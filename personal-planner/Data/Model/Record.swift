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

//extension CKRecord {
//  subscript<Root, Value: CKRecordValueProtocol>(dynamicMember keyPath: WritableKeyPath<Root, Value>) -> Value? {
//    get {
//      let key = NSExpression(forKeyPath: keyPath).keyPath
//      return self[key]
//    }
//    set {
//      let key = NSExpression(forKeyPath: keyPath).keyPath
//      // Fatal error: Could not extract a String from KeyPath Swift.ReferenceWritableKeyPath
//      self[key] = newValue
//    }
//  }
//}

extension CKRecord.RecordType {
  static var ShoppingItem: String { "ShoppingItem" }
  static var ShoppingCategory: String { "ShoppingCategory" }
  static var TransactionItem: String { "TransactionItem" }
  static var TransactionCategory: String { "TransactionCategory" }
  static var PurchaseItem: String { "PurchaseItem" }
  static var PurchaseCategory: String { "PurchaseCategory" }

  static var All: [CKRecord.RecordType] = [
    CKRecord.RecordType.ShoppingItem,
    CKRecord.RecordType.ShoppingCategory,
    CKRecord.RecordType.TransactionItem,
    CKRecord.RecordType.TransactionCategory,
    CKRecord.RecordType.PurchaseItem,
    CKRecord.RecordType.PurchaseCategory
  ]
}

protocol StringIdentifiable: Identifiable {
  var id: String { get }
}

protocol Named {
  var name: String { get set }
}
extension Named where Self: Record {
  var name: String {
    get { self.ckRecord["name"] ?? "" }
    set { self.ckRecord["name"] = newValue }
  }
}

// Cannot be negative
protocol Priced {
  var price: Double { get set }
}
extension Priced where Self: Record {
  var price: Double {
    get { self.ckRecord["price"] ?? 0.0 }
    set { self.ckRecord["price"] = newValue }
  }
}

// Can be negative
protocol Valued {
  var isInflow: Bool { get set }
  var value: Double { get set }
  var valueSigned: Double { get}
}

extension Valued where Self: Record {
  var valueSigned: Double {
    isInflow ? value : -value
  }
  
  var value: Double {
    get { self.ckRecord["value"] ?? 0.0 }
    set { self.ckRecord["value"] = newValue }
  }
  var isInflow: Bool {
    get { self.ckRecord["isInflow"] ?? false }
    set { self.ckRecord["isInflow"] = newValue}
  }
}

protocol Completable {
  var isComplete: Bool { get set }
}
extension Completable where Self: Record {
  var isComplete: Bool {
    get { self.ckRecord["isComplete"] ?? false }
    set { self.ckRecord["isComplete"] = newValue }
  }
}

protocol Needed {
  var isNeeded: Bool { get set }
}
extension Needed where Self: Record {
  var isNeeded: Bool {
    get { self.ckRecord["isNeeded"] ?? false }
    set { self.ckRecord["isNeeded"] = newValue }
  }
}

protocol Dated {
  var date: Date { get set }
}
extension Dated where Self: Record {
  var date: Date {
    get { self.ckRecord["date"] ?? Date() }
    set { self.ckRecord["date"] = newValue }
  }
}

protocol Categorized {
  associatedtype Category: StringIdentifiable, Named
  var category: Category? { get set }
}

protocol FormCategoryPickerMenu {
  var selectedCategoryName: String { get }
}
