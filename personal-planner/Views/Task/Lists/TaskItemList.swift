//
//  TaskItemList.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-04-04.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct TaskItemList: View {
  
  @ObservedObject private var taskItems = TaskItems.shared
  @ObservedObject private var taskCategories = TaskCategories.shared
  
  @Binding var isFiltering: Bool
  @Binding private var showingFormScreen: Bool
  @Binding private var editingItem: TaskItem?
  @State private var rotation: Double = 0.0;
  
  init(query: String, editingItem: Binding<TaskItem?>, isFiltering: Binding<Bool>, showingFormScreen: Binding<Bool>) {
    self._isFiltering = isFiltering
    self._editingItem = editingItem
    self._showingFormScreen = showingFormScreen
    self.taskItems.query = query
  }
  
  var sections: [TaskSection] {
    TaskSection.sections(items: taskItems.items, categories: taskCategories.items, filter: self.isFiltering)
  }
  
  var body: some View {
    List {
      ForEach(sections, id: \.id) { section in
        Section(header: HStack {
          Text(section.categoryName)
          Spacer()
        }) {
          ForEach(section.items, id: \.id) { item in
            TaskItemRow(item: item) {
              self.editingItem = $0
              self.showingFormScreen = true
            }
          }
          .onDelete(perform: { offsets in
            self.delete(at: offsets, in: section)
          })
        }
      }
    }
  }
  
  func delete(at offsets: IndexSet, in section: TaskSection) {
    for offset in offsets {
      let item = section.items[offset]
      item.delete()
    }
  }
}

struct TaskItemList_Previews: PreviewProvider {
  static var previews: some View {
    TaskItemList(query: "", editingItem: .constant(nil), isFiltering: .constant(false), showingFormScreen: .constant(false))
  }
}
