//
//  UserDetailsViewModel.swift
//  GitProfile
//
//  Created by Tien Nguyen on 15/6/25.
//

import Foundation
import GitProfileServices

/// ViewModel responsible for fetching and caching details of a specific GitHub user.
/// Automatically attempts to load cached data first before calling the API when not forced.
@MainActor
final class UserDetailsViewModel: ObservableObject {

    /// The username of the GitHub user whose details this view model manages.
    private let username: String
    
    /// Represents the current loading state of the user details (idle, loading, success, error).
    @Published var userDetails: DataLoadableState<User> = .nothing
    
    // MARK: - Dependencies
    
    /// Service for fetching user data from GitHub API.
    private let apiService: GitHubAPIServiceType

    /// Local cache for storing user data persistently.
    private let localStorage: LocalStorageType

    /// Initializes the view model with required dependencies.
    /// - Parameters:
    ///   - username: The GitHub username to fetch details for.
    ///   - apiService: A `GitHubAPIServiceType` implementation for fetching user data from API. Defaults to the standard implementation.
    ///   - localStorage: A `LocalStorageType` implementation for persisting data locally. Defaults to the standard local storage client.
    init(
        username: String,
        apiService: GitHubAPIServiceType = GitHubAPIFactory.makeDefault(),
        localStorage: LocalStorageType = LocalStorageFactory.makeDefault()
    ) {
        self.username = username
        self.apiService = apiService
        self.localStorage = localStorage
    }

    /// Fetches the user details either from cache or via API.
    /// - Parameter forced: Whether to ignore cache and force fetch from API.
    func refresh(forced: Bool) async {
        // Skip reload if not forced and user details already exist
        if !forced, userDetails.data != nil { return }
        
        // Avoid reloading if a previous request is still in progress
        if userDetails.isLoading { return }

        if !forced {
            // Attempt to load user details from local cache first
            let user = await localStorage.fetchUser(username: username)
            // If cached user exists and contains detailed information, use it
            if let user, user.isDetails {
                userDetails = .success(data: user)
                return
            }
        }

        // Show loading state while preserving any existing data
        userDetails = .loading(data: userDetails.data)

        do {
            // Fetch fresh user details from the API
            let user = try await apiService.fetchUserDetail(username: username)
            // Update UI state with fetched data
            userDetails = .success(data: user)
            // Save new data to local storage for future offline use
            await localStorage.updateUser(user)
        } catch {
            // Handle API failure and reflect in UI state
            userDetails = .error
        }
    }
}
