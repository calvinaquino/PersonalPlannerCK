//
//  Record.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-01.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import UIKit
import CloudKit

@objc class Record: NSObject, Identifiable {
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

extension CKRecord.RecordType {
  static var ShoppingItem: String { "ShoppingItem" }
  static var ShoppingCategory: String { "ShoppingCategory" }
  static var TransactionItem: String { "TransactionItem" }
  static var TransactionCategory: String { "TransactionCategory" }
}
