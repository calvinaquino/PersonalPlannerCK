//
//  Toolbar.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct Toolbar<Content: View>: View {
  
  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }
  
  var content: () -> Content
  
  var body: some View {
    HStack {
      self.content()
    }
    .frame(width: nil, height: 44, alignment: .center)
    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
    .background(Color(.systemGray6).blur(radius: 5))
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

