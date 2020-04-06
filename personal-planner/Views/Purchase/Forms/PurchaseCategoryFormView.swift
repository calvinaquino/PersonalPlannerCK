//
//  PurchaseCategoryFormView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-04-04.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct PurchaseCategoryFormView: View {
  init() {
    self.init(with: nil)
  }
  
  init(with purchaseCategory: PurchaseCategory?) {
    self.item = purchaseCategory
    _name = State(initialValue: item?.name ?? "")
  }
  
  private var item: PurchaseCategory?
  
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
    let editingItem = self.item ?? PurchaseCategory()
    editingItem.name = self.name
    editingItem.save()
    self.presentationMode.wrappedValue.dismiss()
  }
}

struct PurchaseCategoryFormView_Previews: PreviewProvider {
  static var previews: some View {
    PurchaseCategoryFormView()
  }
}
