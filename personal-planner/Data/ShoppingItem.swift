//
//  ShoppingItem.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import CoreData
import SwiftUI

class ShoppingItem : NSManagedObject, Identifiable {
  @NSManaged var name: String
  @NSManaged var price: Double
  @NSManaged var localizedName: String?
  @NSManaged var isNeeded: Bool
  @NSManaged var shoppingCategory: ShoppingCategory?
  
  convenience init() {
    self.init(context: Store.context)
  }
  
  static func allFetchRequest() -> NSFetchRequest<ShoppingItem> {
    let request : NSFetchRequest<ShoppingItem> = ShoppingItem.fetchRequest() as! NSFetchRequest<ShoppingItem>
    request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    return request
  }
}

//@propertyWrapper
//struct FetchedShoppingItems {
//  @FetchRequest(fetchRequest: ShoppingItem.allFetchRequest()) private var items: FetchedResults<ShoppingItem>
//  var wrappedValue: FetchedResults<ShoppingItem> { items }
//}
