# Farm To Home v8 - Saved Addresses

ఈ ZIPలో Saved Addresses moduleని Spring Boot + PostgreSQL backendకి connect చేశాం.

## 1. ZIP replace చేయడం

1. Running Flutter app మరియు backend terminalలో `Ctrl + C` చేయండి.
2. ZIPని open/extract చేయండి.
3. ZIPలో ఉన్న files/folders అన్నీ ఈ project rootలో paste చేయండి:

   `C:\Users\dell\StudioProjects\farm_to_home_app`

4. Windows అడిగితే **Replace the files in the destination** ఎంచుకోండి.
5. Existing `lib`, `assets`, `backend` folders delete చేయవద్దు.

## 2. Backend start - ఒక్క command

Project rootలో PowerShell terminal open చేసి:

```powershell
cd C:\Users\dell\StudioProjects\farm_to_home_app
powershell -ExecutionPolicy Bypass -File .\start_backend.ps1
```

అది PostgreSQL password అడిగితే మీ real `postgres` password enter చేయండి. Password screenపై కనిపించదు; అది normal.

Backend start అయినప్పుడు terminal చివరలో `Started FarmToHomeApiApplication` వస్తుంది. Terminalని close చేయవద్దు.

First successful startలో Flyway automaticగా `public.addresses` table create చేస్తుంది.

## 3. Flutter start

Second terminal open చేసి:

```powershell
cd C:\Users\dell\StudioProjects\farm_to_home_app
flutter clean
flutter pub get
flutter analyze
flutter run -d chrome
```

## 4. Test flow

1. Login చేయండి.
2. Profile > Saved Addresses > Add Addressకి వెళ్లండి.
3. Home/Work address save చేయండి.
4. Second address add చేసి defaultగా set చేయండి.
5. Cart > Delivery > Address > Checkout > Cash on Delivery > Place Order test చేయండి.
6. Address create/edit/delete/default changes app restart చేసినా అలాగే ఉండాలి.

## 5. pgAdminలో చూడడం

Path:

`Servers > PostgreSQL > Databases > farm_to_home > Schemas > public > Tables > addresses`

Tableపై right click చేసి **View/Edit Data > All Rows** ఎంచుకోండి.

లేదా Query Toolలో:

```sql
SELECT id, owner_uid, full_name, phone, address_type, is_default,
       city, state, postal_code, created_at, updated_at
FROM public.addresses
ORDER BY is_default DESC, created_at DESC;
```

## Security included

- ప్రతి address Firebase login UIDకి own అవుతుంది.
- ఒక userకి ఒక default address మాత్రమే ఉంటుంది.
- ఇతర user addressని read/update/delete చేయలేరు.
- Place Order సమయంలో backend address ID ownership verify చేసి, trusted address snapshotని orderలో store చేస్తుంది.
