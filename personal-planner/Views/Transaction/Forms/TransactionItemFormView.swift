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
    self.init(with: nil, date: nil)
  }

  init(with transactionItem: TransactionItem?, date: Date?) {
    self.item = transactionItem
    _name = State(initialValue: item?.name ?? "")
    _value = State(initialValue: item?.value.stringValue ?? "")
    _date = State(initialValue: date ?? transactionItem?.date ?? Date())
    _isInflow = State(initialValue: item?.isInflow ?? false)
    _category = State(initialValue: item?.transactionCategory ?? nil)
  }
  
  private var item: TransactionItem?
  
  @ObservedObject private var categories = TransactionCategories()
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
            ForEach(categories.items, id: \.id) { item in
              Text(item.name).tag(item as TransactionCategory?)
            }
            Text("Geral").tag(nil as TransactionCategory?)
          }
        }
      }
      .navigationBarTitle(self.item != nil ? "Editar item" : "Novo item", displayMode: .inline)
      .navigationBarItems(leading: Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
          Text("Cancelar")
      }, trailing: Button(action: { self.save()}) {
          Text("Salvar")
      })
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
  
  func save() {
    let editingItem = self.item ?? TransactionItem()
    editingItem.name = self.name
    editingItem.value = self.value.doubleValue
    editingItem.isInflow = self.isInflow
    editingItem.date = self.date
    editingItem.transactionCategory = self.category
    editingItem.save()
    self.presentationMode.wrappedValue.dismiss()
  }
}

struct TransactionItemFormView_Previews: PreviewProvider {
  static var previews: some View {
    TransactionItemFormView()
  }
}

