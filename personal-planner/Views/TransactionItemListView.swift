//
//  TransactionItemListView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct TransactionItemListView: View {
  
  @FetchRequest(fetchRequest: TransactionItem.allFetchRequest()) var transactionItems: FetchedResults<TransactionItem>
  
  var body: some View {
    NavigationView {
      VStack {
        List(self.transactionItems) { item in
          HStack {
            Text(item.name)
            Spacer()
            Text(String(item.value))
          }
        }
        Toolbar {
          Button(action: {}) {
            Image(systemName: "chevron.left")
          }
          Spacer()
          Button(action: {}) {
            Image(systemName: "chevron.right")
          }
        }
      }
      .navigationBarTitle("Finanças", displayMode: .inline)
      .navigationBarItems(trailing: Button(action: {
        print("HEY")
      }) {
        Image(systemName: "plus")
      })
    }
  }
}

struct TransactionItemListView_Previews: PreviewProvider {
  static var previews: some View {
    TransactionItemListView()
  }
}
