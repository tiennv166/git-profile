//
//  FetchUserDetailRequest.swift
//  GitProfileServices
//
//  Created by Tien Nguyen on 14/6/25.
//

struct FetchUserDetailRequest: GitHubRequest {
    
    typealias Response = User
    
    let username: String
    
    var path: String { "/users/\(username)" }
}
