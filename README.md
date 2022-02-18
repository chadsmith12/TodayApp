## Today App

Today App is basic reminders application built in UIKit using Apples iOS Developer Course. The application was built mainly to learn UIKit and to also integrate into other Apple Frameworks.

The basic idea of the app is:

* The app asks to for permission to access reminders
* App can read your reminders, with permission
* User can add new Reminders
* User can edit Reminders
* User can delete Reminders
* User can mark Reminders as complete
* Reminders are synced automatically using EventKit

When the user gives permission to access reminders then the App will use EventKit, access the event store, and read reminders and sync reminder changes across apps.

This app was made using the following course: https://developer.apple.com/tutorials/app-dev-training#uikit-essentials