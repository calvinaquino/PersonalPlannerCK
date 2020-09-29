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
  @State private var editingItem: TransactionItem? = nil
  @State private var showingFormScreen = false
  @State private var showingAlert = false
  @State private var searchText: String = ""
  @State private var total: Double = 0.0
  
  func showFormScreen() {
    self.editingItem = nil
    self.showingFormScreen.toggle()
  }
  
  func totalForMonth() -> String {
    return self.total.stringCurrencyValue
  }
  
  func nextMonth() {
    self.viewingDate.nextMonth()
    self.total = 0.0
  }
  
  func previousMonth() {
    self.viewingDate.previousMonth()
    self.total = 0.0
  }
  
  func refresh() {
    Cloud.fetchTransactionCategories{}
    Cloud.fetchTransactionItems(for: self.viewingDate){}
  }
  
  func sendToNextMonth() {
    let item = TransactionItem()
    item.name = "Sobra mês anterior"
    item.value = self.total
    item.isInflow = true
    item.date.day = 1
    item.date.month = self.viewingDate.month + 1
    item.date.year = self.viewingDate.year
    item.save()
  }
  
  var body: some View {
    StackNavigationView {
      VStack(alignment: .center, spacing: 0) {
        HStack {
          SearchBar(searchText: self.$searchText)
          if searchText.isEmpty {
            RefreshButton(action: self.refresh)
          }
        }
        TransactionItemList(
          date: self.viewingDate,
          total: self.$total,
          query: self.searchText,
          editingItem: self.$editingItem,
          showingFormScreen: self.$showingFormScreen
        )
      }
      .toolbar(content: {
        ToolbarItemGroup(placement: .bottomBar) {
          Button(action: self.previousMonth) {
            IconButton(systemIcon: "chevron.left")
          }
          Spacer()
          MonthPicker(currentDate: $viewingDate)
          Spacer()
          Button(action: {
            self.showingAlert.toggle()
          }) {
            Text(self.totalForMonth())
          }
          Spacer()
          Button(action: self.nextMonth) {
            IconButton(systemIcon: "chevron.right")
          }
        }
      })
      .navigationBarTitle("Finanças", displayMode: .inline)
      .navigationBarItems(leading: NavigationLink(destination: TransactionCategoryListView()) {
        IconButton(systemIcon: "folder")
      }, trailing: Button(action: self.showFormScreen) {
        IconButton(systemIcon: "plus")
      })
      .alert(isPresented: self.$showingAlert) {
        Alert(title: Text("Atenção"), message: Text("Gostaria de enviar \(self.total.stringCurrencyValue) como sobra para o próximo mês?"), primaryButton: .default(Text("Sim"), action: self.sendToNextMonth), secondaryButton: .cancel(Text("Não")))
      }
    }
    .sheet(isPresented: $showingFormScreen) {
      TransactionItemFormView(with: self.$editingItem.wrappedValue, date: self.viewingDate)
    }
  }
}

struct TransactionItemListView_Previews: PreviewProvider {
  static var previews: some View {
    Mock.mockTransactions()
    return TransactionItemListView()
  }
}
