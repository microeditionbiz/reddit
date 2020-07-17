//
//  CoreDataPlaygroundTests.swift
//  CoreDataPlaygroundTests
//
//  Created by Pablo Ezequiel Romero Giovannoni on 12/01/2020.
//  Copyright © 2020 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import XCTest
@testable import CoreDataPlayground
import CoreData

class CoreDataPlaygroundTests: XCTestCase {

    var timestamp1: Date!
    var timestamp2: Date!
    
    override func setUp() {
        CoreDataManager.configure(containerName: "CoreDataPlayground")
        timestamp1 = Date()
        timestamp2 = Date().advanced(by: 1)
    }

    override func tearDown() {
        CoreDataManager.deleteAll()
    }

    // MARK: - Helpers
    
    fileprivate func createTwoEvents(in context: NSManagedObjectContext) {
        let event1 = Event.create(in: context)
        event1.stringNonOptionalProperty = "hey"
        event1.timestamp = timestamp1
        event1.save()
        
        let event2 = Event.create(in: context)
        event2.stringNonOptionalProperty = "hey"
        event2.timestamp = timestamp2
        event2.save()
    }
    
    // MARK: - View context
    
    func testCreateObjectsInViewContext() {
        let backgroundContext = CoreDataManager.newBackgroundContext()
        let context = CoreDataManager.viewContex
        createTwoEvents(in: context)
        XCTAssertEqual(Event.count(in: context), 2)
        XCTAssertEqual(Event.count(in: backgroundContext), 2)
    }
    
    func testTemporaryObjects() {
        let context = CoreDataManager.viewContex
        let event1 = Event.createTemporary()
        event1.timestamp = timestamp1
            
        let event2 = Event.createTemporary()
        event2.timestamp = timestamp2
        
        XCTAssertTrue(event1.isTemporary)
        XCTAssertTrue(event2.isTemporary)
        XCTAssertTrue(Event.isEmpty(in: context))
        
        event1.insert(in: context)
        XCTAssertFalse(event1.isTemporary)
        XCTAssertFalse(Event.isEmpty(in: context))
    }
    
    func testFetchObjectsInViewContext() {
        let context = CoreDataManager.viewContex
        createTwoEvents(in: context)
        let events = Event.fetchObjects(in: context)
        XCTAssertEqual(events?.count, 2)
    }
    
    func testFetchOneObjectInViewContext() {
        let context = CoreDataManager.viewContex
        createTwoEvents(in: context)
        let event = Event.fetchObject(where: NSPredicate(format: "timestamp = %@", timestamp1 as NSDate), in: context)
    
        XCTAssertNotNil(event)
        XCTAssertEqual(event?.timestamp, timestamp1)
    }
    
    // MARK: - Delete
    
    func testBatchDelete() {
        CoreDataManager.performAndWaitBackgroundTask { context in
            createTwoEvents(in: context)
        }
      
        let event1Predicate = NSPredicate(format: "timestamp = %@", timestamp1 as NSDate)
        
        CoreDataManager.performAndWaitBackgroundTask { context in
            CoreDataManager.batchDelete(Event.self, where: event1Predicate, in: context)
        }
        
        let context = CoreDataManager.viewContex
        let event1 = Event.fetchObject(where: event1Predicate, in: context)
        XCTAssertNil(event1)

        let event2 = Event.fetchObject(where: NSPredicate(format: "timestamp = %@", timestamp2 as NSDate), in: context)
        XCTAssertNotNil(event2)
        XCTAssertEqual(event2?.timestamp, timestamp2)
        
        XCTAssertEqual(Event.count(in: context), 1)
    }
 
    // MARK: - Background context
    
    func testPerfomAndWaitCreateObjectInBackgroundContext() {
        let promise = expectation(description: "Events created")
        
        DispatchQueue.global(qos: .background).async {
            CoreDataManager.performAndWaitBackgroundTask { context in
                self.createTwoEvents(in: context)
                XCTAssertEqual(Event.count(in: context), 2)
            }
            
            DispatchQueue.main.async {
                XCTAssertEqual(Event.count(in: CoreDataManager.viewContex), 2)
                promise.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testPerfomCreateObjectInBackgroundContext() {
        let promise = expectation(description: "Events created")
        
        DispatchQueue.global(qos: .background).async {
            CoreDataManager.performBackgroundTask { context in
                self.createTwoEvents(in: context)
                XCTAssertEqual(Event.count(in: context), 2)
           
                DispatchQueue.main.async {
                    XCTAssertEqual(Event.count(in: CoreDataManager.viewContex), 2)
                    promise.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // MARK: - Async fetch
    
    func testAsyncFetch() {
        let context = CoreDataManager.viewContex
        createTwoEvents(in: context)
        
        let promise = expectation(description: "Events fetched")
        
        DispatchQueue.global(qos: .background).async {
            let backgroundContext = CoreDataManager.newBackgroundContext()
            Event.asyncFetchObjects(in: backgroundContext) { events in
                XCTAssertEqual(events?.count, 2)
                
                DispatchQueue.main.async {
                    XCTAssertEqual(Event.count(in: CoreDataManager.viewContex), 2)
                    promise.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
}
