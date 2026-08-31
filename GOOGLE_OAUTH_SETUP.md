# Google Cloud OAuth 2.0 Setup Guide for Farm To Home

This document explains how to configure **Google Cloud Console OAuth 2.0** for Flutter Web and Spring Boot backend.

---

## 1. Create a Google Cloud Project

1. Go to the [Google Cloud Console](https://console.cloud.google.com/).
2. Click **Select a Project** at the top and select **New Project**.
3. Name your project (e.g. `Farm To Home`) and click **Create**.

---

## 2. Configure OAuth Consent Screen

1. In the left navigation menu, go to **APIs & Services** > **OAuth consent screen**.
2. Select **User Type**:
   - Choose **External** (for all public users with a Google Account).
3. Click **Create**.
4. Fill in the App Information:
   - **App name**: `Farm To Home`
   - **User support email**: Your support email (e.g. `veeramallasaipichaiah456@gmail.com`).
   - **Developer contact information**: Your developer email address.
5. Click **Save and Continue**.
6. **Scopes**: Click **Add or Remove Scopes**:
   - Select `userinfo.email` (`.../auth/userinfo.email`)
   - Select `userinfo.profile` (`.../auth/userinfo.profile`)
   - Select `openid`
7. Click **Save and Continue**.
8. If the app status is **Testing**, add Test Users (your Google email address). Publish to **Production** when ready.

---

## 3. Create OAuth 2.0 Web Client ID

1. Go to **APIs & Services** > **Credentials**.
2. Click **+ Create Credentials** > **OAuth client ID**.
3. Select **Application type**: `Web application`.
4. Name: `Farm To Home Web Client`.
5. **Authorized JavaScript origins**:
   - Local Development: `http://localhost:8080`, `http://localhost:3000`, `http://localhost:8085`
   - Production URL: `https://flutter-frontend-production-e8d6.up.railway.app`
6. **Authorized redirect URIs**:
   - Local Development: `http://localhost:8080`, `http://localhost:8080/`, `http://localhost:3000`
   - Production URL: `https://flutter-frontend-production-e8d6.up.railway.app`, `https://flutter-frontend-production-e8d6.up.railway.app/`
7. Click **Create**.
8. Copy your **Client ID** (e.g. `123456789012-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com`).

---

## 4. Configure Client ID in Flutter Web

Open [`web/index.html`](file:///c:/fluttersai/farm_to_home_app/web/index.html) and replace `GOOGLE_WEB_CLIENT_ID.apps.googleusercontent.com` with your Google Web Client ID:

```html
<meta name="google-signin-client_id" content="YOUR_ACTUAL_CLIENT_ID.apps.googleusercontent.com">
```

---

## 5. How Auth Flow Works End-to-End

1. **User Action**: User clicks **"Continue with Google"** on the Login Screen.
2. **Google OAuth UI**: Google's official account chooser opens (identical to Gmail/YouTube).
3. **Google Authentication**: User selects their Google account.
4. **Token Generation**: Google returns an official signed **Google ID Token** (`idToken`).
5. **Backend Verification**: Flutter app sends `idToken` to `/api/v1/auth/google-login` in Spring Boot.
6. **Google Verification API**: Spring Boot verifies the token via `https://oauth2.googleapis.com/tokeninfo?id_token=...` and extracts verified email, name, and profile photo.
7. **Session JWT**: Backend creates a user account if new, creates a backend JWT session token, and logs the user into Farm To Home.
