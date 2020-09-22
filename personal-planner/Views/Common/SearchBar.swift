//
//  SearchBar.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-21.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct SearchBar : View {
  @Binding var searchText: String
  
  var body: some View {
    HStack {
      Image(systemName: "magnifyingglass").foregroundColor(.secondary)
      TextField("Search", text: self.$searchText)
      Button(action: {
        self.searchText = ""
      }) {
        Image(systemName: "xmark.circle.fill").foregroundColor(.secondary).opacity(searchText == "" ? 0.0 : 1.0)
      }
    }
    .padding(.horizontal)
    .frame(width: nil, height: 50, alignment: .center)
  }
}

let searchText = "query"
struct SearchBar_Previews: PreviewProvider {
  static var previews: some View {
    SearchBar(searchText: .constant("Hey"))
  }
}
