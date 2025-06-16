//
//  UserListViewModel.swift
//  GitProfile
//
//  Created by Tien Nguyen on 14/6/25.
//

import Foundation
import GitProfileServices

/// ViewModel responsible for managing the list of GitHub users,
/// including initial loading, pagination, and refresh logic.
@MainActor
final class UserListViewModel: ObservableObject {

    /// The current state of the user list (loading, loaded, error, etc.).
    @Published var users: DataLoadableState<[User]> = .nothing

    /// Indicates whether the view is currently loading additional users (pagination).
    @Published var isLoadingMore = false

    private var loadMoreTask: Task<Void, Never>?
    private var isLastPage = false
    
    /// Dependencies
    private let apiService: GitHubAPIServiceType
    private let localStorage: LocalStorageType

    /// Initializes the view model with required dependencies.
    /// - Parameters:
    ///   - apiService: A `GitHubAPIServiceType` implementation for fetching user data from API. Defaults to the standard implementation.
    ///   - localStorage: A `LocalStorageType` implementation for persisting data locally. Defaults to the standard local storage client.
    init(
        apiService: GitHubAPIServiceType = GitHubAPIFactory.makeDefault(),
        localStorage: LocalStorageType = LocalStorageFactory.makeDefault()
    ) {
        self.apiService = apiService
        self.localStorage = localStorage
    }

    /// Refreshes the list of users, starting from the beginning.
    /// - Parameter forced: Whether to force reload even if data already exists.
    func refresh(forced: Bool) async {
        // Avoid reloading if not forced and data already exists
        if !forced, users.data != nil { return }
        // Don't reload if already loading
        if users.isLoading { return }

        // Cancel any ongoing load-more operation
        loadMoreTask?.cancel()
        
        // Reset pagination flag to start loading from the beginning
        isLastPage = false

        // If cached data exists and the refresh is not forced, use the cached data
        // On second app launch (or subsequent loads), prefer loading cached users first
        // to avoid unnecessary API calls if data already exists and reload is not forced
        if !forced {
            // Attempt to load cached users from local storage first
            let cached = await localStorage.fetchAllUsers()
            if !cached.isEmpty {
                users = .success(data: cached.uniqued())
                return
            }
        }

        // Show loading state, optionally preserving old data
        users = .loading(data: users.data)

        do {
            // Fetch page 1
            let fetched = try await apiService.fetchUsers(since: 0)
            // Update with unique users
            users = .success(data: fetched.uniqued())
            isLastPage = fetched.isEmpty
            // Updates local storage with the newly fetched users
            await localStorage.replaceAll(with: fetched)
        } catch {
            users = .error
        }
    }

    /// Loads the next page of users if needed, based on scroll position.
    /// - Parameter currentUser: The currently visible user triggering the load check.
    func loadMoreIfNeeded(currentUser user: User) {
        guard
            !users.isLoading,
            !isLoadingMore,
            !isLastPage,
            let current = users.data,
            current.last?.id == user.id // only load when reaching the end
        else {
            return
        }

        isLoadingMore = true

        loadMoreTask = Task {
            defer { isLoadingMore = false }

            do {
                // Fetch next page
                let fetched = try await apiService.fetchUsers(since: user.id)
                var newUsers = current
                newUsers.append(contentsOf: fetched)

                // Remove duplicates and update state
                users = .success(data: newUsers.uniqued())
                isLastPage = fetched.isEmpty
                
                // Appends newly fetched users to local storage
                await localStorage.appendUsers(fetched)
            } catch {
                // Silently fail, keep current state
            }
        }
    }
}

extension UserListViewModel {
    
    // Internal access for testing
    var activeLoadTask: Task<Void, Never>? { loadMoreTask }
}
