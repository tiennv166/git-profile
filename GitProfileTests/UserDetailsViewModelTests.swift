//
//  UserDetailsViewModelTests.swift
//  GitProfile
//
//  Created by Tien Nguyen on 17/6/25.
//

import XCTest
import GitProfileServices
@testable import GitProfile

final class UserDetailsViewModelTests: XCTestCase {
    
    func testUsesCachedUserIfAvailableAndIsDetailed() async {
        let username = "octocat"
        let cached = User.mock(id: 1, login: username, isDetailed: true)
        
        let storage = MockLocalStorage()
        storage.cachedUsers = [cached]
        
        let api = MockAPIService()
        let vm = await UserDetailsViewModel(username: username, apiService: api, localStorage: storage)
        
        await vm.refresh(forced: false)
        
        await MainActor.run {
            XCTAssertEqual(vm.userDetails.data, cached)
            XCTAssertFalse(api.fetchDetailCalled)
        }
    }

    func testFetchesUserIfNotDetailedInCache() async {
        let username = "devcat"
        let cached = User.mock(id: 2, login: username, isDetailed: false)
        let fetched = User.mock(id: 2, login: username, isDetailed: true)
        
        let storage = MockLocalStorage()
        storage.cachedUsers = [cached]
        
        let api = MockAPIService()
        api.userDetailToReturn = fetched
        
        let vm = await UserDetailsViewModel(username: username, apiService: api, localStorage: storage)
        await vm.refresh(forced: false)
        
        await MainActor.run {
            XCTAssertTrue(api.fetchDetailCalled)
            XCTAssertEqual(vm.userDetails.data, fetched)
            XCTAssertTrue(storage.updateCalled)
        }
    }

    func testForcedRefreshIgnoresCache() async {
        let username = "hubber"
        let cached = User.mock(id: 99, login: username, isDetailed: true)
        let fetched = User.mock(id: 123, login: username, isDetailed: true)
        
        let storage = MockLocalStorage()
        storage.cachedUsers = [cached]
        
        let api = MockAPIService()
        api.userDetailToReturn = fetched
        
        let vm = await UserDetailsViewModel(username: username, apiService: api, localStorage: storage)
        await vm.refresh(forced: true)
        
        await MainActor.run {
            XCTAssertTrue(api.fetchDetailCalled)
            XCTAssertEqual(vm.userDetails.data, fetched)
        }
    }

    func testHandlesErrorGracefully() async {
        let username = "ghost"
        
        let api = MockAPIService()
        api.shouldThrow = true
        let storage = MockLocalStorage()
        
        let vm = await UserDetailsViewModel(username: username, apiService: api, localStorage: storage)
        await vm.refresh(forced: true)
        
        await MainActor.run {
            XCTAssertEqual(vm.userDetails, .error)
        }
    }
    
    func testConcurrentForcedRefreshOnlyFetchesOnce() async {
        let username = "singleCall"
        let fetched = User.mock(id: 100, login: username, isDetailed: true)

        let api = MockAPIService()
        api.userDetailToReturn = fetched

        let storage = MockLocalStorage()
        
        let vm = await UserDetailsViewModel(username: username, apiService: api, localStorage: storage)

        // Run multiple refresh(forced: true) calls concurrently
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<5 {
                group.addTask {
                    await vm.refresh(forced: true)
                }
            }
        }

        await MainActor.run {
            XCTAssertEqual(vm.userDetails.data, fetched)
            XCTAssertEqual(api.fetchDetailCallCount, 1, "API should be called only once despite concurrent refreshes")
        }
    }
}
