# OpenClaw Bridge

OpenClaw Bridge is a Flutter-based Android application that acts as a bridge between your device's notifications and a self-hosted OpenClaw agent. It listens for incoming notifications, filters them based on user-defined keywords, and forwards relevant data to your server via HTTP webhooks.

## Features

*   **Notification Listener:** Automatically detects incoming notifications from installed applications.
*   **Keyword Filtering:** Triggers the webhook only if the notification **title** contains specific user-defined keywords.
*   **Configurable Service:**
    *   **Foreground Service:** Runs with a persistent notification for maximum reliability.
    *   **Background Service:** Runs unobtrusively.
*   **Auto-Start:** Service starts automatically on device boot.
*   **Webhook Integration:** Sends a JSON payload containing the notification title, body, and package name.
*   **Activity Log:** View a history of processed notifications and server responses.

## Getting Started

### Prerequisites

*   Flutter SDK installed.
*   Android device (Notification Access is required).
*   A running instance of OpenClaw (or any HTTP endpoint).

### Installation

1.  Clone the repository.
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the app on your connected device:
    ```bash
    flutter run
    ```

## Usage

1.  **Permissions:** Grant **Notification Access** when prompted.
2.  **Configuration:**
    *   **Server:** Set your OpenClaw URL and Bearer Token in Settings.
    *   **Filters:** Add keywords (e.g., "Alert", "Home") to filter notification titles.
    *   **Service Mode:** Choose between Foreground (Persistent) or Background execution.
3.  **Logs:** Check the **History** tab to verify that notifications are being captured and sent successfully.