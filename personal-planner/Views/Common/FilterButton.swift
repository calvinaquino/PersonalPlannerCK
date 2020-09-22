//
//  FilterButton.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-08.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct FilterButton : View {
  
  private let activeImageName = "line.horizontal.3.decrease.circle.fill"
  private let inactiveImageName = "line.horizontal.3.decrease.circle"
  
  @Binding var isActive: Bool
  @State private var rotation: Double = 0
  var action: () -> Void
  
  var body: some View {
    Button(action: {
      self.action()
    }) {
      Image(systemName: isActive ? activeImageName : inactiveImageName)
        .contentShape(Rectangle())
        .animation(Animation.linear, value: self.isActive)
        .padding()
    }
    .frame(width: 50.0, height: 50.0, alignment: .center)
  }
}

struct FilterButton_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      FilterButton(isActive: .constant(true), action: {})
      FilterButton(isActive: .constant(false), action: {})
    }
  }
}
