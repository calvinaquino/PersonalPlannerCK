//
//  TransactionItem.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import CoreData
import Foundation

class TransactionItem : ManagedRecord, Identifiable {
  @NSManaged var name: String
  @NSManaged var value: Double
  @NSManaged var day: Int16
  @NSManaged var month: Int16
  @NSManaged var year: Int16
  @NSManaged var transacionCategory: TransactionCategory?
  
  static func allFetchRequest() -> NSFetchRequest<TransactionItem> {
    let request : NSFetchRequest<TransactionItem> = TransactionItem.fetchRequest() as! NSFetchRequest<TransactionItem>
    request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    return request
  }
}

