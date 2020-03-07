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
  @State private var showingAlert = false
  @State private var searchText: String = ""
  @State private var total: Double = 0.0
  
  var body: some View {
    NavigationView {
      VStack {
        SearchBar(searchText: self.$searchText)
        TransactionItemList(date: self.viewingDate, total: self.$total, query: self.searchText)
        .sheet(isPresented: $showingFormScreen) {
          TransactionItemFormView(with: nil, date: self.viewingDate)
        }
        Toolbar {
          Button(action: {
            self.viewingDate.previousMonth()
            self.total = 0.0
          }) {
            Image(systemName: "chevron.left")
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
          }
        }
      }
      .navigationBarTitle("Finanças", displayMode: .inline)
      .navigationBarItems(leading: NavigationLink(destination: TransactionCategoryListView()) {
//        Image(systemName: "folder")
        Text("Categorias")
      }, trailing: Button(action: { self.showingFormScreen.toggle() }) {
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
