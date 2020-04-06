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
  
  var body: some View {
    NavigationView {
      VStack(alignment: .center, spacing: 0) {
        HStack {
          SearchBar(searchText: self.$searchText)
          if searchText.isEmpty {
            RefreshButton(action: {
              Cloud.fetchTransactionCategories{}
              Cloud.fetchTransactionItems(for: self.viewingDate){}
            })
          }
        }
        TransactionItemList(
          date: self.viewingDate,
          total: self.$total,
          query: self.searchText,
          editingItem: self.$editingItem,
          showingFormScreen: self.$showingFormScreen
        )
        Toolbar {
          Button(action: {
            self.viewingDate.previousMonth()
            self.total = 0.0
          }) {
            Image(systemName: "chevron.left")
            .frame(width: 30, height: 30, alignment: .center)
            .contentShape(Rectangle())
          }
          Spacer()
          Text(self.viewingDate.currentMonthAndYear())
          Spacer()
          Button(action: {
            self.showingAlert.toggle()
          }) {
            Text(self.totalForMonth())
          }
          Spacer()
          Button(action: {
            self.viewingDate.nextMonth()
            self.total = 0.0
          }) {
            Image(systemName: "chevron.right")
            .frame(width: 30, height: 30, alignment: .center)
            .contentShape(Rectangle())
          }
        }
      }
      .navigationBarTitle("Finanças", displayMode: .inline)
      .navigationBarItems(leading: NavigationLink(destination: TransactionCategoryListView()) {
//        Image(systemName: "folder")
        Text("Categorias")
      }, trailing: Button(action: {
        self.editingItem = nil
        self.showingFormScreen.toggle()
      }) {
//        Image(systemName: "plus")
        Text("Novo")
      })
      .alert(isPresented: self.$showingAlert) {
        Alert(title: Text("Atenção"), message: Text("Gostaria de enviar \(self.total.stringCurrencyValue) como sobra para o próximo mês?"), primaryButton: .default(Text("Sim"), action: {
          // create new events
          let item = TransactionItem()
          item.name = "Sobra mês anterior"
          item.value = self.total
          item.isInflow = true
          item.date.day = 1
          item.date.month = self.viewingDate.month + 1
          item.date.year = self.viewingDate.year
          item.save()
        }), secondaryButton: .cancel(Text("Não")))
      }
    }
    .sheet(isPresented: $showingFormScreen) {
      TransactionItemFormView(with: self.$editingItem.wrappedValue, date: self.viewingDate)
    }
    .navigationViewStyle(StackNavigationViewStyle())
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
