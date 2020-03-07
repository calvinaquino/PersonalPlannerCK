//
//  ShoppingItemList.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-23.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct ShoppingItemList: View {
  
  @ObservedObject private var shoppingItems = ShoppingItems.shared
  @ObservedObject private var shoppingCategories = ShoppingCategories.shared
  
  @State private var showingFormScreen = false
  @State private var editingItem: ShoppingItem?
  //  @State private var isLoading = false
  @State private var rotation: Double = 0.0;
  
  init(query: String) {
    self.shoppingItems.query = query
  }
  
  var sections: [ShoppingSection] {
    ShoppingSection.sections(items: shoppingItems.items, categories: shoppingCategories.items)
  }
  
  var body: some View {
    List {
      ForEach(sections, id: \.id) { section in
        Section(header: HStack {
          Text(section.categoryName)
          Spacer()
          Text(section.countVersusTotal)
        }) {
          ForEach(section.items, id: \.id) { item in
            HStack {
              VStack(alignment: .leading) {
                Text(item.name)
                Text(item.localizedName)
                  .font(.subheadline)
              }
              Spacer()
              Text(item.price.stringCurrencyValue)
              Image(systemName: item.isNeeded ? "cube.box" : "cube.box.fill")
                .imageScale(.large)
                .contentShape(Rectangle())
                .frame(width: 40, height: 40, alignment: .center)
                .foregroundColor(Color(.systemBlue))
                .onTapGesture {
                  item.isNeeded.toggle()
                  item.save()
              }
            }
            .contentShape(Rectangle())
            .onTapGesture {
              self.editingItem = item
              self.showingFormScreen.toggle()
            }
          }
          .onDelete(perform: { offsets in
            self.delete(at: offsets, in: section)
          })
          if self.sections.last == section {
            Rectangle().foregroundColor(.clear)
          }
        }
      }
      .sheet(isPresented: self.$showingFormScreen, onDismiss: {
        self.editingItem = nil
      }) {
        ShoppingItemFormView(with: self.editingItem)
      }
    }
    .overlay(
      RefreshButton(action: {
        self.shoppingCategories.fetch()
        self.shoppingItems.fetch()
      })
    , alignment: .bottomTrailing)
  }
  
  func delete(at offsets: IndexSet, in section: ShoppingSection) {
    for offset in offsets {
      let item = section.items[offset]
      item.delete()
    }
  }
}

struct ShoppingItemList_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingItemList(query: "")
  }
}
