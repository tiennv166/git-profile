//
//  GitHubAPIServiceType.swift
//  GitProfileServices
//
//  Created by Tien Nguyen on 14/6/25.
//

import Foundation

// MARK: - public interface GitHubAPIServiceType

/// A protocol that defines methods for interacting with the GitHub API.
public protocol GitHubAPIServiceType: Sendable {
    /// Fetches a list of GitHub users starting after the given user ID.
    ///
    /// - Parameters:
    ///   - since: The ID of the last user seen. The next page will start after this ID.
    ///   - perPage: The number of users to fetch per request.
    /// - Returns: An array of `User` objects.
    /// - Throws: An error if the request fails or data cannot be decoded.
    func fetchUsers(since: Int, perPage: Int) async throws -> [User]

    /// Fetches detailed information for a specific GitHub user.
    ///
    /// - Parameter username: The GitHub username to fetch details for.
    /// - Returns: A `User` object with full profile information.
    /// - Throws: An error if the request fails or data cannot be decoded.
    func fetchUserDetail(username: String) async throws -> User
}

public extension GitHubAPIServiceType {
    /// Convenience method to fetch users with a default value of `perPage = 20`.
    ///
    /// - Parameter since: The ID of the last user seen.
    /// - Returns: An array of `User` objects.
    /// - Throws: An error if the request fails or data cannot be decoded.
    func fetchUsers(since: Int) async throws -> [User] {
        try await fetchUsers(since: since, perPage: 20)
    }
}

// MARK: - GitHubAPIFactory

/// A factory that creates instances conforming to `GitHubAPIServiceType`.
public enum GitHubAPIFactory {
    /// Creates the default implementation of `GitHubAPIServiceType`.
    ///
    /// - Returns: A `GitHubAPIService` instance.
    public static func makeDefault() -> GitHubAPIServiceType {
        GitHubAPIService()
    }
}
