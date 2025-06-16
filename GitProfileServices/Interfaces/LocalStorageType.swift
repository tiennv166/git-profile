//
//  LocalStorageType.swift
//  GitProfileServices
//
//  Created by Tien Nguyen on 16/6/25.
//

import Foundation

// MARK: - public interface LocalStorageType

/// A protocol defining operations for storing GitHub users locally.
public protocol LocalStorageType: Sendable {
    
    /// Returns all users currently stored locally.
    func fetchAllUsers() async -> [User]
    
    /// Fetches a user by their GitHub username.
    /// - Parameter username: The login/username of the user to fetch.
    func fetchUser(username: String) async -> User?

    /// Appends a list of users to the existing local data.
    /// - Parameter users: The users to append.
    func appendUsers(_ users: [User]) async

    /// Updates an existing user in local storage, matched by ID.
    /// - Parameter user: The user data to update.
    func updateUser(_ user: User) async

    /// Replaces all existing users with the given list.
    /// - Parameter users: The new list of users to store.
    func replaceAll(with users: [User]) async

    /// Removes all users from local storage.
    func clearAllUsers() async
}

// MARK: - LocalStorageFactory

/// A factory responsible for creating instances of `LocalStorageType`.
/// This allows for abstraction and easier dependency injection.
public enum LocalStorageFactory {

    /// Returns the default implementation of `LocalStorageType`.
    /// Internally uses `LocalStorageClient` which handles Core Data operations.
    public static func makeDefault() -> LocalStorageType {
        LocalStorageClient()
    }
}
