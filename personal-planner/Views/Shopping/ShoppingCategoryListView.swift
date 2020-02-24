//
//  ShoppingCategoryListView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-23.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct ShoppingCategoryListView: View {
   @FetchRequest(fetchRequest: ShoppingCategory.allFetchRequest()) var items: FetchedResults<ShoppingCategory>
   @State private var showingFormScreen = false
   @State private var editingItem: ShoppingCategory?
   @State private var searchText: String = ""
   
   var body: some View {
     NavigationView {
       VStack {
         SearchBar(searchText: self.$searchText)
         List {
           ForEach(self.items) { item in
             Text(item.name)
               .onTapGesture {
                 self.editingItem = item
                 self.showingFormScreen.toggle()
               }
           }
           .onDelete(perform: self.delete)
         }
       }
       .navigationBarTitle("Categories", displayMode: .inline)
       .navigationBarItems(trailing: Button(action: {
         self.showingFormScreen.toggle()
       }) {
         Image(systemName: "plus")
       })
         .sheet(isPresented: $showingFormScreen, onDismiss: {
           self.editingItem = nil
         }) {
           ShoppingCategoryFormView(with: self.editingItem).environment(\.managedObjectContext, Store.context)
       }
     }
   }
   
   func delete(at offsets: IndexSet) {
     for offset in offsets {
       let item = self.items[offset]
       Store.context.delete(item)
     }
     Store.save()
   }
}

struct ShoppingCategoryListView_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingCategoryListView()
  }
}
