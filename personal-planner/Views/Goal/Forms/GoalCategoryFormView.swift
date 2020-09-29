//
//  GoalCategoryFormView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-04-04.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct GoalCategoryFormView: View {
  init() {
    self.init(with: nil)
  }
  
  init(with goalCategory: GoalCategory?) {
    self.item = goalCategory
    _name = State(initialValue: item?.name ?? "")
  }
  
  private var item: GoalCategory?
  
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
    let editingItem = self.item ?? GoalCategory()
    editingItem.name = self.name
    editingItem.save()
    self.presentationMode.wrappedValue.dismiss()
  }
}

struct GoalCategoryFormView_Previews: PreviewProvider {
  static var previews: some View {
    GoalCategoryFormView()
  }
}
