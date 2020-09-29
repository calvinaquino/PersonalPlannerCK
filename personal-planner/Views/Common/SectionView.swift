//
//  SectionView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-09-22.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct SectionView: View {
  var title: String
  var rightText: String? = nil
  var body: some View {
    HStack {
      Text(self.title)
        .fontWeight(.bold)
      Spacer()
      if let rightText = self.rightText {
        Text(rightText)
          .fontWeight(.bold)
      }
    }
  }
}

struct SectionView_Previews: PreviewProvider {
  static var previews: some View {
    SectionView(title: "GERAL", rightText: "0.00 / 100.00")
      .previewLayout(.fixed(width: 350, height: 70))
    SectionView(title: "GERAL")
      .previewLayout(.fixed(width: 350, height: 70))
    SectionView(title: "GERAL", rightText: "0.00 / 100.00")
      .previewLayout(.fixed(width: 350, height: 70))
      .colorScheme(.dark)
    SectionView(title: "GERAL")
      .previewLayout(.fixed(width: 350, height: 70))
      .colorScheme(.dark)
  }
}
