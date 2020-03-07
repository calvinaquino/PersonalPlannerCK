//
//  ShoppingCategoryFormView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-23.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct ShoppingCategoryFormView: View {
  init() {
    self.init(with: nil)
  }
  
  init(with shoppingCategory: ShoppingCategory?) {
    self.item = shoppingCategory
    _name = State(initialValue: item?.name ?? "")
  }
  
  private var item: ShoppingCategory?
  
  @Environment(\.presentationMode) var presentationMode
  
  @State private var name: String
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField("Nome", text: $name)
        }
      }
      .navigationBarTitle(self.item != nil ? "Editar categoria" : "Nova categoria", displayMode: .inline)
      .navigationBarItems(leading: Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
          Text("Cancelar")
      }, trailing: Button(action: { self.save()}) {
          Text("Salvar")
      })
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
  
  func save() {
    let editingItem = self.item ?? ShoppingCategory()
    editingItem.name = self.name
    editingItem.save()
    self.presentationMode.wrappedValue.dismiss()
  }
}

struct ShoppingCategoryFormView_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingCategoryFormView()
  }
}
