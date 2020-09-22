//
//  StackNavigationView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-09-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct StackNavigationView<Content: View>: View {
  var content: () -> Content
  
  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }
  
  var body: some View {
    NavigationView {
      self.content()
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

//struct StackNavigationView_Previews: PreviewProvider {
//  static var previews: some View {
//    StackNavigationView()
//  }
//}
