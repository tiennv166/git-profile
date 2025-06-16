//
//  LocalStorageClientTests.swift
//  GitProfile
//
//  Created by Tien Nguyen on 16/6/25.
//

import XCTest
import CoreData
@testable import GitProfileServices

final class LocalStorageClientTests: XCTestCase {
    
    private var storage: LocalStorageClient!
    
    override func setUp() async throws {
        try await super.setUp()
        storage = LocalStorageClient()
        await storage.clearAllUsers()
    }
    
    override func tearDown() async throws {
        await storage.clearAllUsers()
        storage = nil
        try await super.tearDown()
    }
    
    // MARK: - Tests
    
    func testStoreAndFetchUsers() async {
        let users = mockUsers()
        await storage.appendUsers(users)
        
        let fetched = await storage.fetchAllUsers()
        XCTAssertEqual(fetched.count, users.count)
        XCTAssertEqual(fetched.map(\.id), users.map(\.id).sorted())
    }
    
    func testFetchAllUsersReturnsSortedById() async {
        let users = mockUsers()
        await storage.appendUsers(users)
        let fetched = await storage.fetchAllUsers()
        
        let ids = fetched.map(\.id)
        XCTAssertEqual(ids, [1, 7, 42], "Users should be sorted in ascending order by id")
    }
    
    func testClearUsers() async {
        await storage.appendUsers(mockUsers())
        await storage.clearAllUsers()
        
        let fetched = await storage.fetchAllUsers()
        XCTAssertTrue(fetched.isEmpty)
    }
    
    func testReplaceAllUsers() async {
        await storage.appendUsers([mockUsers()[0]])
        await storage.replaceAll(with: mockUsers())
        
        let fetched = await storage.fetchAllUsers()
        XCTAssertEqual(fetched.count, 3)
    }
    
    func testAppendShouldReplaceDuplicates() async {
        await storage.appendUsers([mockUsers()[0]])
        await storage.appendUsers(mockUsers()) // same ID as first
        
        let fetched = await storage.fetchAllUsers()
        XCTAssertEqual(fetched.count, 3)
    }
    
    func testFetchUserByUsername() async {
        let users = mockUsers()
        await storage.appendUsers(users)

        let fetched = await storage.fetchUser(username: "hubber")
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.login, "hubber")
        XCTAssertEqual(fetched?.id, 1)
    }
    
    func testFetchUserByUsernameReturnsNilIfNotFound() async {
        let users = mockUsers()
        await storage.appendUsers(users)

        let fetched = await storage.fetchUser(username: "nonexistent")
        XCTAssertNil(fetched, "Should return nil for a username that doesn't exist")
    }

    func testUpdateUserPersistsChanges() async {
        let users = mockUsers()
        await storage.appendUsers(users)

        // Modify bio and location for user "hubber"
        var updated = users.first(where: { $0.login == "hubber" })!
        updated = User(
            id: updated.id,
            login: updated.login,
            avatarUrl: updated.avatarUrl,
            htmlUrl: updated.htmlUrl,
            location: "San Francisco",
            followers: updated.followers,
            following: updated.following,
            bio: "Updated bio",
            blog: nil
        )

        await storage.updateUser(updated)
        let fetched = await storage.fetchUser(username: "hubber")

        XCTAssertEqual(fetched?.location, "San Francisco")
        XCTAssertEqual(fetched?.bio, "Updated bio")
    }
    
    // MARK: - Mocks
    
    private func mockUsers() -> [User] {
        [
            User(id: 42, login: "octocat", avatarUrl: nil, htmlUrl: nil, location: nil, followers: 1, following: 2, bio: nil, blog: nil),
            User(id: 1, login: "hubber", avatarUrl: nil, htmlUrl: nil, location: "NY", followers: 10, following: 5, bio: "dev", blog: nil),
            User(id: 7, login: "devcat", avatarUrl: nil, htmlUrl: nil, location: nil, followers: nil, following: nil, bio: nil, blog: nil)
        ]
    }
}
