//
//  GitHubRequest.swift
//  GitProfileServices
//
//  Created by Tien Nguyen on 14/6/25.
//

internal import APIKit
import Foundation

// MARK: Base GitHubRequest

protocol GitHubRequest: Request {}

extension GitHubRequest {
    var baseURL: URL {
        guard let url = URL(string: "https://api.github.com") else {
            fatalError("Invalid base URL.")
        }
        return url
    }
    
    var headerFields: [String: String] {
        ["Content-Type": "application/json; charset=utf-8"]
    }
    
    var method: HTTPMethod { .get }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response where Response: Decodable {
        let data = try JSONSerialization.data(withJSONObject: object)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(Response.self, from: data)
    }
}
