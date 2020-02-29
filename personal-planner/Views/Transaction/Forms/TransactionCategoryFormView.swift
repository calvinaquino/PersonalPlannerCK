//
//  TransactionCategoryFormView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-23.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct TransactionCategoryFormView: View {
  init() {
    self.init(with: nil)
  }
  
  init(with transactionCategory: TransactionCategory?) {
    self.item = transactionCategory
    _name = State(initialValue: item?.name ?? "")
    _budget = State(initialValue: item?.budget.stringCurrencyValue ?? "")
  }
  
  private var item: TransactionCategory?
  
  @Environment(\.presentationMode) var presentationMode
  
  @State private var name: String
  @State private var budget: String
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField("Nome", text: $name)
          TextField("Orçamento", text: $budget)
        }
        Section {
          Button("Salvar") {
            let editingItem = self.item ?? TransactionCategory()
            editingItem.name = self.name
            editingItem.budget = self.budget.doubleValue
            Store.save()
            self.presentationMode.wrappedValue.dismiss()
          }
        }
      }
      .navigationBarTitle(self.item != nil ? "Editar categoria" : "Nova categoria", displayMode: .inline)
    }
  }
}

struct TransactionCategoryFormView_Previews: PreviewProvider {
  static var previews: some View {
    TransactionCategoryFormView().environment(\.managedObjectContext, Store.context)
  }
}
