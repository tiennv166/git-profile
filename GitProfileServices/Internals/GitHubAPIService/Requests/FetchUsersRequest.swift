//
//  FetchUsersRequest.swift
//  GitProfileServices
//
//  Created by Tien Nguyen on 14/6/25.
//

struct FetchUsersRequest: GitHubRequest {
    
    typealias Response = [User]
    
    let since: Int
    let perPage: Int
    
    var path: String { "/users" }
    
    var parameters: Any? {
        [
            "since": since,
            "per_page": perPage
        ]
    }
}
