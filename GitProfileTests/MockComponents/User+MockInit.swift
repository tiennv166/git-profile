//
//  User+MockInit.swift
//  GitProfile
//
//  Created by Tien Nguyen on 16/6/25.
//

import Foundation
@testable import GitProfileServices

extension User {
    static func mock(
        id: Int = 1,
        login: String = "mock_user",
        avatarUrl: String? = "https://example.com/avatar.png",
        htmlUrl: String? = "https://github.com/mock_user",
        location: String? = "Mockville",
        followers: Int? = 42,
        following: Int? = 99,
        bio: String? = "Just a mock user.",
        blog: String? = "https://example.com/mockblog",
        isDetailed: Bool = true,
    ) -> User {
        if isDetailed {
            return User(
                id: id,
                login: login,
                avatarUrl: avatarUrl,
                htmlUrl: htmlUrl,
                location: location ?? "Mockville",
                followers: followers,
                following: following,
                bio: bio,
                blog: blog
            )
        } else {
            return User(
                id: id,
                login: login,
                avatarUrl: avatarUrl,
                htmlUrl: htmlUrl,
                location: nil,
                followers: nil,
                following: nil,
                bio: nil,
                blog: nil
            )
        }
    }
}
