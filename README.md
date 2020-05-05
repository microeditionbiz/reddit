# Reddit Code Challenge

This app shows top feed from Reddit.

+ It uses MVVM-C pattern. Fetches are handle via the View Model and actions and navigation via Coordiantors.
+ Dependency injection is managed via a general container and dependency factories.
+ Third party dependencies weren't used. MEKit folder contains code that I usually reuse for other projects, it includes code to manage images download, API interactions and Core Data wrapper.
+ Feed list was implemented using UITableView and the new UITableViewDiffableDataSource contained by a UISplitViewController.
+ I used some Combine basic features in RedditDataManager.
+ The app supports all device orientations and runs on iPhone and iPad.
+ You can pull down to refresh.
+ It has pagination support.
+ Core data model persists Links state: read status and also the ones that were marked as dimissed. Ideally this has to be handled via API to have a single source of truth.
+ I could've loaded cached links when the app starts, but I didn't do that because I wasn't able to find the right sort criteria used by Reddit on top response. The API documentation is not clear about this.
+ It supports Dark mode.
+ You can see Link details for images and general web content. 
+ Links details can be shared or saved locally (images).
+ Swiftgen was used to generate Core data NSManagedObject subclasses.
+ Dismiss Link was implemented with swipe gesture.

Not implemented:

+ Dismiss all.
+ App state-preservation/restoration.
