//
//  LocalStorageClient.swift
//  GitProfile
//
//  Created by Tien Nguyen on 16/6/25.
//

import CoreData
import Foundation

/// A concrete implementation of `LocalStorageType` using Core Data.
/// This class manages persistent storage of `User` objects.
final actor LocalStorageClient {
    
    // MARK: - Core Data Stack
    
    /// The main persistent container using the `CoreModels` data model.
    private lazy var persistentContainer: NSPersistentContainer = {
        let bundle = Bundle(for: type(of: self))
        guard
            let modelURL = bundle.url(forResource: "CoreModels", withExtension: "momd"),
            let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        else {
            fatalError("❌ Failed to locate or load Core Data model.")
        }
        
        let container = NSPersistentContainer(name: "CoreModels", managedObjectModel: managedObjectModel)
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("❌ Failed to load Core Data store: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return container
    }()
    
    /// A background context used for all operations within the actor.
    private lazy var context: NSManagedObjectContext = {
        let ctx = persistentContainer.newBackgroundContext()
        ctx.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        ctx.automaticallyMergesChangesFromParent = true
        return ctx
    }()
}

// MARK: - LocalStorageType

extension LocalStorageClient: LocalStorageType {
    
    /// Fetches all stored users, sorted by `id` ascending.
    func fetchAllUsers() async -> [User] {
        context.performAndWait {
            let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            do {
                let fetched = try context.fetch(request)
                return fetched.compactMap(\.toUser)
            } catch {
                debugPrint("⚠️ Failed to fetch users: \(error)")
                return []
            }
        }
    }
    
    /// Appends a list of users to storage.
    /// Existing users with the same `id` will be replaced.
    func appendUsers(_ users: [User]) async {
        guard !users.isEmpty else { return }
        
        context.performAndWait {
            // Collect IDs to check for duplicates
            let ids = users.map { NSNumber(value: $0.id) }
            
            // Fetch and delete existing entities with matching IDs
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id IN %@", ids)
            
            do {
                let existing = try context.fetch(fetchRequest)
                existing.forEach { context.delete($0) }
                
                // Insert new user entities
                for user in users {
                    let entity = UserEntity(context: context)
                    entity.id = NSNumber(value: user.id)
                    entity.login = user.login
                    entity.avatarUrl = user.avatarUrl
                    entity.htmlUrl = user.htmlUrl
                    entity.location = user.location
                    entity.followers = user.followers.map(NSNumber.init)
                    entity.following = user.following.map(NSNumber.init)
                    entity.bio = user.bio
                    entity.blog = user.blog
                }
                
                try context.save()
            } catch {
                debugPrint("⚠️ Failed to append users: \(error)")
            }
        }
    }
    
    /// Clears all existing users and replaces with a new list.
    func replaceAll(with users: [User]) async {
        await clearAllUsers()
        await appendUsers(users)
    }
    
    /// Deletes all stored users from persistent store.
    func clearAllUsers() async {
        context.performAndWait {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserEntity.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                debugPrint("⚠️ Failed to delete all users: \(error)")
            }
        }
    }
    
    /// Fetches a single user by username from local storage.
    /// - Parameter username: The username of the user to fetch.
    /// - Returns: A `User` if found, otherwise `nil`.
    func fetchUser(username: String) async -> User? {
        context.performAndWait {
            let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            request.predicate = NSPredicate(format: "login == %@", username)
            request.fetchLimit = 1
            do {
                return try context.fetch(request).first?.toUser
            } catch {
                debugPrint("⚠️ Failed to fetch user: \(error)")
                return nil
            }
        }
    }
    
    /// Updates an existing user in local storage with the new user data.
    /// - Parameter user: The updated user model to persist.
    /// If the user does not exist, this method does nothing.
    func updateUser(_ user: User) async {
        context.performAndWait {
            let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", user.id)
            request.fetchLimit = 1
            do {
                if let entity = try context.fetch(request).first {
                    entity.login = user.login
                    entity.avatarUrl = user.avatarUrl
                    entity.htmlUrl = user.htmlUrl
                    entity.location = user.location
                    entity.followers = user.followers.map(NSNumber.init)
                    entity.following = user.following.map(NSNumber.init)
                    entity.bio = user.bio
                    entity.blog = user.blog
                    try context.save()
                }
            } catch {
                debugPrint("⚠️ Failed to update user: \(error)")
            }
        }
    }
}
