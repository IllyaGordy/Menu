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
    
    func updateGroup(group: Group, name: String?, imagePath: String?) -> Group? {
        
        if let name = name {
            group.name = name
        }
        
        if let imagePath = imagePath {
            group.imagePath = imagePath
        }
        
        return group
    }
    
    func insertItem(into group:Group, name: String, detail: String, imagePath: String, price: Double) -> Item? {
        
        let item = Item(context: persistentContainer.viewContext)
        item.name = name
        item.detail = detail
        item.imagePath = imagePath
        item.price = price
        item.group = group
        
        group.addToItems(item)
        
        return item
    }
    
    func updateItem(item: Item, name: String?, detail: String?, imagePath: String?, price: Double?) -> Item? {
        
        if let name = name {
            item.name = name
        }
        
        if let detail = detail {
            item.detail = detail
        }
        
        if let imagePath = imagePath {
            item.imagePath = imagePath
        }
        
        if let price = price {
            item.price = price
        }
        
        return item
    }
    
    // TODO: refactor to take in a parameter instead of a black state
    func fetchGroups() -> [Group] {
        let request:NSFetchRequest<Group> = Group.fetchRequest()
        let results = try? persistentContainer.viewContext.fetch(request)
        
        return results ?? [Group]()
    }
    
    func fetchItems(from group:Group) -> [Item] {
        let request:NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "group == %@", group)
        let results = try? persistentContainer.viewContext.fetch(request)
        
        return results ?? [Item]()
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
        }else if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                print("Save error \(error)")
            }
        }
    }
}
