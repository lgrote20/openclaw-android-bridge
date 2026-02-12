# OpenClaw Bridge

OpenClaw Bridge is a Flutter-based Android application designed to act as a bridge between Samsung's "Modes and Routines" (or any Android launcher supporting App Shortcuts) and a self-hosted OpenClaw agent.

## Features

*   **Dynamic Shortcuts:** Create custom actions within the app that are published as Android App Shortcuts.
*   **Samsung Routines Integration:** Use these shortcuts as actions within Samsung Modes and Routines.
*   **Webhook Trigger:** When a shortcut is triggered, the app sends an HTTP POST request to your configured OpenClaw server.
*   **Secure Auth:** Supports Bearer Token authentication for your server.

## Getting Started

### Prerequisites

*   Flutter SDK installed.
*   Android device (Samsung device recommended for Routines integration).
*   A running instance of OpenClaw (or any HTTP endpoint accepting POST requests).

### Installation

1.  Clone the repository.
2.  Navigate to the project directory:
    ```bash
    cd openclaw_bridge
    ```
3.  Install dependencies:
    ```bash
    flutter pub get
    ```
4.  Run the app on your connected device:
    ```bash
    flutter run
    ```

## Usage

1.  **Configure Server:**
    *   Open the app and go to **Settings**.
    *   Enter your OpenClaw Server URL (e.g., `https://my-openclaw.com/api/webhook`).
    *   Enter your Bearer Token.
    *   Save.

2.  **Create Actions:**
    *   Go to the **Action List**.
    *   Click the `+` button.
    *   Enter an **ID** (e.g., `night_mode`) and a **Label** (e.g., "Activate Night Mode").
    *   Save. This registers a shortcut with the Android system.

3.  **Triggering:**
    *   **Manual:** Long press the app icon on your home screen to see and trigger the shortcuts.
    *   **Samsung Routines:** Open "Modes and Routines" -> Create Routine -> Add Action -> Apps -> OpenClaw Bridge -> Select your action.