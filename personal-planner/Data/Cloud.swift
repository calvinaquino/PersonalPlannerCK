//
//  Cloud.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-01.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation
import CloudKit

fileprivate let kIsSubscribed = "isSubscribedPublic"
fileprivate let kSubscriptionID = "public-changes"

class Cloud {
  static let shared = Cloud()
  
  var container: CKContainer { CKContainer(identifier: "iCloud.com.calvinaquino.planner") }
  var database: CKDatabase { self.container.publicCloudDatabase }
  var zoneID: CKRecordZone { CKRecordZone.default() }
  
  class var subscriptionID: String {
    kSubscriptionID
  }
  
  class var isSubscribed: Bool {
    get { UserDefaults.standard.bool(forKey: kIsSubscribed) }
    set { UserDefaults.standard.set(newValue, forKey: kIsSubscribed) }
  }
  
  class func subscribeIfNeeded() {
    guard !Cloud.isSubscribed else {
      return
    }
    
    let predicate = NSPredicate(value: true)
    let recordTypes = [CKRecord.RecordType.ShoppingItem, CKRecord.RecordType.ShoppingCategory, CKRecord.RecordType.TransactionItem, CKRecord.RecordType.TransactionCategory]
    var subscriptionsToSave: [CKQuerySubscription] = []
    for recordType in recordTypes {
      let subscription = CKQuerySubscription(recordType: recordType, predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordDeletion,.firesOnRecordUpdate])
      let info = CKSubscription.NotificationInfo()
      info.shouldSendContentAvailable = true
      //    info.alertBody = ""
      subscription.notificationInfo = info
      subscriptionsToSave.append(subscription)
    }
    
    let subscriptionOperation = CKModifySubscriptionsOperation(subscriptionsToSave: subscriptionsToSave, subscriptionIDsToDelete: nil)
    subscriptionOperation.modifySubscriptionsCompletionBlock = { (_, _, error) in
      if let error = error {
        print(error.localizedDescription)
      } else {
        Cloud.isSubscribed = true
      }
    }
    Cloud.shared.database.add(subscriptionOperation)
  }
  
  class func queryOperation(for recordType: Record.Type, predicate: NSPredicate = NSPredicate(value: true)) -> CKQueryOperation {
    let query = CKQuery(recordType: recordType.recordType, predicate: predicate)
    let queryOperation = CKQueryOperation(query: query)
    queryOperation.database = Cloud.shared.database
    return queryOperation
  }
  
  class func modifyBatch(save: [Record], delete: [Record], completion: @escaping () -> Void) {
    let recordsToSave = save.map{$0.ckRecord!}
    let recordIDsToDelete = delete.map{$0.recordId}
    let modifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete)
    let configuration = CKOperation.Configuration()
    configuration.qualityOfService = .userInitiated
    modifyRecordsOperation.configuration = configuration
    modifyRecordsOperation.modifyRecordsCompletionBlock = { _, _, _ in
      completion()
    }
    Cloud.shared.database.add(modifyRecordsOperation)
  }
  
  class func modify(save: Record?, delete: Record?, completion: @escaping () -> Void) {
    let modifyRecordsOperation = CKModifyRecordsOperation()
    if let save = save {
      modifyRecordsOperation.recordsToSave = [save.ckRecord]
    }
    if let delete = delete {
      modifyRecordsOperation.recordIDsToDelete = [delete.recordId]
    }
    let configuration = CKOperation.Configuration()
    configuration.qualityOfService = .userInitiated
    modifyRecordsOperation.configuration = configuration
    modifyRecordsOperation.modifyRecordsCompletionBlock = { saved, deleted, error in
      completion()
    }
    Cloud.shared.database.add(modifyRecordsOperation)
  }
  
  class func fetch(_ record: Record, completion: @escaping () -> Void) {
    let fetchOperation = CKFetchRecordsOperation(recordIDs: [record.recordId])
    let configuration = CKOperation.Configuration()
    configuration.qualityOfService = .userInitiated
    fetchOperation.configuration = configuration
    fetchOperation.perRecordCompletionBlock = { fetchedRecord, fetchedRecordId, error in
      record.ckRecord = fetchedRecord
    }
    fetchOperation.fetchRecordsCompletionBlock = { _, error in
      completion()
    }
    Cloud.shared.database.add(fetchOperation)
  }
  
  class func handleCreatedOrUpdatedRecord(_ recordID: CKRecord.ID, completion: @escaping () -> Void) {
    let fetchOperation = CKFetchRecordsOperation(recordIDs: [recordID])
    let configuration = CKOperation.Configuration()
    configuration.qualityOfService = .userInitiated
    fetchOperation.configuration = configuration
    fetchOperation.perRecordCompletionBlock = { fetchedRecord, fetchedRecordId, error in
      if let record = fetchedRecord {
        switch record.recordType {
        case CKRecord.RecordType.ShoppingItem:
          let newItem = ShoppingItem(with: record)
          newItem.save()
        case CKRecord.RecordType.ShoppingCategory:
          let newItem = ShoppingCategory(with: record)
          newItem.save()
        case CKRecord.RecordType.TransactionItem:
          let newItem = TransactionItem(with: record)
          newItem.save()
        case CKRecord.RecordType.TransactionCategory:
          let newItem = TransactionCategory(with: record)
          newItem.save()
        default:
          break
        }
      }
    }
    fetchOperation.fetchRecordsCompletionBlock = { recordsByID, error in
      completion()
    }
    Cloud.shared.database.add(fetchOperation)
  }
  
  class func errorAlert(error: Error) {
    print(error.localizedDescription)
  }
  
  class func fetchShoppingItems(completion: @escaping () -> Void) {
    var shoppingItems: [ShoppingItem] = []
    let fetchOperation = queryOperation(for: ShoppingItem.self)
    fetchOperation.recordFetchedBlock = { record in
      shoppingItems.append(ShoppingItem(with: record))
    }
    fetchOperation.queryCompletionBlock = { cursor, error in
      if let error = error {
        self.errorAlert(error: error)
      }
      Store.shared.shoppingItems.items = shoppingItems
      DispatchQueue.main.async {
        completion()
      }
    }
    Cloud.shared.database.add(fetchOperation)
  }
  
  class func fetchTransactionItems(for month: Int, year: Int, completion: @escaping () -> Void) {
    var transactionItems: [TransactionItem] = []
    let predicate = TransactionItem.predicate(month: month, year: year)
    let fetchOperation = queryOperation(for: TransactionItem.self, predicate: predicate)
    fetchOperation.recordFetchedBlock = { record in
      transactionItems.append(TransactionItem(with: record))
    }
    fetchOperation.queryCompletionBlock = { cursor, error in
      if let error = error {
        self.errorAlert(error: error)
      }
      Store.shared.transactionItems.items = transactionItems
      DispatchQueue.main.async {
        completion()
      }
    }
    Cloud.shared.database.add(fetchOperation)
  }
  
  class func fetchTransactionCategories(completion: @escaping () -> Void) {
    var transactionCategories: [TransactionCategory] = []
    let fetchOperation = queryOperation(for: TransactionCategory.self)
    fetchOperation.recordFetchedBlock = { record in
      transactionCategories.append(TransactionCategory(with: record))
    }
    fetchOperation.queryCompletionBlock = { cursor, error in
      if let error = error {
        self.errorAlert(error: error)
      }
      Store.shared.transactionCategories.items = transactionCategories
      DispatchQueue.main.async {
        completion()
      }
    }
    Cloud.shared.database.add(fetchOperation)
  }
  
  class func fetchShoppingCategories(completion: @escaping () -> Void) {
    var shoppingCategories: [ShoppingCategory] = []
    let fetchOperation = queryOperation(for: ShoppingCategory.self)
    fetchOperation.recordFetchedBlock = { record in
      shoppingCategories.append(ShoppingCategory(with: record))
    }
    fetchOperation.queryCompletionBlock = { cursor, error in
      if let error = error {
        self.errorAlert(error: error)
      }
      Store.shared.shoppingCategories.items = shoppingCategories
      DispatchQueue.main.async {
        completion()
      }
    }
    Cloud.shared.database.add(fetchOperation)
  }
}
