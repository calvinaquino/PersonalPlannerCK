//
//  Cloud.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-01.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation
import CloudKit
import Combine

fileprivate let kIsSubscribed = "isSubscribedPublic"
fileprivate let kIsSubscribed2 = "isSubscribedPublic2"
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
  
  class var isSubscribed2: Bool {
    get { UserDefaults.standard.bool(forKey: kIsSubscribed2) }
    set { UserDefaults.standard.set(newValue, forKey: kIsSubscribed2) }
  }
  
  class func subscribeIfNeeded() {
    guard !Cloud.isSubscribed && !Cloud.isSubscribed2 else {
      return
    }
    
    let predicate = NSPredicate(value: true)
    let recordTypes = CKRecord.RecordType.All
    var subscriptionsToSave: [CKQuerySubscription] = []
    for recordType in recordTypes {
      let subscription = CKQuerySubscription(recordType: recordType, predicate: predicate, subscriptionID: subscriptionID)
      let info = CKSubscription.NotificationInfo()
      info.shouldSendContentAvailable = true
      //    info.alertBody = ""
      subscription.notificationInfo = info
      subscriptionsToSave.append(subscription)
    }
    
    let subscriptionOperation = CKModifySubscriptionsOperation(subscriptionsToSave: subscriptionsToSave, subscriptionIDsToDelete: nil)
      subscriptionOperation.modifySubscriptionsResultBlock = { result in
          switch result {
          case .success():
              Cloud.isSubscribed = true
              Cloud.isSubscribed2 = true
          case .failure(let error):
              print(error.localizedDescription)
          }
          
      }
    Cloud.shared.database.add(subscriptionOperation)
  }
  
  class func queryOperation(for recordType: Record.Type, predicate: NSPredicate = NSPredicate(value: true)) -> CKQueryOperation {
    let query = CKQuery(recordType: recordType.recordType, predicate: predicate)
    let nameSort = NSSortDescriptor(key: "name", ascending: true)
    query.sortDescriptors = [nameSort]
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
      modifyRecordsOperation.modifyRecordsResultBlock = { result in
          switch result {
          case .failure(let error):
              print(error.localizedDescription)
          default: break
          }
          completion()
      }
    Cloud.shared.database.add(modifyRecordsOperation)
  }
  
  class func modify(save: Record?, delete: Record?, completion: @escaping () -> Void) {
    let modifyRecordsOperation = CKModifyRecordsOperation()
    modifyRecordsOperation.savePolicy = .changedKeys
    if let save = save {
      modifyRecordsOperation.recordsToSave = [save.ckRecord]
    }
    if let delete = delete {
      modifyRecordsOperation.recordIDsToDelete = [delete.recordId]
    }
    let configuration = CKOperation.Configuration()
    configuration.qualityOfService = .userInitiated
    modifyRecordsOperation.configuration = configuration
      modifyRecordsOperation.modifyRecordsResultBlock = { result in
          switch result {
          case .failure(let error):
              print(error.localizedDescription)
          default: break
          }
          completion()
      }
    Cloud.shared.database.add(modifyRecordsOperation)
  }
  
  class func fetch(_ record: Record, completion: @escaping () -> Void) {
    let fetchOperation = CKFetchRecordsOperation(recordIDs: [record.recordId])
    let configuration = CKOperation.Configuration()
    configuration.qualityOfService = .userInitiated
    fetchOperation.configuration = configuration
      fetchOperation.perRecordResultBlock = { (_, result) in
          switch result {
          case .success(let fetchedRecord):
              record.ckRecord = fetchedRecord
          case .failure(let error):
              print(error.localizedDescription)
          }
      }
      fetchOperation.fetchRecordsResultBlock = { result in
          switch result {
          case .failure(let error):
              print(error.localizedDescription)
          default: break
          }
          completion()
      }
    Cloud.shared.database.add(fetchOperation)
  }
  
  class func handleCreatedOrUpdatedRecord(_ recordID: CKRecord.ID, completion: @escaping () -> Void) {
    let fetchOperation = CKFetchRecordsOperation(recordIDs: [recordID])
    let configuration = CKOperation.Configuration()
    configuration.qualityOfService = .userInitiated
    fetchOperation.configuration = configuration
      fetchOperation.perRecordResultBlock = { (_, result) in
          switch result {
          case .success(let record):
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
              case CKRecord.RecordType.GoalItem:
                  let newItem = GoalItem(with: record)
                  newItem.save()
              case CKRecord.RecordType.GoalCategory:
                  let newItem = GoalCategory(with: record)
                  newItem.save()
              default:
                  break
              }
          case .failure(let error):
              print(error.localizedDescription)
          }
      }
      fetchOperation.fetchRecordsResultBlock = { result in
          switch result {
          case .failure(let error):
              print(error.localizedDescription)
          default: break
          }
          completion()
      }
    Cloud.shared.database.add(fetchOperation)
  }
  
  class func errorAlert(error: Error) {
    print(error.localizedDescription)
  }
}

// MARK: Shopping -
extension Cloud {
  class func fetchShoppingItems(completion: @escaping () -> Void) {
    var shoppingItems: [ShoppingItem] = []
    let fetchOperation = queryOperation(for: ShoppingItem.self)
      fetchOperation.recordMatchedBlock = { _, result in
          switch result {
          case .success(let record):
              shoppingItems.append(ShoppingItem(with: record))
          case .failure(let error):
              print(error.localizedDescription)
          }
      }
      fetchOperation.queryResultBlock = { result in
          switch result {
          case .failure(let error):
              self.errorAlert(error: error)
          default: break
          }
          Store.shared.shoppingItems.items = shoppingItems
          DispatchQueue.main.async {
            completion()
          }
      }
    Cloud.shared.database.add(fetchOperation)
  }
  
  class func fetchShoppingCategories(completion: @escaping () -> Void) {
    var shoppingCategories: [ShoppingCategory] = []
    let fetchOperation = queryOperation(for: ShoppingCategory.self)
      fetchOperation.recordMatchedBlock = { _, result in
          switch result {
          case .success(let record):
              shoppingCategories.append(ShoppingCategory(with: record))
          case .failure(let error):
              print(error.localizedDescription)
          }
      }
      fetchOperation.queryResultBlock = { result in
          switch result {
          case .failure(let error):
              self.errorAlert(error: error)
          default: break
          }
          Store.shared.shoppingCategories.items = shoppingCategories
          DispatchQueue.main.async {
            completion()
          }
      }
    Cloud.shared.database.add(fetchOperation)
  }
}

// MARK: Transaction -
extension Cloud {
  class func fetchTransactionItems(for date: Date, completion: @escaping () -> Void) {
    var transactionItems: [TransactionItem] = []
    let fetchOperation = queryOperation(for: TransactionItem.self, predicate: date.currentMonthPredicate)
      fetchOperation.recordMatchedBlock = { _, result in
          switch result {
          case .success(let record):
              transactionItems.append(TransactionItem(with: record))
          case .failure(let error):
              print(error.localizedDescription)
          }
      }
      fetchOperation.queryResultBlock = { result in
          switch result {
          case .failure(let error):
              self.errorAlert(error: error)
          default: break
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
      fetchOperation.recordMatchedBlock = { _, result in
          switch result {
          case .success(let record):
              transactionCategories.append(TransactionCategory(with: record))
          case .failure(let error):
              print(error.localizedDescription)
          }
      }
      fetchOperation.queryResultBlock = { result in
          switch result {
          case .failure(let error):
              self.errorAlert(error: error)
          default: break
          }
          Store.shared.transactionCategories.items = transactionCategories
          DispatchQueue.main.async {
            completion()
          }
      }
    Cloud.shared.database.add(fetchOperation)
  }
}

// MARK: Goal -
extension Cloud {
  class func fetchGoalItems(completion: @escaping () -> Void) {
    var goalItems: [GoalItem] = []
    let fetchOperation = queryOperation(for: GoalItem.self)
      fetchOperation.recordMatchedBlock = { _, result in
          switch result {
          case .success(let record):
              goalItems.append(GoalItem(with: record))
          case .failure(let error):
              print(error.localizedDescription)
          }
      }
      fetchOperation.queryResultBlock = { result in
          switch result {
          case .failure(let error):
              self.errorAlert(error: error)
          default: break
          }
          Store.shared.goalItems.items = goalItems
          DispatchQueue.main.async {
            completion()
          }
      }
    Cloud.shared.database.add(fetchOperation)
  }
  
  class func fetchGoalCategories(completion: @escaping () -> Void) {
    var goalCategories: [GoalCategory] = []
    let fetchOperation = queryOperation(for: GoalCategory.self)
      fetchOperation.recordMatchedBlock = { _, result in
          switch result {
          case .success(let record):
              goalCategories.append(GoalCategory(with: record))
          case .failure(let error):
              print(error.localizedDescription)
          }
      }
      fetchOperation.queryResultBlock = { result in
          switch result {
          case .failure(let error):
              self.errorAlert(error: error)
          default: break
          }
          Store.shared.goalCategories.items = goalCategories
          DispatchQueue.main.async {
            completion()
          }
      }
    Cloud.shared.database.add(fetchOperation)
  }
}

//extension Cloud {
//  class func fetchRecords(for recordType: Record.Type, predicate: NSPredicate? = nil) -> Future<Void, Error> {
//    return Future<Void, Error> { promise in
////      var purchaseCategories: [] = []
//      let fetchOperation = queryOperation(for: recordType)
//      fetchOperation.recordFetchedBlock = { record in
////        purchaseCategories.append(PurchaseCategory(with: record))
//      }
//      fetchOperation.queryCompletionBlock = { cursor, error in
//        if let error = error {
//          self.errorAlert(error: error)
//          promise(.failure(error))
//        }
////        Store.shared.purchaseCategories.items = purchaseCategories
//        DispatchQueue.main.async {
//          promise(.success(()))
//        }
//      }
//      Cloud.shared.database.add(fetchOperation)
//    }
//  }
//}
