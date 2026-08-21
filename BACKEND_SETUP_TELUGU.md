# Farm To Home — Spring Boot + PostgreSQL Setup

ఈ ZIPలో `lib`, `pubspec.yaml`, `backend` ఉన్నాయి. Existing `assets`, `android`,
Firebase config files delete చేయవద్దు.

## 1. ZIP projectలో paste చేయడం

1. Android Studio close చేయి.
2. ZIPను ఒక temporary folderలో **Extract All** చేయి.
3. Extract అయిన folderలో ఉన్న `lib`, `backend`, `pubspec.yaml`, ఈ guideను copy చేయి.
4. `C:\Users\dell\StudioProjects\farm_to_home_app` open చేయి.
5. అక్కడ paste చేసి Windows అడిగితే **Replace the files in the destination** select చేయి.
6. Existing `assets`, `android`, `ios` folders delete చేయవద్దు.

## 2. pgAdminలో database create చేయడం

1. pgAdmin open చేయి.
2. Left sideలో `Servers` > నీ PostgreSQL server expand చేయి.
3. `Databases` మీద right-click > `Create` > `Database...`.
4. Database name: `farm_to_home`
5. Owner: `postgres`
6. `Save` click చేయి.

Tables manually create చేయవద్దు. Backend first runలో Flyway automaticగా tables,
coupons, Telugu namesతో 111 products create చేస్తుంది.

## 3. Firebase service-account key తీసుకోవడం

1. Firebase Consoleలో `farm-to-home-8c520` project open చేయి.
2. Project settings > `Service accounts` open చేయి.
3. `Generate new private key` click చేసి JSON download చేయి.
4. Safe folder create చేసి file అక్కడ పెట్టు, ఉదాహరణ:
   `C:\firebase-keys\farm-to-home-service-account.json`

ఈ JSONను projectలో paste చేయవద్దు, GitHubకి upload చేయవద్దు, ఎవరికీ పంపవద్దు.

## 4. Backend run చేయడం

Windows PowerShell open చేసి ఈ commands one by one run చేయి. `YOUR_POSTGRES_PASSWORD`
స్థానంలో PostgreSQL install చేసినప్పుడు పెట్టిన actual password ఇవ్వాలి.

```powershell
cd C:\Users\dell\StudioProjects\farm_to_home_app\backend
$env:DB_URL="jdbc:postgresql://localhost:5432/farm_to_home"
$env:DB_USERNAME="postgres"
$env:DB_PASSWORD="YOUR_POSTGRES_PASSWORD"
$env:FIREBASE_PROJECT_ID="farm-to-home-8c520"
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\firebase-keys\farm-to-home-service-account.json"
mvn spring-boot:run
```

Terminal close చేయవద్దు. చివర `Started FarmToHomeApiApplication` రావాలి.

Browserలో `http://localhost:8080/actuator/health` open చేస్తే:

```json
{"status":"UP"}
```

`mvn` command not found వస్తే IntelliJ/STSలో `backend/pom.xml`ను Maven projectగా
open చేసి `FarmToHomeApiApplication.java` run చేయి. అదే environment variablesను
Run Configurationలో add చేయాలి.

## 5. Flutter app run చేయడం

Backend terminal run అవుతూనే ఉండాలి. ఇంకొక PowerShell open చేయి:

```powershell
cd C:\Users\dell\StudioProjects\farm_to_home_app
flutter pub get
flutter analyze
flutter run -d chrome
```

Chrome/Windowsకు backend address automaticగా `http://localhost:8080`.
Android emulatorకు automaticగా `http://10.0.2.2:8080`.

Physical Android phone ఉపయోగిస్తే PC మరియు phone ఒకే Wi-Fiలో ఉండాలి. PC IP
ఉదాహరణకు `192.168.1.5` అయితే:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.5:8080
```

Windows Firewall prompt వస్తే private networksకు Java access allow చేయాలి.

## 6. ఇప్పుడు నిజంగా connect అయినవి

- Product catalog/search/filter — PostgreSQL API
- Home/category/product screens product data — backend API
- Cart add, plus/minus, remove, coupon — PostgreSQL API
- COD order place — backend transaction
- Orders list/details/cancel/reorder — PostgreSQL API
- Stock reduction and cancellation stock restore — backend
- Authentication/Google login/session — Firebase Authentication
- Existing profile/address/notifications — Firebase services

Firebase login చేసిన user ID tokenను Flutter automaticగా Spring Bootకి పంపుతుంది;
backend verify చేసిన తర్వాత మాత్రమే ఆ user cart/orders ఇస్తుంది.

## 7. Payment status

COD flow end-to-end backendతో connected. Online payment intentionally test-successగా
fake చేయలేదు. Razorpay/Stripe వంటి gateway production keys, webhook signature
verification, refund handling add చేసిన తర్వాత మాత్రమే online `Pay Now` enable చేయాలి.

## 8. Common errors

- `password authentication failed`: `DB_PASSWORD` తప్పు.
- `database farm_to_home does not exist`: pgAdminలో Step 2 చేయలేదు.
- `401 Unauthorized`: Flutter login session/ID token లేదు; appలో login అవ్వాలి.
- `Connection refused`: backend terminal run అవడం లేదు లేదా wrong API address.
- Browser CORS error: backend restart చేసి Chrome localhost URLతో test చేయి.
- Product image కనిపించకపోతే existing `assets` folder delete అయిందో, pubspec assets paths
  correctగా ఉన్నాయో check చేసి `flutter clean`, `flutter pub get`, Hot Restart చేయి.

