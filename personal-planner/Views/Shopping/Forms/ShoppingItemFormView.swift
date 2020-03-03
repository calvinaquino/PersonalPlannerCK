//
//  ShoppingItemFormView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-22.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation

import Combine
import SwiftUI

struct ShoppingItemFormView: View {
  
  init() {
    self.init(with: nil)
  }

  init(with shoppingItem: ShoppingItem?) {
    self.item = shoppingItem
    _name = State(initialValue: item?.name ?? "")
    _localizedName = State(initialValue: item?.localizedName ?? "")
    _price = State(initialValue: item?.price.stringValue ?? "")
    _isNeeded = State(initialValue: item?.isNeeded ?? true)
    _category = State(initialValue: item?.shoppingCategory ?? nil)
  }
  
  private var item: ShoppingItem?
  
  @ObservedObject private var categories = ShoppingCategories()
  @Environment(\.presentationMode) var presentationMode
  
  @State private var name: String
  @State private var localizedName: String
  @State private var price: String
  @State private var isNeeded: Bool
  @State private var category: ShoppingCategory?
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField("Nome", text: $name)
          TextField("Nome em inglês", text: $localizedName)
          TextField("Preço", text: $price)
            .keyboardType(.decimalPad)
          Toggle("Em falta", isOn: $isNeeded)
          Picker("Categoria", selection: $category) {
            ForEach(categories.items, id: \.id) { item in
              Text(item.name).tag(item as ShoppingCategory?)
            }
            Text("Geral").tag(nil as ShoppingCategory?)
          }
        }
        Section {
          Button("Salvar") {
            let editingItem = self.item ?? ShoppingItem()
            editingItem.name = self.name
            editingItem.localizedName = self.localizedName
            editingItem.price = self.price.doubleValue
            editingItem.isNeeded = self.isNeeded
            editingItem.shoppingCategory = self.category
            editingItem.save()
            self.presentationMode.wrappedValue.dismiss()
          }
        }
      }
      .navigationBarTitle(self.item != nil ? "Editar item" : "Novo item", displayMode: .inline)
    }
  }
}

struct ShoppingItemFormView_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingItemFormView()
  }
}
