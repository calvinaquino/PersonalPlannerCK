//
//  ShoppingCategory.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import CoreData
import Foundation

class ShoppingCategory : ManagedRecord, Identifiable {
  @NSManaged var name: String
  @NSManaged var shoppingItems: [ShoppingItem]?
  
  static func allFetchRequest() -> NSFetchRequest<ShoppingCategory> {
    let request : NSFetchRequest<ShoppingCategory> = ShoppingCategory.fetchRequest() as! NSFetchRequest<ShoppingCategory>
    request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    return request
  }
}

