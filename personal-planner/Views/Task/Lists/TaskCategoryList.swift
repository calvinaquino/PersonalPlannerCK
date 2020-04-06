//
//  TaskCategoryList.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-04-04.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct TaskCategoryList: View {
  
  @ObservedObject private var taskCategories = TaskCategories.shared
  
  @Binding private var showingFormScreen: Bool
  @Binding private var editingItem: TaskCategory?
  
  init(query: String, editingItem: Binding<TaskCategory?>, showingFormScreen: Binding<Bool>) {
    self._editingItem = editingItem
    self._showingFormScreen = showingFormScreen
    self.taskCategories.query = query
  }
  
  var body: some View {
    List {
      ForEach(taskCategories.items, id: \.id) { item in
        HStack {
          Text(item.name)
          Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
          self.editingItem = item
          self.showingFormScreen.toggle()
        }
      }
      .onDelete(perform: self.delete)
    }
  }
  
  func delete(at offsets: IndexSet) {
    for offset in offsets {
      let item = self.taskCategories.items[offset]
      item.delete()
    }
  }
}

struct TaskCategoryList_Previews: PreviewProvider {
  static var previews: some View {
    TaskCategoryList(query: "", editingItem: .constant(nil), showingFormScreen: .constant(false))
  }
}
