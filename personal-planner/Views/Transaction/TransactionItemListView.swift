//
//  TransactionItemListView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct TransactionItemListView: View {
  
  @State private var viewingDate: Date = Date()
  @State private var showingFormScreen = false
  @State private var searchText: String = ""
  @State private var total: Double = 0.0
  
  var body: some View {
    NavigationView {
      VStack {
        SearchBar(searchText: self.$searchText)
        TransactionItemList(month: self.viewingDate.month, year: self.viewingDate.year, total: self.$total, query: self.searchText)
        .sheet(isPresented: $showingFormScreen) {
            TransactionItemFormView(with: nil).environment(\.managedObjectContext, Store.context)
        }
        Toolbar {
          Button(action: {
            self.viewingDate.previousMonth()
          }) {
            Image(systemName: "chevron.left")
          }
          Spacer()
          Text(self.viewingDate.currentMonthAndYear())
          Spacer()
          Text(self.totalForMonth())
          Spacer()
          Button(action: {
            self.viewingDate.nextMonth()
          }) {
            Image(systemName: "chevron.right")
          }
        }
      }
      .navigationBarTitle("Finanças", displayMode: .inline)
      .navigationBarItems(leading: NavigationLink(destination: TransactionCategoryListView()) {
        Image(systemName: "folder")
      }, trailing: Button(action: { self.showingFormScreen.toggle() }) {
        Image(systemName: "plus")
      })
    }
  }
  
  func totalForMonth() -> String {
    return self.total.stringCurrencyValue
  }
}

struct TransactionItemListView_Previews: PreviewProvider {
  static var previews: some View {
    TransactionItemListView()
  }
}
