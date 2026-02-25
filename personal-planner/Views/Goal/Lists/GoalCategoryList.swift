//
//  GoalCategoryList.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-04-04.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct GoalCategoryList: View {
  
  @State private var goalCategories = GoalCategories.shared

  var query: String
  @Binding private var showingFormScreen: Bool
  @Binding private var editingItem: GoalCategory?
  
  var body: some View {
    List {
      ForEach(goalCategories.items, id: \.id) { item in
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
    .onChange(of: query) { _, newValue in
      goalCategories.query = newValue
    }
    .onAppear {
      goalCategories.query = query
    }
  }
  
  func delete(at offsets: IndexSet) {
    for offset in offsets {
      let item = self.goalCategories.items[offset]
      item.delete()
    }
  }
}

struct GoalCategoryList_Previews: PreviewProvider {
  static var previews: some View {
    GoalCategoryList(query: "", editingItem: .constant(nil), showingFormScreen: .constant(false))
  }
}
