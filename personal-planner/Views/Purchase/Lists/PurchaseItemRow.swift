//
//  PurchaseItemRow.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-04-04.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct PurchaseItemRow: View {
  var item: PurchaseItem!
  var onTapAction: ((_ item: PurchaseItem) -> Void)?
  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(item.name)
        Text(item.description)
          .font(.subheadline)
      }
      Spacer()
      Text(item.price.stringCurrencyValue)
    }
    .contentShape(Rectangle())
    .onTapGesture {
      self.onTapAction?(self.item)
    }
  }
}

struct PurchaseItemRow_Previews: PreviewProvider {
  static var item: PurchaseItem = {
    var _item = PurchaseItem()
    _item.name = "Cueca"
    _item.description = "Underwear"
    _item.price = 9.99
    _item.instalments = 1
    return _item
  }()
  static var previews: some View {
    PurchaseItemRow(item: item, onTapAction: { print($0.name) })
  }
}
