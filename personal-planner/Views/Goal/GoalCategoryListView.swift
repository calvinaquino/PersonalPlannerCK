//
//  GoalCategoryListView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-04-04.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct GoalCategoryListView: View {
    @State private var showingFormScreen = false
    @State private var searchText: String = ""
    @State private var editingItem: GoalCategory?
    
    var body: some View {
        VStack {
            GoalCategoryList(
                query: self.searchText,
                editingItem: self.$editingItem,
                showingFormScreen: self.$showingFormScreen
            )
            .searchable(text: $searchText)
        }
        .sheet(isPresented: $showingFormScreen) {
            GoalCategoryFormView(with: nil)
        }
        .navigationBarTitle("Categorias", displayMode: .inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                RefreshButton(action: {
                    Cloud.fetchGoalCategories { }
                })
                Button(action: { self.showingFormScreen.toggle() }) {
                    Text("Novo")
                }
            }
        }
    }
}

struct GoalCategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        GoalCategoryListView()
    }
}
