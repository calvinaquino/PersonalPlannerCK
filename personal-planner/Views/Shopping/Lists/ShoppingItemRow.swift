//
//  ShoppingItemRow.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-08.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct ShoppingItemRow: View {
  var item: ShoppingItem!
  var onTapAction: ((_ item: ShoppingItem) -> Void)?
  var body: some View {
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
          self.item.isNeeded.toggle()
          self.item.save()
      }
    }
    .contentShape(Rectangle())
    .onTapGesture {
      self.onTapAction?(self.item)
    }
  }
}

struct ShoppingItemRow_Previews: PreviewProvider {
  static var item: ShoppingItem = {
    var _item = ShoppingItem()
    _item.name = "Cueca"
    _item.localizedName = "Underwear"
    _item.price = 9.99
    _item.isNeeded = true
    return _item
  }()
  static var previews: some View {
    ShoppingItemRow(item: item, onTapAction: { print($0.name) })
  }
}
