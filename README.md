# Shop App

This app is used to show how state management works in Flutter using Provider package

## Setup Firebase

- Create a firebase database in the console
- Go to `Authentication` > `Sign-in method` > Enable `Email/Password`
- Go to `Database` > `Rules` and add the following lines:
```
{
  /* Visit https://firebase.google.com/docs/database/security to learn more about security rules. */
  "rules": {
    //".read": true,
      //".write": true,
    ".read": "auth != null",
    ".write": "auth != null",
    "products": {
      ".indexOn": ["creatorId"]
    }
  }
}
```
- Create a new file called `.env` in the root folder of the project and then add:

```
DATABASE_URL=<your-database-url>
API_KEY=<your-api-key>
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
