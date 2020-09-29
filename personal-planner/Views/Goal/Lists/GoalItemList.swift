//
//  GoalItemList.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-04-04.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct GoalItemList: View {
  
  @ObservedObject private var goalItems = GoalItems.shared
  @ObservedObject private var goalCategories = GoalCategories.shared
  
  @Binding var isFiltering: Bool
  @Binding private var showingFormScreen: Bool
  @Binding private var editingItem: GoalItem?
  @State private var rotation: Double = 0.0;
  
  init(query: String, editingItem: Binding<GoalItem?>, isFiltering: Binding<Bool>, showingFormScreen: Binding<Bool>) {
    self._isFiltering = isFiltering
    self._editingItem = editingItem
    self._showingFormScreen = showingFormScreen
    self.goalItems.query = query
  }
  
  var sections: [GoalSection] {
    GoalSection.sections(items: goalItems.items, categories: goalCategories.items, filter: self.isFiltering)
  }
  
  var body: some View {
    List {
      ForEach(sections, id: \.id) { section in
        Section(header: HStack {
          Text(section.categoryName)
          Spacer()
        }) {
          ForEach(section.items, id: \.id) { item in
            GoalItemRow(item: item) {
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
  
  func delete(at offsets: IndexSet, in section: GoalSection) {
    for offset in offsets {
      let item = section.items[offset]
      item.delete()
    }
  }
}

struct GoalItemList_Previews: PreviewProvider {
  static var previews: some View {
    GoalItemList(query: "", editingItem: .constant(nil), isFiltering: .constant(false), showingFormScreen: .constant(false))
  }
}
