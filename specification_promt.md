# Project Specification: OpenClaw Android Bridge

## Overview
The goal is to refactor the existing Flutter application to function as a **Notification Listener Bridge**. The app will listen for incoming Android notifications, filter them based on user-defined keywords, and forward the notification data to a self-hosted OpenClaw instance via HTTP POST webhooks.

## Functional Requirements

### 1. Notification Listener Service
- **Mechanism:** Use `flutter_notification_listener` to intercept incoming notifications.
- **Permissions:** The app must request "Notification Access" permissions from the user.
- **Auto-Start:** The service should automatically start when the device boots.

### 2. Filtering Logic
- **Keyword Matching:** The user can define a list of keywords in the settings.
- **Logic:**
    - When a notification arrives, check if the **Title** contains any of the defined keywords (case-insensitive).
    - If a match is found, trigger the webhook.
    - If no match is found, ignore the notification.
- **Future Scope:** App-specific filtering (package name) is deferred for later, but the architecture should allow for it.

### 3. Webhook Integration
- **Endpoint:** Configurable in settings (URL).
- **Authentication:** Configurable Bearer Token in settings.
- **Payload Structure:**
    ```json
    {
      "title": "String",
      "body": "String",
      "packageName": "String",
      "timestamp": "Long (Epoch)"
    }
    ```

### 4. Background Execution
- **Workmanager:** Use `workmanager` to handle periodic tasks (no retrying failed webhooks though) and ensure the app remains active in the background.
- **Service Modes:** The user must be able to select between two modes in Settings:
    1.  **Foreground Service:** The listener runs with a persistent notification (configurable via the plugin).
    2.  **Background Service:** Standard execution.

### 5. User Interface
- **Home Screen:**
    - **Status Indicator:** Shows if the listener service is running.
    - **History/Log:** A list view showing recently captured notifications and their webhook status (Success/Fail) for transparency.
- **Settings Screen:**
    - Server URL input.
    - Bearer Token input.
    - Keyword management (Add/Remove keywords).
    - Service Mode toggle (Foreground/Background).
    - "Grant Permissions" button to open Android Notification Access settings.

### 6. Legacy Cleanup
- **Remove:** All functionality related to "App Shortcuts" and Samsung Routines integration from the previous version.

### 7. Technical Architecture & Project Structure
To ensure maintainability and separation of concerns, the project must follow this structure:

- **`lib/models/`**:
    - `notification_log.dart`: Model for storing history (title, timestamp, status).
    - `app_config.dart`: Model for settings (url, token, keywords).
- **`lib/services/`**:
    - `notification_service.dart`: Wraps `flutter_notification_listener`. Contains the **static/top-level** callback function required for background execution.
    - `api_service.dart`: Handles HTTP POST requests.
    - `storage_service.dart`: Wraps `shared_preferences`. **Crucial:** Since the background listener runs in a separate Isolate, use SharedPreferences to persist logs so the UI Isolate can read them.
    - `background_service.dart`: Configures `workmanager`.
- **`lib/screens/`**:
    - `home_screen.dart`: Displays service status and the history list.
    - `settings_screen.dart`: Form for configuration.
- **`lib/utils/`**:
    - Constants and helper functions.

**Implementation Note:**
The `onNotificationReceived` callback runs in a background Isolate. It cannot update the UI directly. It must save data to `SharedPreferences`. The UI (Home Screen) should reload data from `SharedPreferences` when the view appears or via a refresh indicator.