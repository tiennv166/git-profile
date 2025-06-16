//
//  NavigationManager.swift
//  GitProfile
//
//  Created by Tien Nguyen on 16/6/25.
//

import Foundation
import SwiftUI

/// A global navigation manager using `@Published` state for navigation path and root.
/// Designed to be used with SwiftUI's `NavigationStack` and support programmatic navigation.
@MainActor
final class NavigationManager: ObservableObject {
    
    /// The current root screen of the app. (Can be expanded to support tabs or onboarding flows.)
    @Published var currentRoot: AppRoot = .home
    
    /// The current navigation path stack, used by `NavigationStack`.
    @Published var navPath: [NavDestination] = []
    
    /// Pushes a new destination onto the navigation stack.
    func push(destination: NavDestination) {
        navPath.append(destination)
    }
    
    /// Pops the topmost destination from the navigation stack.
    func pop() {
        guard !navPath.isEmpty else { return }
        navPath.removeLast()
    }
    
    /// Pops all destinations, returning to the root.
    func popToRoot() {
        navPath.removeAll()
    }
}

/// Enum representing the root-level flows of the app (e.g., home, onboarding, etc.)
enum AppRoot: Equatable {
    case home

    /// Returns the corresponding root view for each app flow.
    /// This is used to map an `AppRoot` case to its associated SwiftUI content.
    @MainActor
    @ViewBuilder
    var content: some View {
        switch self {
        case .home:
            UserListView()
        }
    }
}

/// Enum representing navigable destinations within the app.
/// Conforms to `Codable` and `Hashable` to work with `NavigationStack`.
enum NavDestination: Codable, Hashable {
    case userDetails(String) // Navigate to user details screen by username
    
    /// Returns the associated SwiftUI view for each navigation case.
    @MainActor
    @ViewBuilder
    var content: some View {
        switch self {
        case let .userDetails(username):
            UserDetailsView(username: username)
        }
    }
}
