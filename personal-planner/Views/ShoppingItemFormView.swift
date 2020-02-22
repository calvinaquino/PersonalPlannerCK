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
  
  var item: ShoppingItem?
  
  @FetchRequest(fetchRequest: ShoppingCategory.allFetchRequest()) var categories: FetchedResults<ShoppingCategory>
  @Environment(\.presentationMode) var presentationMode
  
  @State private var name: String = ""
  @State private var localizedName: String = ""
  @State private var price: String = ""
  @State private var isNeeded: Bool = true
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
            ForEach(categories, id: \.self) {
              Text($0.name)
            }
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
            Store.save()
            self.presentationMode.wrappedValue.dismiss()
          }
        }
      }
      .onAppear {
        self.name = self.item?.name ?? ""
        self.localizedName = self.item?.localizedName ?? ""
        self.price = self.item?.price.stringValue ?? ""
        self.isNeeded = self.item?.isNeeded ?? true
        self.category = self.item?.shoppingCategory ?? nil
      }
      .navigationBarTitle("Novo item")
    }
  }
}

struct ShoppingItemFormView_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingItemFormView()
  }
}
