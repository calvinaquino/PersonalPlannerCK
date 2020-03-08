//
//  Toolbar.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct Toolbar<Content>: View where Content : View {
  
  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }
  
  var content: () -> Content
  
  var body: some View {
    ZStack {
      Color(.systemGray6)
      HStack {
        self.content()
      }
      .frame(width: nil, height: 44, alignment: .center)
      .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
    }
    .frame(width: nil, height: 50, alignment: .center)
  }
}

struct Toolbar_Previews: PreviewProvider {
  static var previews: some View {
    Toolbar {
      Button(action: {}) {
        Image(systemName: "square.filled")
      }
      Spacer()
      Button(action: {}) {
        Image(systemName: "square")
      }
    }
  }
}

