//
//  PurchaseItemFormView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-04-04.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation

import Combine
import SwiftUI

struct PurchaseItemFormView: View {
  
  init() {
    self.init(with: FormViewManager.shared.purchaseItemForm.editingItem)
  }

  init(with purchaseItem: PurchaseItem?) {
    self.item = purchaseItem
    _name = State(initialValue: item?.name ?? "")
    _description = State(initialValue: item?.description ?? "")
    _price = State(initialValue: item?.price.stringValue ?? "")
    _instalments = State(initialValue: item?.instalments ?? 1)
    _category = State(initialValue: item?.category ?? nil)
  }
  
  private var item: PurchaseItem?
  
  @ObservedObject private var categories = PurchaseCategories()
  @Environment(\.presentationMode) var presentationMode
  
  @State private var name: String
  @State private var description: String
  @State private var price: String
  @State private var instalments: Int
  @State private var category: PurchaseCategory?
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField("Nome", text: $name)
            .autocapitalization(.sentences)
          TextField("Descrição", text: $description)
          TextField("Preço", text: $price)
            .keyboardType(.decimalPad)
//          TextField("Parcelaa", text: $instalments) // slider?
          HStack {
            Picker("Categoria", selection: $category) {
              ForEach(categories.items, id: \.id) { item in
                Text(item.name).tag(item as PurchaseCategory?)
              }
              Text("Geral").tag(nil as PurchaseCategory?)
            }
            .pickerStyle(MenuPickerStyle())
            Spacer()
            Text(category?.name ?? "Geral")
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
    let editingItem = self.item ?? PurchaseItem()
    editingItem.name = self.name
    editingItem.description = self.description
    editingItem.price = self.price.doubleValue
    editingItem.instalments = self.instalments
    editingItem.category = self.category
    editingItem.save()
    self.presentationMode.wrappedValue.dismiss()
  }
}

struct PurchaseItemFormView_Previews: PreviewProvider {
  static var previews: some View {
    PurchaseItemFormView()
  }
}
