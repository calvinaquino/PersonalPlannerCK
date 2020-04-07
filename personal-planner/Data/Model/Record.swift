//
//  Record.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-01.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation
import CloudKit

protocol Record: CloudAccessible, Hashable, StoreAccessible {
  associatedtype SelfRecord
  
  var id: String { get }
  var recordId: CKRecord.ID { get }
  
  var ckRecord: CKRecord! { get set }
  var deleted: Bool { get set }
  
  init(with record: CKRecord?)
  init(withRecordName recordName: String)
  init()
  
  static var recordType: String { get }
  static func makeRecord(with record: CKRecord) -> SelfRecord
  static func newCKRecord(recordType: String) -> CKRecord
}

extension Record {
  var id: String {
    self.ckRecord.recordID.recordName
  }
  
  var recordId: CKRecord.ID {
    self.ckRecord.recordID
  }
  
  init(with record: CKRecord?) {
    self.init()
    self.ckRecord = record ?? Self.newCKRecord(recordType: Self.recordType)
  }
  
  init(withRecordName recordName: String) {
    let recordId = CKRecord.ID(recordName: recordName)
    let record = CKRecord(recordType: Self.recordType, recordID: recordId)
    self.init(with: record)
  }
  
  init() {
    self.init(withRecordName: UUID().uuidString)
  }
  
  static func newCKRecord(recordType: String) -> CKRecord {
    let recordId = CKRecord.ID(recordName: UUID().uuidString)
    return CKRecord(recordType: recordType, recordID: recordId)
  }
}

extension CKRecord {
  var id: String {
    self.recordID.recordName
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

protocol Named {
  var name: String { get set }
}
extension Named where Self: Record {
  var name: String {
    get { self.ckRecord["name"] ?? "" }
    set { self.ckRecord["name"] = newValue }
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
  var isInflow: Bool {
    get { self.ckRecord["isInflow"] ?? false }
    set { self.ckRecord["isInflow"] = newValue}
  }
  var value: Double {
    get { self.ckRecord["value"] ?? 0.0 }
    set { self.ckRecord["value"] = newValue}
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

protocol Located {
  var location: String { get set }
}
extension Located where Self: Record {
  var location: String {
    get { self.ckRecord["location"] ?? "" }
    set { self.ckRecord["location"] = newValue }
  }
}

protocol Categorized where Self: StoreAccessible {
  associatedtype ParentCategory: Record, Named
  var category: ParentCategory? { get set }
  var categoryKey: String { get }
  func makeCategory(with record: CKRecord) -> ParentCategory
}
extension Categorized where Self: Record {
  var category: ParentCategory? {
    get {
      if let reference = self.ckRecord[self.categoryKey] as? CKRecord.Reference {
        let record = CKRecord(recordType: ParentCategory.recordType, recordID: reference.recordID)
        let cached = ParentCategory.store().items.first { $0.id == record.id }
        return cached ?? ParentCategory.makeRecord(with: record) as! Self.ParentCategory
      }
      return nil
    }
    set {
      if let newCategory = newValue {
        let reference = CKRecord.Reference(recordID: newCategory.ckRecord!.recordID, action: .none)
        self.ckRecord[self.categoryKey] = reference
      } else {
        self.ckRecord[self.categoryKey] = nil
      }
    }
  }
}

protocol StoreAccessible where Self: StringIdentifiable {
  static func store() -> Cache<Self>
}

protocol RecordMaker where Self: Record {
  associatedtype CreatedRecord: Record
  static func makeRecord(with record: CKRecord) -> CreatedRecord
}

protocol CloudAccessible: AnyObject {
  func onSave()
  func save()
  func save(completion: @escaping () -> Void)
  
  func onFetch()
  func fetch()
  func fetch(completion: @escaping () -> Void)
  
  func onDelete()
  func delete()
  func delete(completion: @escaping () -> Void)
}
extension CloudAccessible where Self: Record {
  func onSave() { }
  func save() { self.save { } }
  func save(completion: @escaping () -> Void) {
    onSave()
    Cloud.modify(save: self, delete: nil) { completion() }
  }
  
  
  func onFetch() { }
  func fetch() { self.fetch {  } }
  func fetch(completion: @escaping () -> Void) {
    self.onFetch()
    Cloud.fetch(self) { completion() }
  }
  
  func onDelete() { }
  func delete() { self.delete {  } }
  func delete(completion: @escaping () -> Void) {
    self.onDelete()
    Cloud.modify(save: nil, delete: self) {
      self.deleted = true
      completion()
    }
  }
}

extension CloudAccessible where Self: StoreAccessible {
  func onSave() {
    Self.store().save(self)
  }
  
  func onDelete() {
    Self.store().delete(self.id)
  }
}
