//
//  TransactionItemFormView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-22.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation

import Combine
import SwiftUI

struct TransactionItemFormView: View {
  
  init() {
    self.init(with: nil)
  }

  init(with transactionItem: TransactionItem?) {
    self.item = transactionItem
    _name = State(initialValue: item?.name ?? "")
    _value = State(initialValue: item?.value.stringValue ?? "")
    _date = State(initialValue: Date.with(day: item?.day, month: item?.month, year: item?.year))
    _isInflow = State(initialValue: item?.isInflow ?? false)
    _category = State(initialValue: item?.transactionCategory ?? nil)
  }
  
  private var item: TransactionItem?
  
  @FetchRequest(fetchRequest: TransactionCategory.allFetchRequest()) var categories: FetchedResults<TransactionCategory>
  @Environment(\.presentationMode) var presentationMode
  
  @State private var name: String
  @State private var value: String
  @State private var date: Date
  @State private var isInflow: Bool
  @State private var category: TransactionCategory?
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField("Nome", text: $name)
          TextField("Valor", text: $value)
            .keyboardType(.decimalPad)
          Toggle("Recebido", isOn: $isInflow)
          DatePicker(selection: $date, displayedComponents: .date) {
            Text("Data")
          }
          Picker("Categoria", selection: $category) {
            ForEach(categories, id: \.self) { item in
              Text(item.name).tag(item as TransactionCategory?)
            }
            Text("Geral").tag(nil as TransactionCategory?)
          }
        }
        Section {
          Button("Salvar") {
            let editingItem = self.item ?? TransactionItem()
            editingItem.name = self.name
            editingItem.value = self.value.doubleValue
            editingItem.isInflow = self.isInflow
            editingItem.day = self.date.day
            editingItem.month = self.date.month
            editingItem.year = self.date.year
            editingItem.transactionCategory = self.category
            Store.save()
            self.presentationMode.wrappedValue.dismiss()
          }
        }
      }
      .navigationBarTitle(self.item != nil ? "Editar item" : "Novo item", displayMode: .inline)
    }
  }
}

struct TransactionItemFormView_Previews: PreviewProvider {
  static var previews: some View {
    TransactionItemFormView().environment(\.managedObjectContext, Store.context)
  }
}

