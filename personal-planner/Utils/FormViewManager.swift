//
//  FormManager.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-16.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation
import Combine

class FormViewManager {
  static let shared = FormViewManager()
  
  var shoppingItemForm = FormView<ShoppingItem>()
  var shoppingCategoryForm = FormView<ShoppingCategory>()
  var transactionItemForm = FormView<TransactionItem>()
  var transactionCategoryForm = FormView<TransactionCategory>()
  var taskItemForm = FormView<TaskItem>()
  var taskCategoryForm = FormView<TaskCategory>()
  var purchaseItemForm = FormView<PurchaseItem>()
  var purchaseCategoryForm = FormView<PurchaseCategory>()
}

class FormView<T>: ObservableObject {
  var editingItem: T?
  @Published var isPresented: Bool = false
  
  func show(for item: T?) {
    self.isPresented = true
    self.editingItem = item
  }
  
  func hide() {
    self.isPresented = false
    self.editingItem = nil
  }
}
