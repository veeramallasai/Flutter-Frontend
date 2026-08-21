#!/usr/bin/env python3
"""Offline consistency audit for the Farm To Home Flutter + Spring project."""

from __future__ import annotations

import json
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

import yaml


ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
JAVA = ROOT / "backend" / "src"
MIGRATIONS = ROOT / "backend" / "src" / "main" / "resources" / "db" / "migration"

EXPECTED_TABLES = {
    "products",
    "coupons",
    "carts",
    "cart_items",
    "orders",
    "order_items",
    "payments",
    "app_users",
    "addresses",
    "categories",
    "banners",
    "offers",
    "farmers",
    "delivery_slots",
    "favorites",
    "reviews",
    "notifications",
    "notification_preferences",
    "support_tickets",
    "device_tokens",
    "payment_events",
}


def fail(message: str, errors: list[str]) -> None:
    errors.append(message)


def mask_source(source: str) -> str:
    """Remove comments and string contents while keeping delimiters/newlines."""
    chars = list(source)
    output = list(source)
    index = 0
    length = len(chars)
    state = "code"
    quote = ""
    triple = False
    while index < length:
        current = chars[index]
        nxt = chars[index + 1] if index + 1 < length else ""
        if state == "code":
            if current == "/" and nxt == "/":
                output[index] = output[index + 1] = " "
                index += 2
                state = "line_comment"
                continue
            if current == "/" and nxt == "*":
                output[index] = output[index + 1] = " "
                index += 2
                state = "block_comment"
                continue
            if current in ("'", '"'):
                quote = current
                triple = source[index : index + 3] == current * 3
                width = 3 if triple else 1
                for offset in range(width):
                    output[index + offset] = " "
                index += width
                state = "string"
                continue
            index += 1
            continue
        if state == "line_comment":
            if current == "\n":
                state = "code"
            else:
                output[index] = " "
            index += 1
            continue
        if state == "block_comment":
            if current == "*" and nxt == "/":
                output[index] = output[index + 1] = " "
                index += 2
                state = "code"
            else:
                if current != "\n":
                    output[index] = " "
                index += 1
            continue
        if state == "string":
            width = 3 if triple else 1
            if triple and source[index : index + 3] == quote * 3:
                for offset in range(3):
                    output[index + offset] = " "
                index += 3
                state = "code"
                continue
            if not triple and current == quote:
                output[index] = " "
                index += 1
                state = "code"
                continue
            if current == "\\" and index + 1 < length:
                output[index] = " "
                if chars[index + 1] != "\n":
                    output[index + 1] = " "
                index += 2
                continue
            if current != "\n":
                output[index] = " "
            index += 1
    return "".join(output)


def check_delimiters(path: Path, errors: list[str]) -> None:
    masked = mask_source(path.read_text(encoding="utf-8"))
    stack: list[tuple[str, int]] = []
    pairs = {")": "(", "]": "[", "}": "{"}
    for position, token in enumerate(masked):
        if token in "([{":
            stack.append((token, position))
        elif token in pairs:
            if not stack or stack[-1][0] != pairs[token]:
                line = masked.count("\n", 0, position) + 1
                fail(f"{path.relative_to(ROOT)}:{line}: unmatched {token}", errors)
                return
            stack.pop()
    if stack:
        token, position = stack[-1]
        line = masked.count("\n", 0, position) + 1
        fail(f"{path.relative_to(ROOT)}:{line}: unclosed {token}", errors)


def check_dart_imports(path: Path, errors: list[str]) -> None:
    source = path.read_text(encoding="utf-8")
    for imported in re.findall(r"^\s*import\s+['\"]([^'\"]+)", source, re.MULTILINE):
        candidate: Path | None = None
        if imported.startswith("package:farm_to_home_app/"):
            candidate = ROOT / imported.removeprefix("package:farm_to_home_app/")
        elif imported.startswith("."):
            candidate = (path.parent / imported).resolve()
        if candidate is not None and not candidate.is_file():
            fail(f"{path.relative_to(ROOT)}: missing import {imported}", errors)


def check_java_imports(path: Path, errors: list[str]) -> None:
    source = path.read_text(encoding="utf-8")
    for imported in re.findall(
        r"^\s*import\s+(com\.farmtohome\.api\.[A-Za-z0-9_.*]+);",
        source,
        re.MULTILINE,
    ):
        parts = imported.removeprefix("com.farmtohome.api.").rstrip(".*").split(".")
        found = False
        for width in range(len(parts), 0, -1):
            candidate = JAVA / "main" / "java" / "com" / "farmtohome" / "api"
            candidate = candidate.joinpath(*parts[:width]).with_suffix(".java")
            if candidate.is_file():
                found = True
                break
        if not found:
            fail(f"{path.relative_to(ROOT)}: missing internal import {imported}", errors)


def main() -> int:
    errors: list[str] = []
    dart_files = sorted(LIB.rglob("*.dart"))
    java_files = sorted(JAVA.rglob("*.java"))
    source_files = dart_files + java_files

    for path in source_files:
        if path.stat().st_size == 0:
            fail(f"Empty source file: {path.relative_to(ROOT)}", errors)
            continue
        check_delimiters(path, errors)
    for path in dart_files:
        check_dart_imports(path, errors)
    for path in java_files:
        check_java_imports(path, errors)

    try:
        pubspec = yaml.safe_load((ROOT / "pubspec.yaml").read_text(encoding="utf-8"))
        if pubspec.get("name") != "farm_to_home_app":
            fail("pubspec project name is incorrect", errors)
        assets = set(pubspec.get("flutter", {}).get("assets", []))
        expected_assets = {
            "assets/icons/",
            "assets/images/categories/",
            "assets/images/vegetables/",
            "assets/images/fruits/",
            "assets/images/dairy/",
        }
        if assets != expected_assets:
            fail("pubspec asset declarations are incomplete", errors)
    except Exception as error:  # noqa: BLE001
        fail(f"pubspec.yaml is invalid: {error}", errors)

    try:
        ET.parse(ROOT / "backend" / "pom.xml")
    except Exception as error:  # noqa: BLE001
        fail(f"backend/pom.xml is invalid: {error}", errors)

    migration_names = [path.name for path in sorted(MIGRATIONS.glob("V*__*.sql"))]
    if migration_names != [
        "V1__schema.sql",
        "V2__coupons.sql",
        "V3__product_catalog.sql",
        "V4__app_users.sql",
        "V5__addresses.sql",
        "V6__platform_modules.sql",
        "V7__notification_preferences.sql",
    ]:
        fail(f"Unexpected migration sequence: {migration_names}", errors)
    sql = "\n".join(path.read_text(encoding="utf-8") for path in sorted(MIGRATIONS.glob("*.sql")))
    tables = set(re.findall(r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:public\.)?([a-z_]+)", sql, re.I))
    missing_tables = EXPECTED_TABLES - tables
    if missing_tables:
        fail(f"Missing database tables: {sorted(missing_tables)}", errors)

    product_catalog = (MIGRATIONS / "V3__product_catalog.sql").read_text(encoding="utf-8")
    product_rows = re.findall(
        r"^\s*\('([^']+)',\s*'([^']+)',\s*'([^']+)',\s*'([^']+)',"
        r"\s*'[^']*',\s*'(vegetables|fruits|dairy)',\s*'([^']+)',\s*'([^']+)'",
        product_catalog,
        re.MULTILINE,
    )
    if len(product_rows) != 111:
        fail(f"Expected 111 seeded products, found {len(product_rows)}", errors)
    product_ids = [row[0] for row in product_rows]
    image_paths = [row[5] for row in product_rows]
    if len(product_ids) != len(set(product_ids)):
        fail("Product catalog contains duplicate ids", errors)
    if len(image_paths) != len(set(image_paths)):
        fail("Product catalog contains duplicate image paths", errors)
    for product_id, display_name, _english, telugu, category, image_path, unit in product_rows:
        if not re.search(r"[\u0c00-\u0c7f]", telugu) or f"({telugu})" not in display_name:
            fail(f"Product {product_id} is missing its Telugu display name", errors)
        expected_prefix = f"assets/images/{category}/"
        if not image_path.startswith(expected_prefix) or not image_path.endswith(".png"):
            fail(f"Product {product_id} has invalid image path {image_path}", errors)
        if not unit.strip():
            fail(f"Product {product_id} has an empty selling unit", errors)

    collection_path = ROOT / "postman" / "FarmToHome_Complete_v9.postman_collection.json"
    environment_path = ROOT / "postman" / "FarmToHome_Local_Full_Test.postman_environment.json"
    try:
        collection = json.loads(collection_path.read_text(encoding="utf-8"))
        environment = json.loads(environment_path.read_text(encoding="utf-8"))

        def requests(items: list[dict]) -> list[dict]:
            result: list[dict] = []
            for item in items:
                if "request" in item:
                    result.append(item)
                result.extend(requests(item.get("item", [])))
            return result

        request_count = len(requests(collection.get("item", [])))
        if request_count != 54:
            fail(f"Expected 54 Postman requests, found {request_count}", errors)
        request_names = [item.get("name", "") for item in requests(collection.get("item", []))]
        if len(request_names) != len(set(request_names)):
            fail("Postman collection contains duplicate request names", errors)
        env_keys = {item.get("key") for item in environment.get("values", [])}
        if not {"baseUrl", "firebaseToken", "productId"}.issubset(env_keys):
            fail("Postman environment is missing required variables", errors)
    except Exception as error:  # noqa: BLE001
        fail(f"Postman JSON is invalid: {error}", errors)

    routes_source = (LIB / "app" / "app_routes.dart").read_text(encoding="utf-8")
    router_source = (LIB / "app" / "app_router.dart").read_text(encoding="utf-8")
    route_names = set(re.findall(r"static const String (\w+)\s*=", routes_source))
    handled_routes = set(re.findall(r"case AppRoutes\.(\w+):", router_source))
    if route_names != handled_routes:
        fail(
            f"Route mismatch; unhandled={sorted(route_names - handled_routes)}, "
            f"undefined={sorted(handled_routes - route_names)}",
            errors,
        )

    forbidden_ui_text = {
        "This screen is being connected.",
        "TEST MODE",
    }
    all_dart_source = "\n".join(path.read_text(encoding="utf-8") for path in dart_files)
    for text in forbidden_ui_text:
        if text in all_dart_source:
            fail(f"Production UI still contains forbidden placeholder text: {text}", errors)

    if errors:
        print("STATIC AUDIT FAILED")
        for error in errors:
            print(f"- {error}")
        return 1

    print("STATIC AUDIT PASSED")
    print(f"- Dart source files: {len(dart_files)}")
    print(f"- Java source/test files: {len(java_files)}")
    print(f"- Flutter routes checked: {len(route_names)}")
    print(f"- PostgreSQL app tables: {len(EXPECTED_TABLES)} (+ flyway_schema_history)")
    print(f"- Seeded bilingual products checked: {len(product_rows)}")
    print("- Flyway migrations: 7")
    print("- Postman requests: 54")
    return 0


if __name__ == "__main__":
    sys.exit(main())
