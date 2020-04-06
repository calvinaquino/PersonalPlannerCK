//
//  TaskItemRow.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-04-04.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct TaskItemRow: View {
  var item: TaskItem!
  var onTapAction: ((_ item: TaskItem) -> Void)?
  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(item.name)
        Text(item.description)
          .font(.subheadline)
      }
    }
    .contentShape(Rectangle())
    .onTapGesture {
      self.onTapAction?(self.item)
    }
  }
}

struct TaskItemRow_Previews: PreviewProvider {
  static var item: TaskItem = {
    var _item = TaskItem()
    _item.name = "Cueca"
    _item.description = "Underwear"
    return _item
  }()
  static var previews: some View {
    TaskItemRow(item: item, onTapAction: { print($0.name) })
  }
}
