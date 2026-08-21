# Farm To Home v9 — final setup

## Replace

ZIPలో ఉన్న files అన్నింటినీ ఈ folderలో paste చేయాలి:

`C:\Users\dell\StudioProjects\farm_to_home_app`

Windows అడిగితే **Replace the files in the destination** select చేయాలి. Existing `assets` folder delete చేయకూడదు.

Existing `android`, `assets`, `ios`, `web`, `windows` foldersను delete చేయకూడదు.
ఈ ZIP safe overlay: కొత్త `lib`, `backend`, `postman`, tests/scripts merge అవుతాయి.

## ఒక్క commandతో complete verification

Android Studio Terminalలో project root నుంచి:

```powershell
powershell -ExecutionPolicy Bypass -File .\verify_everything.ps1
```

PostgreSQL password అడిగినప్పుడు pgAdminకి పనిచేసే real password enter చేయాలి. Script backend tests, migration coverage, Spring package, Flutter dependencies, `flutter analyze`, Flutter tests, backend runtime health, PostgreSQL connection, Postman JSON validation అన్నీ చేస్తుంది.

## Backend run

Verification పూర్తయ్యాక backendని run చేయడానికి:

```powershell
powershell -ExecutionPolicy Bypass -File .\start_backend.ps1
```

Password enter చేసిన తరువాత terminal close చేయకుండా ఉంచాలి. Browserలో `http://localhost:8080/actuator/health` → `UP` వస్తే backend + PostgreSQL connected.

## Flutter run

Second terminalలో:

```powershell
flutter run -d chrome
```

## Postman full API test

`postman` folderలో ఉన్న collection JSON మరియు environment JSON import చేయాలి. Existing collection popup వస్తే **Apply to all → Replace**. Environmentలో valid `firebaseToken` paste చేసి **Run collection** ఒక్కసారి click చేయాలి. 54 requests వరుసగా run అవుతాయి.

Postmanలో top-right environment dropdown నుంచి **Farm To Home - Local Full Test**
select చేయాలి. `firebaseToken` current tokenగా ఉండాలి. Collection menu `...` →
**Run collection** → **Run Farm To Home Backend v9** click చేయాలి.

## Important production boundary

- COD order flow real PostgreSQLలో store అవుతుంది.
- Google/email/phone authentication Firebase production services ద్వారా జరుగుతుంది.
- Real SMS OTP రావాలంటే Firebase Phone provider, India SMS region, Android SHA fingerprints, web authorized domain/reCAPTCHA correctగా configure కావాలి.
- Google Pay/PhonePe/card real money flow merchant onboarding, production keys, signature verification, webhook verification పూర్తయ్యే వరకు intentionally blocked ఉంటుంది. UIలో “TEST MODE”గా fake success చూపించదు.
