//
//  RefreshButton.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-03-04.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct RefreshButton : View {
  
  @State private var rotation: Double = 0
  var action: () -> Void
  
  var body: some View {
    Button(action: {
      self.action()
      self.rotation += 360
    }) {
      Image(systemName: "arrow.2.circlepath")
        .contentShape(Rectangle())
        .rotationEffect(.degrees(self.rotation))
        .animation(Animation.linear, value: self.rotation)
        .padding()
    }
    .frame(width: 50.0, height: 50.0, alignment: .center)
  }
}

struct RefreshButton_Previews: PreviewProvider {
  static var previews: some View {
    RefreshButton(action: {})
  }
}
