//
//  MonhPicker.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-09-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct MonthPicker: View {
  @Binding var currentDate: Date
  
  func getMonthName(for index: Int) -> String {
    DateFormatter().monthSymbols[index]
  }
  
  func isCurrent(_ monthIndex: Int) -> Bool {
    (monthIndex + 1) == currentDate.month
  }
  
  var body: some View {
    Menu(self.currentDate.currentMonthAndYear()) {
      ForEach(0...11, id: \.self) { monthIndex in
        Button {
          self.currentDate.month = monthIndex + 1
        } label: {
          HStack {
            Text(self.getMonthName(for: monthIndex))
            if self.isCurrent(monthIndex) {
              Image(systemName: "checkmark")
            }
          }
        }
      }
    }
  }
}

struct MonthPicker_Previews: PreviewProvider {
  static var previews: some View {
    MonthPicker(currentDate: .constant(Date()))
      .previewLayout(.sizeThatFits)
  }
}
