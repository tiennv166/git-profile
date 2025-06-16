//
//  UserListViewModelTests.swift
//  GitProfileTests
//
//  Created by Tien Nguyen on 16/6/25.
//

import XCTest
import GitProfileServices
@testable import GitProfile

final class UserListViewModelTests: XCTestCase {
    
    func testRefreshUsesCachedUsersIfAvailable() async {
        let api = MockAPIService()
        let storage = MockLocalStorage()
        let cachedUsers = [User.mock(id: 1)]
        storage.cachedUsers = cachedUsers
        
        let vm = await UserListViewModel(apiService: api, localStorage: storage)
        await vm.refresh(forced: false)
        
        await MainActor.run {
            XCTAssertEqual(vm.users.data, cachedUsers)
            XCTAssertFalse(api.fetchCalled)
        }
    }
    
    func testRefreshForcedWithEmptyResponse() async {
        let api = MockAPIService()
        api.usersToReturn = [] // simulate empty response
        let storage = MockLocalStorage()
        
        let vm = await UserListViewModel(apiService: api, localStorage: storage)
        await vm.refresh(forced: true)
        
        await MainActor.run {
            XCTAssertEqual(vm.users, .success(data: []))
            XCTAssertTrue(api.fetchCalled)
            XCTAssertTrue(storage.replaceCalled)
        }
    }

    func testRefreshFetchesFromAPIIfNoCache() async {
        let api = MockAPIService()
        let usersToReturn = [User.mock(id: 2)]
        api.usersToReturn = usersToReturn
        
        let storage = MockLocalStorage()
        storage.cachedUsers = []
        
        let vm = await UserListViewModel(apiService: api, localStorage: storage)
        await vm.refresh(forced: false)
        
        await MainActor.run {
            XCTAssertTrue(api.fetchCalled)
            XCTAssertTrue(storage.replaceCalled)
            XCTAssertEqual(vm.users.data, usersToReturn)
        }
    }
    
    func testRefreshHandlesErrorGracefully() async {
        let api = MockAPIService()
        api.shouldThrow = true
        let storage = MockLocalStorage()
        
        let vm = await UserListViewModel(apiService: api, localStorage: storage)
        await vm.refresh(forced: true)
        
        await MainActor.run {
            XCTAssertEqual(vm.users, .error)
        }
    }
    
    func testLoadMoreAppendsUsers() async {
        let api = MockAPIService()
        api.usersToReturn = [User.mock(id: 3)]
        let storage = MockLocalStorage()
        
        let vm = await UserListViewModel(apiService: api, localStorage: storage)
        let existing = User.mock(id: 2)
        await MainActor.run {
            vm.users = .success(data: [existing])
        }
        
        await vm.loadMoreIfNeeded(currentUser: existing)
        
        // Wait until async task completes
        await vm.activeLoadTask?.value
        
        await MainActor.run {
            XCTAssertTrue(storage.appendCalled)
            XCTAssertTrue(vm.users.data?.contains { $0.id == 3 } ?? false)
        }
    }
    
    func testLoadMoreHandlesErrorGracefully() async {
        let api = MockAPIService()
        api.shouldThrow = true // Simulate error during load more

        let storage = MockLocalStorage()
        let vm = await UserListViewModel(apiService: api, localStorage: storage)

        // Setup existing user list
        let existing = User.mock(id: 10)
        await MainActor.run {
            vm.users = .success(data: [existing])
        }

        // Trigger load more
        await vm.loadMoreIfNeeded(currentUser: existing)

        // Wait for async task to complete
        await vm.activeLoadTask?.value

        await MainActor.run {
            XCTAssertEqual(vm.users, .success(data: [existing]), "Data should remain unchanged on error")
            XCTAssertFalse(storage.appendCalled, "appendUsers should not be called on error")
            XCTAssertEqual(api.fetchCallCount, 1, "API should be called once even on error")
        }
    }
    
    func testRefreshForcedBypassesCache() async {
        let api = MockAPIService()
        let usersToReturn = [User.mock(id: 42)]
        api.usersToReturn = usersToReturn
        let storage = MockLocalStorage()
        storage.cachedUsers = [User.mock(id: 99)]
        
        let vm = await UserListViewModel(apiService: api, localStorage: storage)
        await vm.refresh(forced: true)
        
        await MainActor.run {
            XCTAssertTrue(api.fetchCalled)
            XCTAssertEqual(vm.users.data, usersToReturn)
        }
    }
    
    func testLoadMoreDoesNotTriggerWhenAlreadyLoading() async {
        let api = MockAPIService()
        api.usersToReturn = [User.mock(id: 4)]
        let storage = MockLocalStorage()
        
        let vm = await UserListViewModel(apiService: api, localStorage: storage)
        
        let existing = User.mock(id: 10)
        await MainActor.run {
            vm.users = .loading(data: [existing]) // simulate already loading
        }
        
        await vm.loadMoreIfNeeded(currentUser: existing)
        
        await MainActor.run {
            XCTAssertFalse(storage.appendCalled)
            XCTAssertFalse(api.fetchCalled)
        }
    }
    
    func testLoadMoreDoesNotTriggerIfNotAtEnd() async {
        let api = MockAPIService()
        api.usersToReturn = [User.mock(id: 4)]
        let storage = MockLocalStorage()
        
        let vm = await UserListViewModel(apiService: api, localStorage: storage)
        let currentList = [User.mock(id: 1), User.mock(id: 2), User.mock(id: 3)]
        await MainActor.run {
            vm.users = .success(data: currentList)
        }
        
        await vm.loadMoreIfNeeded(currentUser: User.mock(id: 2)) // not last item
        
        await MainActor.run {
            XCTAssertFalse(storage.appendCalled)
            XCTAssertFalse(api.fetchCalled)
        }
    }
    
    func testMultipleForcedRefreshCallsShouldOnlyTriggerOneRequest() async {
        let api = MockAPIService()
        api.usersToReturn = [User.mock(id: 1)]
        
        let storage = MockLocalStorage()
        let vm = await UserListViewModel(apiService: api, localStorage: storage)

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<5 {
                group.addTask {
                    await vm.refresh(forced: true)
                }
            }
        }

        await MainActor.run {
            XCTAssertEqual(api.fetchCallCount, 1, "Only one API request should be made during concurrent forced refresh calls")
            XCTAssertEqual(storage.replaceCallCount, 1, "Storage replaceAll should only be called once")
        }
    }
    
    func testMultipleLoadMoreCallsShouldOnlyTriggerOneRequest() async {
        let api = MockAPIService()
        api.usersToReturn = [User.mock(id: 6)]
        
        let storage = MockLocalStorage()
        let vm = await UserListViewModel(apiService: api, localStorage: storage)

        // Setup existing list to enable loadMore condition
        await MainActor.run {
            vm.users = .success(data: [User.mock(id: 5)])
        }

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<5 {
                group.addTask {
                    await vm.loadMoreIfNeeded(currentUser: User.mock(id: 5))
                }
            }
        }

        await vm.activeLoadTask?.value

        await MainActor.run {
            XCTAssertEqual(api.fetchCallCount, 1, "Only one API request should be made during concurrent loadMore calls")
            XCTAssertEqual(storage.appendCallCount, 1, "Storage appendUsers should only be called once")
        }
    }
}
