//
//  MockLocalStorage.swift
//  GitProfileTests
//
//  Created by Tien Nguyen on 16/6/25.
//

import GitProfileServices

final class MockLocalStorage: LocalStorageType, @unchecked Sendable {
    
    // MARK: - Configurable mock data
    var cachedUsers: [User] = []
    
    // MARK: - Call flags
    var fetchAllCalled = false
    var replaceCalled = false
    var appendCalled = false
    var updateCalled = false
    var fetchUserCalled = false
    var clearCalled = false
    
    // MARK: - Call counters
    var fetchAllCallCount = 0
    var appendCallCount = 0
    var replaceCallCount = 0
    var clearCallCount = 0
    var fetchUserCallCount = 0
    var updateCallCount = 0

    // MARK: - LocalStorageType

    func fetchAllUsers() async -> [User] {
        fetchAllCalled = true
        fetchAllCallCount += 1
        return cachedUsers
    }

    func appendUsers(_ users: [User]) async {
        appendCalled = true
        appendCallCount += 1
        cachedUsers.append(contentsOf: users)
    }

    func replaceAll(with users: [User]) async {
        replaceCalled = true
        replaceCallCount += 1
        cachedUsers = users
    }

    func clearAllUsers() async {
        clearCalled = true
        clearCallCount += 1
    }

    func fetchUser(username: String) async -> User? {
        fetchUserCalled = true
        fetchUserCallCount += 1
        return cachedUsers.first { $0.login == username }
    }

    func updateUser(_ user: User) async {
        updateCalled = true
        updateCallCount += 1
        if let index = cachedUsers.firstIndex(where: { $0.id == user.id }) {
            cachedUsers[index] = user
        }
    }
}
