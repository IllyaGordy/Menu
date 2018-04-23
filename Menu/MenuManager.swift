//
//  MenuManager.swift
//  Menu
//
//  Created by Illya Gordiyenko on 2018-04-22.
//  Copyright © 2018 Illya Gordiyenko. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum Entities:String {
    case Group = "Group"
    case Item = "Item"
}

enum GroupAttributes:String {
    case ImagePath = "imagePath"
    case Name = "name"
}
class MenuManager {

    let persistentContainer: NSPersistentContainer!
    
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    convenience init() {
        
        // Use the default container for production env
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Cannot get shared app delegate")
        }
        
        self.init(container: appDelegate.persistentContainer)
    }
    
    // commit changes in the background thread instead of main thread
    lazy var backgroundContext: NSManagedObjectContext = {
        return self.persistentContainer.newBackgroundContext()
    }()
    
    // MARK: create, read, update, delete - CRUD
    func insertGroup(name: String, imagePath: String) -> Group? {
        guard let group = NSEntityDescription.insertNewObject(forEntityName: Entities.Group.rawValue, into: backgroundContext) as? Group else {
            return nil
        }
        
        group.name = name
        group.imagePath = imagePath
        
        return group
    }
    
    // TODO: refactor to take in a parameter instead of a black state
    func fetchGroups() -> [Group] {
        let request:NSFetchRequest<Group> = Group.fetchRequest()
        let results = try? persistentContainer.viewContext.fetch(request)
        
        return results ?? [Group]()
    }
    
    func remove(objectID: NSManagedObjectID) {
        let obj = backgroundContext.object(with: objectID)
        backgroundContext.delete(obj)
    }
    
    func save() {
        if backgroundContext.hasChanges {
            do {
                try backgroundContext.save()
            } catch {
                print("Save error \(error)")
            }
        }
    }
}
