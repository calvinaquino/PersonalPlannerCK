//
//  RoundedRow.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-09-22.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct RoundedRow: ViewModifier {
  func body(content: Content) -> some View {
    content
      .foregroundColor(.primary)
      .padding()
      .background(Color.systemGray5)
      .cornerRadius(10)
  }
}

extension View {
  func roundedRow() -> some View {
    modifier(RoundedRow())
  }
}

struct RoundedRow_Previews: PreviewProvider {
  static var previews: some View {
    HStack {
      Text("Item")
      Spacer()
      Text("0.00")
    }
      .roundedRow()
      .previewLayout(.fixed(width: 350, height: 70))
    HStack {
      Text("Item")
      Spacer()
      Text("0.00")
    }
      .roundedRow()
      .previewLayout(.fixed(width: 350, height: 70))
      .colorScheme(.dark)
  }
}
