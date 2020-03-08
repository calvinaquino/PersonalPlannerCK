//
//  TransactionItemRow.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-08.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct TransactionItemRow: View {
  var item: TransactionItem!
  var onTapAction: ((_ item: TransactionItem) -> Void)?
    var body: some View {
        HStack {
          Text(item.name)
          Spacer()
          Text(item.valueSigned.stringCurrencyValue)
        }
        .contentShape(Rectangle())
        .onTapGesture {
          self.onTapAction?(self.item)
        }
    }
}

struct TransactionItemRow_Previews: PreviewProvider {
  static var item: TransactionItem = {
    var _item = TransactionItem()
    _item.name = "Cueca"
    _item.value = 9.99
    _item.date = Date()
    return _item
  }()
    static var previews: some View {
      TransactionItemRow(item: item) { print($0.name) }
    }
}
