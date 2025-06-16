//
//  GitHubAPIService.swift
//  GitProfile
//
//  Created by Tien Nguyen on 14/6/25.
//

@preconcurrency internal import APIKit
import Foundation

/// A service responsible for communicating with GitHub's REST API.
/// Provides methods to fetch user lists and detailed user profiles.
///
/// You can inject a custom `Session` for testing or use the default configuration.
final class GitHubAPIService: GitHubAPIServiceType {

    /// The APIKit session used to perform requests.
    private let session: Session

    /// Creates an instance of `GitHubAPIService`.
    ///
    /// - Parameter session: A custom `Session` instance for performing requests.
    ///                      Defaults to a shared session with recommended configuration.
    init(session: Session = GitHubAPIService.defaultSession) {
        self.session = session
    }

    /// Fetches a list of GitHub users starting from a given user ID.
    ///
    /// - Parameters:
    ///   - since: The ID of the last user seen. The response will include users after this ID.
    ///   - perPage: The number of users to fetch per page.
    /// - Returns: An array of `User` objects.
    /// - Throws: An error if the request fails or decoding fails.
    func fetchUsers(since: Int, perPage: Int) async throws -> [User] {
        try await session.response(for: FetchUsersRequest(since: since, perPage: perPage))
    }

    /// Fetches detailed information for a specific GitHub user.
    ///
    /// - Parameter username: The username of the user to retrieve details for.
    /// - Returns: A `User` object with detailed information.
    /// - Throws: An error if the request fails or decoding fails.
    func fetchUserDetail(username: String) async throws -> User {
        try await session.response(for: FetchUserDetailRequest(username: username))
    }
}

private extension GitHubAPIService {
    /// The default APIKit session configuration used by the service.
    ///
    /// - Uses a default URLSession configuration with a 60-second timeout.
    /// - The callback queue is set to`sessionQueue`, not the main queue.
    static var defaultSession: Session {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        return Session(
            adapter: URLSessionAdapter(configuration: configuration),
            callbackQueue: .sessionQueue
        )
    }
}

