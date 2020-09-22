//
//  NavigaionIcon.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-09-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct IconButton: View {
  let size: CGFloat = 30;
  @State var systemIcon: String
  @State var alignment: Alignment = .center
    var body: some View {
      Image(systemName: self.systemIcon)
        .frame(width: self.size, height: self.size, alignment: self.alignment)
    }
}

struct NavigationIcon_Previews: PreviewProvider {
    static var previews: some View {
      IconButton(systemIcon: "plus")
        .previewLayout(.sizeThatFits)
      IconButton(systemIcon: "folder")
        .previewLayout(.sizeThatFits)
    }
}
