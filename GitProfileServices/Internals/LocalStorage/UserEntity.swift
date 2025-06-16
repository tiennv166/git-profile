//
//  UserEntity.swift
//  GitProfileServices
//
//  Created by Tien Nguyen on 16/6/25.
//

import Foundation
import CoreData

final class UserEntity: NSManagedObject {}

extension UserEntity {
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<UserEntity> {
        NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }
    
    @NSManaged var id: NSNumber
    @NSManaged var login: String
    @NSManaged var avatarUrl: String?
    @NSManaged var htmlUrl: String?
    @NSManaged var location: String?
    @NSManaged var followers: NSNumber?
    @NSManaged var following: NSNumber?
    @NSManaged var bio: String?
    @NSManaged var blog: String?
}

extension UserEntity: Identifiable {}

extension UserEntity {
    /// Converts a `UserEntity` (Core Data) to a regular `User` model.
    var toUser: User? {
        User(
            id: id.intValue,
            login: login,
            avatarUrl: avatarUrl,
            htmlUrl: htmlUrl,
            location: location,
            followers: followers?.intValue,
            following: following?.intValue,
            bio: bio,
            blog: blog
        )
    }
}
