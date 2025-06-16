//
//  GitHubAPIServiceTests.swift
//  GitProfileServicesTests
//
//  Created by Tien Nguyen on 14/6/25.
//

import XCTest
import APIKit
@testable import GitProfileServices

final class GitHubAPIServiceTests: XCTestCase {
    
    // MARK: - Helpers
    
    private func makeServiceWithMockResponse(json: String, urlString: String, statusCode: Int = 200) throws -> GitHubAPIService {
        guard
            let data = json.data(using: .utf8),
            let url = URL(string: urlString),
            let response = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )
        else {
            throw URLError(.badURL)
        }
        
        let adapter = MockAPIKitAdapter(data: data, urlResponse: response)
        let session = Session(adapter: adapter)
        return GitHubAPIService(session: session)
    }
    
    // MARK: - fetchUsers tests
    
    func testFetchUsersReturnsSingleUser() async throws {
        let mockJSON = """
        [
          {
            "id": 1,
            "login": "octocat",
            "avatar_url": "https://avatars.githubusercontent.com/u/1?v=4",
            "html_url": "https://github.com/octocat"
          }
        ]
        """
        let service = try makeServiceWithMockResponse(
            json: mockJSON,
            urlString: "https://api.github.com/users"
        )
        
        let users = try await service.fetchUsers(since: 0, perPage: 1)
        
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users.first?.login, "octocat")
        XCTAssertEqual(users.first?.avatarUrl, "https://avatars.githubusercontent.com/u/1?v=4")
    }
    
    func testFetchUsersReturnsMultipleUsers() async throws {
        let mockJSON = """
        [
          {
            "id": 1,
            "login": "octocat",
            "avatar_url": "https://avatars.githubusercontent.com/u/1?v=4",
            "html_url": "https://github.com/octocat"
          },
          {
            "id": 2,
            "login": "hubber",
            "avatar_url": "https://avatars.githubusercontent.com/u/2?v=4",
            "html_url": "https://github.com/hubber",
            "location": "NY",
            "followers": 30,
            "following": 10
          },
          {
            "id": 3,
            "login": "devcat",
            "avatar_url": "https://avatars.githubusercontent.com/u/3?v=4",
            "html_url": "https://github.com/devcat",
            "followers": 5,
            "following": 8
          }
        ]
        """
        let service = try makeServiceWithMockResponse(
            json: mockJSON,
            urlString: "https://api.github.com/users"
        )
        
        let users = try await service.fetchUsers(since: 0, perPage: 3)
        
        XCTAssertEqual(users.count, 3)
        XCTAssertEqual(users[0].login, "octocat")
        XCTAssertEqual(users[1].login, "hubber")
        XCTAssertEqual(users[2].login, "devcat")
    }
    
    func testFetchUsersReturnsEmptyList() async throws {
        let emptyJSON = "[]"
        let service = try makeServiceWithMockResponse(
            json: emptyJSON,
            urlString: "https://api.github.com/users"
        )

        let users = try await service.fetchUsers(since: 0, perPage: 20)

        XCTAssertEqual(users.count, 0)
    }

    
    func testFetchUsersThrowsDecodingErrorOnInvalidJSON() async throws {
        let invalidJSON = "not json"
        let service = try makeServiceWithMockResponse(
            json: invalidJSON,
            urlString: "https://api.github.com/users"
        )
        
        do {
            _ = try await service.fetchUsers(since: 0, perPage: 2)
            XCTFail("Expected decoding to fail")
        } catch {
            if case let SessionTaskError.responseError(innerError) = error {
                XCTAssertNotNil(innerError.localizedDescription)
            } else {
                XCTFail("Expected SessionTaskError.responseError wrapping DecodingError, got: \(error)")
            }
        }
    }
    
    func testFetchUsersThrowsUnacceptableStatusCode() async throws {
        let service = try makeServiceWithMockResponse(
            json: "[]",
            urlString: "https://api.github.com/users", statusCode: 404
        )
        
        do {
            _ = try await service.fetchUsers(since: 0, perPage: 1)
            XCTFail("Expected unacceptableStatusCode error")
        } catch {
            if case let SessionTaskError.responseError(innerError) = error {
                if case let ResponseError.unacceptableStatusCode(code) = innerError {
                    XCTAssertEqual(code, 404)
                } else {
                    XCTFail("Expected ResponseError.unacceptableStatusCode, got: \(innerError)")
                }
            } else {
                XCTFail("Expected SessionTaskError.responseError, got: \(error)")
            }
        }
    }
    
    // MARK: - fetchUserDetail tests
    
    func testFetchUserDetailReturnsDecodedUser() async throws {
        let mockJSON = """
        {
          "id": 1,
          "login": "octocat",
          "avatar_url": "https://avatars.githubusercontent.com/u/1?v=4",
          "html_url": "https://github.com/octocat",
          "location": "San Francisco",
          "followers": 100,
          "following": 50
        }
        """
        let service = try makeServiceWithMockResponse(
            json: mockJSON,
            urlString: "https://api.github.com/users/octocat"
        )
        let user = try await service.fetchUserDetail(username: "octocat")
        
        XCTAssertEqual(user.login, "octocat")
        XCTAssertEqual(user.location, "San Francisco")
        XCTAssertEqual(user.followers, 100)
        XCTAssertEqual(user.following, 50)
    }
    
    func testFetchUserDetailThrowsDecodingErrorOnInvalidJSON() async throws {
        let invalidJSON = "not json"
        let service = try makeServiceWithMockResponse(
            json: invalidJSON,
            urlString: "https://api.github.com/users/octocat"
        )
        
        do {
            _ = try await service.fetchUserDetail(username: "octocat")
            XCTFail("Expected decoding to fail")
        } catch {
            if case let SessionTaskError.responseError(innerError) = error {
                XCTAssertNotNil(innerError.localizedDescription)
            } else {
                XCTFail("Expected SessionTaskError.error(DecodingError), got: \(error)")
            }
        }
    }
    
    func testFetchUserDetailReturnsUnacceptableStatusCode() async throws {
        let service = try makeServiceWithMockResponse(
            json: "{}",
            urlString: "https://api.github.com/users/octocat",
            statusCode: 404
        )
        
        do {
            _ = try await service.fetchUserDetail(username: "octocat")
            XCTFail("Expected unacceptableStatusCode error")
        } catch {
            if case let SessionTaskError.responseError(innerError) = error {
                if case let ResponseError.unacceptableStatusCode(code) = innerError {
                    XCTAssertEqual(code, 404)
                } else {
                    XCTFail("Expected ResponseError.unacceptableStatusCode, got: \(innerError)")
                }
            } else {
                XCTFail("Expected SessionTaskError.responseError, got: \(error)")
            }
        }
    }
}
