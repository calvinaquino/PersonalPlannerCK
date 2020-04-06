//
//  TaskItemFormView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-04-04.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation

import Combine
import SwiftUI

struct TaskItemFormView: View {
  
  init() {
    self.init(with: FormViewManager.shared.taskItemForm.editingItem)
  }

  init(with taskItem: TaskItem?) {
    self.item = taskItem
    _name = State(initialValue: item?.name ?? "")
    _description = State(initialValue: item?.description ?? "")
    _category = State(initialValue: item?.category ?? nil)
  }
  
  private var item: TaskItem?
  
  @ObservedObject private var categories = TaskCategories()
  @Environment(\.presentationMode) var presentationMode
  
  @State private var name: String
  @State private var description: String
  @State private var category: TaskCategory?
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField("Nome", text: $name)
          TextField("Descrição", text: $description)
          Picker("Categoria", selection: $category) {
            ForEach(categories.items, id: \.id) { item in
              Text(item.name).tag(item as TaskCategory?)
            }
            Text("Geral").tag(nil as TaskCategory?)
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
    let editingItem = self.item ?? TaskItem()
    editingItem.name = self.name
    editingItem.description = self.description
    editingItem.category = self.category
    editingItem.save()
    self.presentationMode.wrappedValue.dismiss()
  }
}

struct TaskItemFormView_Previews: PreviewProvider {
  static var previews: some View {
    TaskItemFormView()
  }
}
