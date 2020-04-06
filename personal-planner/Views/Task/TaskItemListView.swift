//
//  TaskItemListView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-04-04.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Combine
import SwiftUI

struct TaskItemListView: View {
  
  @State private var showingFormScreen = false
  @State private var editingItem: TaskItem? = nil
  @State private var searchText: String = ""
  @State private var isActive = false
  
  var body: some View {
    NavigationView {
      VStack {
        HStack {
          SearchBar(searchText: self.$searchText)
          if searchText.isEmpty {
            FilterButton(isActive: self.$isActive) {
              self.isActive.toggle()
            }
            RefreshButton(action: {
              Cloud.fetchTaskCategories { }
              Cloud.fetchTaskItems { }
            })
          }
        }
        TaskItemList(
          query: searchText,
          editingItem: self.$editingItem,
          isFiltering: self.$isActive,
          showingFormScreen: self.$showingFormScreen
        )
      }
      .navigationBarTitle("Tarefas", displayMode: .inline)
      .navigationBarItems(leading: NavigationLink(destination: TaskCategoryListView()) {
//        Image(systemName: "folder")
        Text("Categorias")
        }, trailing: Button(action: {
          self.editingItem = nil
          self.showingFormScreen.toggle()
        }) {
//        Image(systemName: "plus")
          Text("Novo")
      })
    }
    .sheet(isPresented: $showingFormScreen) {
      TaskItemFormView(with: self.$editingItem.wrappedValue)
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

struct TaskItemListView_Previews: PreviewProvider {
  static var previews: some View {
    TaskItemListView()
  }
}
