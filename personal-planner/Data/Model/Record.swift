//
//  Record.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-01.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation
import CloudKit

@objc class Record: NSObject, StringIdentifiable {
  open var ckRecord: CKRecord!
  var deleted: Bool = false
  
  var id: String {
    self.ckRecord.recordID.recordName
  }
  
  var recordId: CKRecord.ID {
    self.ckRecord.recordID
  }
  
  required init(with record: CKRecord?) {
    super.init()
    self.ckRecord = record ?? Record.newCKRecord(recordType: Self.recordType)
  }
  
  convenience init(withRecordName recordName: String) {
    let recordId = CKRecord.ID(recordName: recordName)
    let record = CKRecord(recordType: Self.recordType, recordID: recordId)
    self.init(with: record)
  }
  
  convenience override init() {
    self.init(withRecordName: UUID().uuidString)
  }
  
  class var recordType: String {
    fatalError("recordType needs to be implemented by subclass")
  }
  
  class func newCKRecord(recordType: String) -> CKRecord {
    let recordId = CKRecord.ID(recordName: UUID().uuidString)
    return CKRecord(recordType: recordType, recordID: recordId)
  }
  
  open func onSave() { }
  final func save() { self.save { } }
  final func save(completion: @escaping () -> Void) {
    onSave()
    Cloud.modify(save: self, delete: nil) { completion() }
  }
  
  
  open func onFetch() { }
  final func fetch() { self.fetch {  } }
  final func fetch(completion: @escaping () -> Void) {
    self.onFetch()
    Cloud.fetch(self) { completion() }
  }
  
  open func onDelete() { }
  final func delete() { self.delete {  } }
  final func delete(completion: @escaping () -> Void) {
    self.onDelete()
    Cloud.modify(save: nil, delete: self) {
      self.deleted = true
      completion()
    }
  }
}

extension CKRecord {
  var id: String {
    self.recordID.recordName
  }
}

extension CKRecord {
  subscript<Root, Value: CKRecordValueProtocol>(dynamicMember keyPath: WritableKeyPath<Root, Value>) -> Value? {
    get {
      let key = NSExpression(forKeyPath: keyPath).keyPath
      return self[key]
    }
    set {
      let key = NSExpression(forKeyPath: keyPath).keyPath
      // Fatal error: Could not extract a String from KeyPath Swift.ReferenceWritableKeyPath
      self[key] = newValue
    }
  }
}

extension CKRecord.RecordType {
  static var ShoppingItem: String { "ShoppingItem" }
  static var ShoppingCategory: String { "ShoppingCategory" }
  static var TransactionItem: String { "TransactionItem" }
  static var TransactionCategory: String { "TransactionCategory" }
  static var TaskItem: String { "TaskItem" }
  static var TaskCategory: String { "TaskCategory" }
  static var PurchaseItem: String { "PurchaseItem" }
  static var PurchaseCategory: String { "PurchaseCategory" }
}

protocol StringIdentifiable: Identifiable {
  var id: String { get }
}

protocol Nameable {
  var name: String { get set }
}

// Cannot be negative
protocol Priceable {
  var price: Double { get set }
}

// Can be negative
protocol Valuable {
  var isInflow: Bool { get set }
  var value: Double { get set }
  var valueSigned: Double { get}
}

extension Valuable {
  var valueSigned: Double {
    isInflow ? value : -value
  }
}

protocol Needable {
  var isNeeded: Bool { get set }
}

protocol Categorizable {
  associatedtype Category: StringIdentifiable, Nameable
  var category: Category? { get set }
}
