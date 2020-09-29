//
//  GoalItemRow.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-04-04.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct GoalItemRow: View {
  var item: GoalItem!
  var onTapAction: ((_ item: GoalItem) -> Void)?
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

struct GoalItemRow_Previews: PreviewProvider {
  static var item: GoalItem = {
    var _item = GoalItem()
    _item.name = "Cueca"
    _item.description = "Underwear"
    _item.price = 9.99
    _item.instalments = 1
    return _item
  }()
  static var previews: some View {
    GoalItemRow(item: item, onTapAction: { print($0.name) })
  }
}
