//
//  MockAPIService.swift
//  GitProfileTests
//
//  Created by Tien Nguyen on 16/6/25.
//

import Foundation
import GitProfileServices

final class MockAPIService: GitHubAPIServiceType, @unchecked Sendable {
    
    // MARK: - Configurable mock data
    var usersToReturn: [User] = []
    var userDetailToReturn: User?
    var shouldThrow = false

    // MARK: - Call tracking
    var fetchCalled = false
    var fetchDetailCalled = false
    var fetchCallCount = 0
    var fetchDetailCallCount = 0
    
    // MARK: - GitHubAPIServiceType
    
    func fetchUsers(since: Int, perPage: Int) async throws -> [User] {
        fetchCalled = true
        fetchCallCount += 1
        if shouldThrow {
            throw URLError(.badServerResponse)
        }
        return usersToReturn
    }
    
    func fetchUserDetail(username: String) async throws -> User {
        fetchDetailCalled = true
        fetchDetailCallCount += 1
        if shouldThrow {
            throw URLError(.badServerResponse)
        }
        guard let userDetailToReturn else {
            throw URLError(.badServerResponse)
        }
        return userDetailToReturn
    }
}
