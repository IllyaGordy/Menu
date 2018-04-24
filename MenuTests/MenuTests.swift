//
//  MenuTests.swift
//  MenuTests
//
//  Created by Illya Gordiyenko on 2018-04-16.
//  Copyright © 2018 Illya Gordiyenko. All rights reserved.
//

import XCTest
import CoreData

@testable import Menu

class MenuTests: XCTestCase {
    
    var menuManager: MenuManager!
    
    override func setUp() {
        super.setUp()
        
        // Create mock data
        initMock()
        menuManager = MenuManager(container: mockPersistantContainer)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextSaved(notification:)),
                                               name: NSNotification.Name.NSManagedObjectContextDidSave,
                                               object: nil)
    }
    
    override func tearDown() {

        flushData()
        super.tearDown()
    }
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))] )!
        return managedObjectModel
    }()
    
    lazy var mockPersistantContainer: NSPersistentContainer = {
        
        // Usually the default managedObjectModel would be in the file but for tests it cannot find it, so need to explicitly set it
        let container = NSPersistentContainer(name: "Menu", managedObjectModel: self.managedObjectModel)
        
        // Init the description and set it for NSInMemoryStoreType since we do not want to to be persistent for the test env
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false // Make is simpler in test env
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            // Check if the data store is in memory
            precondition(description.type == NSInMemoryStoreType)
            
            // Check if creating container wrong
            if let error = error {
                fatalError("Create an in-mem coordinate failed \(error)")
            }
            
        }
        
        return container
    }()
    
    func initMock() {
        
        func insertGroup(name: String, imagePath: String) -> Group? {
            
            let obj = NSEntityDescription.insertNewObject(forEntityName: Entities.Group.rawValue, into: mockPersistantContainer.viewContext)
            
            obj.setValue(name, forKey: GroupAttributes.Name.rawValue)
            obj.setValue(imagePath, forKey: GroupAttributes.ImagePath.rawValue)
            
            return obj as? Group
        }
        
        _ = insertGroup(name: "1", imagePath: "123")
        _ = insertGroup(name: "2", imagePath: "123")
        _ = insertGroup(name: "3", imagePath: "123")
        _ = insertGroup(name: "4", imagePath: "123")
        _ = insertGroup(name: "5", imagePath: "123")
        
        do {
            try mockPersistantContainer.viewContext.save()
        } catch {
            print("create fakes error \(error)")
        }
        
        
    }
    
    func flushData() {
        
        // TODO: repeat for the other entity as well
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: Entities.Group.rawValue)
        let objs = try! mockPersistantContainer.viewContext.fetch(fetchRequest)
        
        for case let obj as NSManagedObject in objs {
            mockPersistantContainer.viewContext.delete(obj)
        }
        
        try! mockPersistantContainer.viewContext.save()
    }
    
    // MARK: TESTS
    
    // General testing cases from the spec:
    // 1. insertGroup() -> should return Group
    // 2. fetchGroups() -> should return correct number of Groups
    // 3. remove() -> should remove an item from database
    // 4. save() -> should call NSManagedContext.save()
    // 5. TODO insertItem() -> should return Item
    // 6. TODO fetchItems() -> should return correct number of Groups
    // 7. TODO updateGroup() -> should return newly updated Group
    
    // Test 1 - insertGroup
    func test_create_group() {
        
        // Given the name & status
        let name = "group1"
        let imagePath = "123"
        
        // when add todo
        let todo = menuManager.insertGroup(name: name, imagePath: imagePath)
        
        // Assert: return todo item
        XCTAssertNotNil(todo)
    }
    
    // Test 2 - fetchGroups()
    func test_fetch_all_todo() {
        
        // when fetch
        let results = menuManager.fetchGroups()
        
        // Assert return five todo items
        XCTAssertEqual(results.count, 5)
    }
    
    // convenience methond
    func numberOfItemsPersistentStore(type: Entities) -> Int {
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: type.rawValue)
        let result = try! mockPersistantContainer.viewContext.fetch(request)
        return result.count
    }
    
    // Test 3 - remove()
    func test_remove_todo() {
        
        // Given an item in persistent store
        let items = menuManager.fetchGroups()
        let item = items[0]
        
        let numberOfItems = items.count
        
        // When removing an item
        menuManager.remove(objectID: item.objectID)
        menuManager.save()
        
        // Assert number of item-1
        XCTAssertEqual(numberOfItemsPersistentStore(type: Entities.Group), numberOfItems - 1)
    }
    
    // Test 4 - save()
    // Note this requires the NSManagedObjectContextDidSave notification update
    func test_save() {
        
        // give a group item
        let name = "group1"
        let imagePath = "123"
        
        
        // Expectation patter
        // test skill for testing asynchronous methods. We setup an expection, and wait for the expections to be fulfilled in a time slot
        let expect = expectation(description: "Context Saved")
        
        waitForSavedNotification { (notification) in
            expect.fulfill()
        }
        
        _ = menuManager.insertGroup(name: name, imagePath: imagePath)
        
        // When save
        menuManager.save()
        
        // Assert save is called via notification (wait)
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func contextSaved(notification: Notification) {
        saveNotificationCompleteHandler?(notification)
    }
    
    var saveNotificationCompleteHandler: ((Notification) -> ())?
    
    func waitForSavedNotification(completeHandler: @escaping ((Notification) -> ()) ) {
        saveNotificationCompleteHandler = completeHandler
    }
    
}
