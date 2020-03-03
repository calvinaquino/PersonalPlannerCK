//
//  Notifications.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-01.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation

// not yet using

extension Notification.Name {
  static let shoppingItem = Notification.Name("shopping_item")
  static let transactionItem = Notification.Name("transaction_item")
  static let shoppingCategory = Notification.Name("shopping_category")
  static let transactionCategory = Notification.Name("transaction_category")
}

class Notifier {
  let shoppingItemPublisher = NotificationCenter.Publisher(center: .default, name: .shoppingItem, object: nil)
  let transactionItemPublisher = NotificationCenter.Publisher(center: .default, name: .shoppingCategory, object: nil)
  let shoppingCategoryPublisher = NotificationCenter.Publisher(center: .default, name: .transactionItem, object: nil)
  let transactionCategoryPublisher = NotificationCenter.Publisher(center: .default, name: .transactionCategory, object: nil)
}
