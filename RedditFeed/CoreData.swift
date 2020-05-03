// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import CoreData
import Foundation


// MARK: - FeedItem

@objc(FeedItem)
internal class FeedItem: NSManagedObject {

  @nonobjc internal static func fetchRequest(where predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, offset: Int = 0, limit: Int? = nil, batchSize: Int? = nil) -> NSFetchRequest<FeedItem> {
    return Self.fetchRequest(resultOf: FeedItem.self, where: predicate, sortDescriptors: sortDescriptors, offset: offset, limit: limit, batchSize: batchSize)
  }

  @nonobjc internal static func fetchObjects(where predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, offset: Int = 0, limit: Int? = nil, batchSize: Int? = nil, in context: NSManagedObjectContext) -> [FeedItem] {
    return Self.fetchObjects(FeedItem.self, where: predicate, sortDescriptors: sortDescriptors, offset: offset, limit: limit, batchSize: batchSize, in: context) ?? []
  }

  @discardableResult @nonobjc internal static func asyncFetchObjects(where predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil, offset: Int = 0, limit: Int? = nil, batchSize: Int? = nil, in context: NSManagedObjectContext, completion: @escaping ([FeedItem]?)->()) -> NSPersistentStoreAsynchronousResult? {
    return Self.asyncFetchObjects(FeedItem.self, where: predicate, sortDescriptors: sortDescriptors, offset: offset, limit: limit, batchSize: batchSize, in: context, completion: completion)
  }


  @NSManaged internal var author: String?
  @NSManaged internal var commentsCount: Int64
  @NSManaged internal var createdAt: Date?
  @NSManaged internal var identifier: String
  @NSManaged internal var postHint: String?
  @NSManaged internal var sortValue: Int32
  @NSManaged internal var thumbnail: URL?
  @NSManaged internal var title: String?
  @NSManaged internal var unread: Bool
  @NSManaged internal var url: URL?
}

