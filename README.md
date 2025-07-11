# ToDoAssistant

ToDoAssistant is an iOS app that lets you keep track of pending tasks ("ToDos"), letting you establish tags, due date, priority, description and even setting notifications for each one.

It is written on Swift 6, using SwiftUI

No third party packages are needed to buid this code. Only he most recent version of Xcode.

Some major views of this project were created following MVVM arquitectural pattern, while the rest use MVC.

The project incorporates tests that check the most basic data usage inside the data controller and SwiftData models, basic happy path UI testing, as well as a single performance test. 

Some accesibility features are incorporated in the app, such as identifiers and hints.

The app is localized to both english and spanish with the use of string catalogs.

SwiftLint is used to mantain an acceptable level of code standardization.

This project was mostly done thanks to the teachings of hackingwithswift.com, the Apple Developer official documentation, and Ahmed Yamany's blog (for a fix with the buggy swiping-back on NavigationSplitView for iOS).
