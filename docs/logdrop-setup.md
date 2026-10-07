# LogDrop setup

Copy `docs/LogDrop-Services.example.plist` to `LogDropDemoApp/LogDrop-Services.plist` and replace `YOUR_APP_ID` with your project App ID. The local configuration file is ignored by Git.

For dSYM uploads, replace `YOUR_API_KEY` in the Xcode target’s LogDrop upload build phase locally. Do not commit your credentials.

Push notifications require your Apple development team, provisioning profiles with Push Notifications and App Groups enabled, and the same App Group on the app and notification service extension.
