# GitProfile

A GitHub profile viewer app built using **SwiftUI** and modern **MVVM architecture**.

This project demonstrates modular design, API integration, local data caching, and testability using pure Swift.

---

## 🧱 Architecture

The project consists of two main modules:

### 1. [`GitProfile`](https://github.com/tiennv166/git-profile/tree/main/GitProfile)
- UI layer written entirely in **SwiftUI**.
- Follows the **MVVM pattern** with `@MainActor`-based view models.
- Depends on `GitProfileServices` for all API and persistence logic.
- Uses **Dependency Injection (DI)** to access services via protocols for better testability and modular design.

#### Key Views & ViewModels

- [`UserListView`](https://github.com/tiennv166/git-profile/blob/main/GitProfile/UserList/UserListView.swift): Displays list of GitHub users with infinite scrolling and pull-to-refresh.
- [`UserListViewModel`](https://github.com/tiennv166/git-profile/blob/main/GitProfile/UserList/UserListViewModel.swift): Manages user list state, API, and caching logic.

- [`UserDetailsView`](https://github.com/tiennv166/git-profile/blob/main/GitProfile/UserDetails/UserDetailsView.swift): Displays detailed profile for a specific user with pull-to-refresh support.
- [`UserDetailsViewModel`](https://github.com/tiennv166/git-profile/blob/main/GitProfile/UserDetails/UserDetailsViewModel.swift): Manages detailed user fetching and cache logic.

#### Supporting Types

- [`DataLoadableState`](https://github.com/tiennv166/git-profile/blob/main/GitProfile/Commons/DataLoadableState.swift): A generic enum used across view models to represent the state of data loading. It encapsulates common UI states such as:
  - `.nothing`: No data loaded yet
  - `.loading`: Data is currently being fetched (may contain cached data)
  - `.success(data)`: Data loaded successfully
  - `.error`: An error occurred while loading

This abstraction helps streamline state management between the view and the view model, enabling consistent rendering for loading indicators, content, and error messages.


### 2. [`GitProfileServices`](https://github.com/tiennv166/git-profile/tree/main/GitProfileServices)
- Core logic module responsible for:
  - **Fetching data** from GitHub API using [`APIKit`](https://github.com/ishkawa/APIKit)
  - **Local caching** with Core Data
- Implements clean separation of concerns:
  - Only exposes protocols/interfaces publicly
  - All concrete implementations remain internal
  - All services are resolved through factories or injected via DI

#### Public Interfaces
- [`GitHubAPIServiceType`](https://github.com/tiennv166/git-profile/blob/main/GitProfileServices/Interfaces/GitHubAPIServiceType.swift): Defines methods to fetch GitHub users and details.
- [`LocalStorageType`](https://github.com/tiennv166/git-profile/blob/main/GitProfileServices/Interfaces/LocalStorageType.swift): Interface for local caching and persistence.
- [`User`](https://github.com/tiennv166/git-profile/blob/main/GitProfileServices/Interfaces/Models/User.swift): Shared user model used across the app and services.


#### Internal Implementations

- [`GitHubAPIService`](https://github.com/tiennv166/git-profile/tree/main/GitProfileServices/Internals/GitHubAPIService): Concrete implementation of `GitHubAPIServiceType` using APIKit
- [`LocalStorageClient`](https://github.com/tiennv166/git-profile/tree/main/GitProfileServices/Internals/LocalStorage): Core Data-backed implementation of `LocalStorageType`

---

## 📦 Dependencies

Using **Swift Package Manager (SPM)** for all third-party dependencies.

### In `GitProfile`:
- [`Kingfisher`](https://github.com/onevcat/Kingfisher) – image loading and caching
- [`SkeletonUI`](https://github.com/CSolanaM/SkeletonUI) – loading skeleton views
- [`LanguageManager_iOS`](https://github.com/Abedalkareem/LanguageManager-iOS) – dynamic language switching

### In `GitProfileServices`:
- [`APIKit`](https://github.com/ishkawa/APIKit) – simple and powerful networking abstraction

---

## 🚀 Features

- Browse GitHub users with infinite scrolling
- View detailed user profiles
- Pull to refresh to reload the latest data in both user list and user details views
- Local cache for offline access
- Smart refresh logic (uses cache first)

---

## 🧪 Testing

Unit tests are included and organized into modules:

- [`GitProfileTests`](https://github.com/tiennv166/git-profile/tree/main/GitProfileTests): tests view models and UI logic
- [`GitProfileServicesTests`](https://github.com/tiennv166/git-profile/tree/main/GitProfileServicesTests): tests API calls, local caching, and Core Data behavior

Test coverage includes:
- Data loading logic
- Pagination
- Error handling
- Cache fallback behavior

---

## ⚙️ Requirements

- Xcode 16+
- Swift 6.0

---

## 📱 Supported Platforms

- iOS 16.0

---

## 🚧 Setup

1. Clone or Download the Repository

2. Open the project in Xcode

   - Open: `GitProfile.xcodeproj`

3. Build and Run the App

   - In Xcode, select the `GitProfile` target
   - Choose a simulator (e.g. iPhone 16 Pro with iOS 18.5)
   - Press `⌘ + R` or go to `Product > Run` to build and launch the app

4. Run Unit Tests

   - Make sure the scheme is set to `GitProfile`
   - Press `⌘ + U` or go to `Product > Test` to execute all tests
   - This will run:
     - `GitProfileTests`
     - `GitProfileServicesTests`
