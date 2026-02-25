//
//  GoalItemFormView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-04-04.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation

import Combine
import SwiftUI

struct GoalItemFormView: View {
    
    init() {
        self.init(with: FormViewManager.shared.goalItemForm.editingItem)
    }
    
    init(with goalItem: GoalItem?) {
        self.item = goalItem
        _name = State(initialValue: item?.name ?? "")
        _description = State(initialValue: item?.description ?? "")
        _price = State(initialValue: item?.price.stringValue ?? "")
        _instalments = State(initialValue: item?.instalments ?? 1)
        _category = State(initialValue: item?.category ?? nil)
    }
    
    private var item: GoalItem?
    
    @State private var categories = GoalCategories.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var description: String
    @State private var price: String
    @State private var instalments: Int
    @State private var category: GoalCategory?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nome", text: $name)
                        .autocapitalization(.sentences)
                    TextField("Descrição", text: $description)
                    TextField("Preço", text: $price)
                        .keyboardType(.decimalPad)
                    //          TextField("Parcelaa", text: $instalments) // slider?
                    HStack {
                        Picker("Categoria", selection: $category) {
                            ForEach(categories.items, id: \.id) { item in
                                Text(item.name).tag(item as GoalCategory?)
                            }
                            Text("Geral").tag(nil as GoalCategory?)
                        }
                        .pickerStyle(MenuPickerStyle())
                        Spacer()
                        Text(category?.name ?? "Geral")
                    }
                }
            }
            .navigationBarTitle(self.item != nil ? "Editar item" : "Novo item", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Text("Cancelar")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { self.save()}) {
                        Text("Salvar")
                    }
                }
            }
        }
    }
    
    func save() {
        let editingItem = self.item ?? GoalItem()
        editingItem.name = self.name
        editingItem.description = self.description
        editingItem.price = self.price.doubleValue
        editingItem.instalments = self.instalments
        editingItem.category = self.category
        editingItem.save()
        dismiss()
    }
}

struct GoalItemFormView_Previews: PreviewProvider {
    static var previews: some View {
        GoalItemFormView()
    }
}
