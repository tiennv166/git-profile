//
//  User.swift
//  GitProfileServices
//
//  Created by Tien Nguyen on 14/6/25.
//

import Foundation

/// Represents a GitHub user with basic and detailed profile information.
public struct User: Codable, Equatable, Identifiable, Sendable {
    
    // MARK: - Basic Info (Available from both list and detail APIs)

    public let id: Int
    public let login: String
    public let avatarUrl: String?
    public let htmlUrl: String?
    
    // MARK: - Detailed Info (Available only from the detail API)

    public let location: String?
    public let followers: Int?
    public let following: Int?
    public let bio: String?
    public let blog: String?
}

extension User {
    
    /// Indicates whether this user instance contains detailed profile information.
    /// Used to differentiate between summary info (from list) and full details (from detail API).
    public var isDetails: Bool {
        location != nil ||
        followers != nil ||
        following != nil ||
        blog != nil ||
        bio != nil
    }
}
