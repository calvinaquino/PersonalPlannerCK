//
//  TransactionItem.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import CoreData
import SwiftUI


class TransactionItem : NSManagedObject, Identifiable {
  @NSManaged var name: String
  @NSManaged var value: Double
  @NSManaged var day: Int16
  @NSManaged var month: Int16
  @NSManaged var year: Int16
  @NSManaged var isInflow: Bool
  @NSManaged var transactionCategory: TransactionCategory?
  
  var valueSigned: Double {
    isInflow ? value : -value
  }
  
  convenience init() {
    self.init(context: Store.context)
  }
  
  static func allFetchRequest() -> NSFetchRequest<TransactionItem> {
    let request : NSFetchRequest<TransactionItem> = TransactionItem.fetchRequest() as! NSFetchRequest<TransactionItem>
    request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    return request
  }
  
  static func allFetchRequest(month: Int16, year: Int16) -> NSFetchRequest<TransactionItem> {
    let request = TransactionItem.allFetchRequest()
    let monthPredicate = NSPredicate(format: "month == %@", month.numberValue)
    let yearPredicate = NSPredicate(format: "year == %@", year.numberValue)
    let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [monthPredicate, yearPredicate])
    request.predicate = compoundPredicate
    return request
  }
}

class FetchTransactionItems: ObservableObject {
  var month: Int16 {
    didSet {
      self.updateRequest()
    }
  }
  var year: Int16 {
    didSet {
      self.updateRequest()
    }
  }

  @FetchRequest(fetchRequest: TransactionItem.allFetchRequest()) var items: FetchedResults<TransactionItem>

  func updateRequest() {
    let predicate = NSPredicate(format: "month == %@ AND year == $@", self.month.numberValue, self.year.numberValue)
    let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    _items = FetchRequest(entity: TransactionItem.entity(), sortDescriptors: sortDescriptors, predicate: predicate)
  }

  init(month: Int16, year: Int16) {
    self.month = month
    self.year = year
    self.updateRequest()
  }
  
  func callAsFunction() -> FetchedResults<TransactionItem> {
    self.items
  }
}

