# 🔔 Firebase Notifications & Credentials Setup Guide (Backend & Mobile App)

This document provides step-by-step instructions on setting up Firebase Cloud Messaging (FCM) and obtaining the required credentials for both the **Laravel Backend** (`zetucrm_web`) and the **Flutter Mobile App** (`zetucrm`).

---

## 🏗️ 1. Architecture Overview

```
                      ┌────────────────────────────────────────┐
                      │            Laravel Backend             │
                      │  - Task Reminders                      │
                      │  - Scorecard Reminders                 │
                      │  - Monthly Financial Reports           │
                      │  - Workspace Invitations               │
                      │  - Requisitions & Approvals            │
                      │  - Generic / Email Notifications       │
                      └──────────────────┬─────────────────────┘
                                         │
                        [FCM v1 OAuth2 Service Account API]
                                         │
                                         ▼
                      ┌────────────────────────────────────────┐
                      │    Firebase Cloud Messaging (FCM)      │
                      └────────────┬──────────────┬────────────┘
                                   │              │
                           (Android)              (iOS APNs)
                                   │              │
                                   ▼              ▼
                      ┌────────────────────────────────────────┐
                      │           Flutter Mobile App           │
                      │  - Auto-syncs device FCM token         │
                      │  - Heads-up foreground push banners    │
                      │  - In-app notification bell counter    │
                      │  - Swipe-to-dismiss notification drawer│
                      └────────────────────────────────────────┘
```

---

## 🛠️ 2. Step 1: Create or Open Your Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Log in with your Google account.
3. Click **Add project** (or select your existing Zetu project).
4. Project name: e.g. `ZetuCRM` or `zetucrm-production`.
5. Google Analytics: Optional (can enable or disable).
6. Click **Create project** and wait for it to be ready.

---

## 🔑 3. Step 2: Backend Credentials (Google Service Account JSON)

The Laravel backend uses the **Google FCM v1 REST API** via OAuth2 Service Account credentials (RS256 signed JWTs) located in `App\Services\FcmService`.

### How to generate the Service Account JSON:

1. In the [Firebase Console](https://console.firebase.google.com/), open your project.
2. Click the **Gear icon (⚙️)** next to *Project Overview* in the top left sidebar and choose **Project settings**.
3. Select the **Service accounts** tab.
4. Ensure **Firebase Admin SDK** is highlighted.
5. Click the button: **Generate new private key**, then confirm by clicking **Generate key**.
6. A `.json` file will download to your computer (e.g. `zetucrm-firebase-adminsdk-xxxx-yyyy.json`).

### Setting it up in Laravel Backend (`zetucrm_web`):

You have two easy options to configure the file in `zetucrm_web`:

#### Option A: Copy file to `storage/app/` (Recommended)
Rename the downloaded file to `firebase-credentials.json` and move it to:
```bash
cp ~/Downloads/zetucrm-firebase-adminsdk-*.json /Volumes/Dephel01/TASHICO/PROJECTS/WORKS/ZETUAPPS/zetucrm_web/storage/app/firebase-credentials.json
```
`FcmService` automatically checks `storage/app/firebase-credentials.json` out of the box!

#### Option B: Set via `.env`
In `/Volumes/Dephel01/TASHICO/PROJECTS/WORKS/ZETUAPPS/zetucrm_web/.env`, add:
```env
FIREBASE_CREDENTIALS="/Volumes/Dephel01/TASHICO/PROJECTS/WORKS/ZETUAPPS/zetucrm_web/storage/app/firebase-credentials.json"
```
Or paste the single-line JSON string:
```env
FIREBASE_CREDENTIALS_JSON='{"type":"service_account","project_id":"...","private_key":"..."}'
```

---

## 📱 4. Step 3: Android Setup in Mobile App (`zetucrm`)

### 1. Register Android App in Firebase Console:
1. In Firebase Console **Project settings** -> **General** tab.
2. Under **Your apps**, click the **Android** icon (or click **Add app** -> **Android**).
3. Fill in the details:
   - **Android package name**: `com.zetuapps.zetucrm` *(MUST match exactly)*
   - **App nickname**: `ZetuCRM Android`
   - **Debug signing certificate SHA-1**: Optional for push notifications (required only for Google Sign-In).
4. Click **Register app**.

### 2. Download and Place `google-services.json`:
1. Click **Download google-services.json**.
2. Move the file into the mobile app's `android/app/` folder:
```bash
cp ~/Downloads/google-services.json /Volumes/Dephel01/TASHICO/PROJECTS/WORKS/ZETUAPPS/zetucrm/android/app/google-services.json
```

> **Note**: The Android build configuration has already been pre-configured with Google Services plugins in `android/settings.gradle.kts` and `android/app/build.gradle.kts`. Once `google-services.json` is placed in `android/app/`, Gradle automatically detects and activates it!

---

## 🍏 5. Step 4: iOS Setup in Mobile App (`zetucrm`)

### 1. Register iOS App in Firebase Console:
1. In Firebase Console **Project settings** -> **General** tab.
2. Under **Your apps**, click **Add app** -> **Apple / iOS** icon.
3. Fill in the details:
   - **Apple bundle ID**: `com.zetuapps.zetucrm` *(MUST match exactly)*
   - **App nickname**: `ZetuCRM iOS`
4. Click **Register app**.

### 2. Download and Place `GoogleService-Info.plist`:
1. Download `GoogleService-Info.plist`.
2. Move it into `ios/Runner/`:
```bash
cp ~/Downloads/GoogleService-Info.plist /Volumes/Dephel01/TASHICO/PROJECTS/WORKS/ZETUAPPS/zetucrm/ios/Runner/GoogleService-Info.plist
```
3. Open `ios/Runner.xcworkspace` in Xcode, right click `Runner` folder -> **Add Files to "Runner"**, select `GoogleService-Info.plist`, ensure **Copy items if needed** is checked and target **Runner** is selected.

### 3. Apple Push Notification service (APNs) Key:
1. Go to your [Apple Developer Account](https://developer.apple.com/account/resources/authkeys/list).
2. Create an **APNs Key** (.p8 file) with Push Notifications enabled. Note down the **Key ID** and your **Team ID**.
3. In Firebase Console -> **Project settings** -> **Cloud Messaging** tab -> Scroll down to **Apple app configuration**.
4. Under **APNs Authentication Key**, click **Upload**, upload the `.p8` file, enter your **Key ID** and **Team ID**.

---

## 🚀 6. Step 5: Testing & Verifying Notifications

### A. Testing Mobile Push from Web CRM:
1. Launch the mobile app and log in with your credentials.
2. The mobile app automatically registers its FCM device token with the backend:
   ```
   POST /api/v1/user/fcm-token
   Payload: { "fcm_token": "..." }
   ```
3. In your web browser, navigate to your CRM:
   `http://localhost:8001/settings/notifications`
4. Under notification channels, click **Send Test** for **Mobile Push**.
5. Check your phone / simulator:
   - You will see a push banner notification with sound.
   - The notification is logged in the In-App Notification Center.

### B. Testing Automated Reminders & Reports via Artisan CLI:
To test sending all pending task & scorecard reminders to both Email and Mobile Devices:
```bash
# Force trigger unified task & scorecard reminders immediately:
php artisan reminders:unified --force
```

To test generating and dispatching monthly financial reports to both Email and Mobile Devices:
```bash
php artisan queue:listen
# In another terminal:
php artisan tinker --execute="\Modules\Finance\App\Jobs\GenerateMonthlyFinancialReportsJob::dispatchSync();"
```

---

## 📦 Summary of Supported Notification Triggers

| Event / Notification | Sent to Email | Sent to Mobile Push (FCM) | In-App Bell Center |
| :--- | :---: | :---: | :---: |
| **Task Reminder** | ✅ | ✅ | ✅ |
| **Task Assigned** | — | ✅ | ✅ |
| **Task Created (Admins)** | — | ✅ | ✅ |
| **Scorecard Reminder** | ✅ | ✅ | ✅ |
| **Monthly Financial Report** | ✅ | ✅ | ✅ |
| **Workspace Invitation** | ✅ | ✅ (if existing user) | ✅ |
| **Requisition Approval Request** | — | ✅ | ✅ |
| **Requisition Status Change** | — | ✅ | ✅ |
| **Any EmailChannel Alert** | ✅ | ✅ (Mirrored) | ✅ (Mirrored) |
