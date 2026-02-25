//
//  ShoppingItemFormView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-22.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import Foundation

import Combine
import SwiftUI

struct ShoppingItemFormView: View {
    
    init() {
        self.init(with: FormViewManager.shared.shoppingItemForm.editingItem)
    }
    
    init(with shoppingItem: ShoppingItem?) {
        self.item = shoppingItem
        _name = State(initialValue: item?.name ?? "")
        _localizedName = State(initialValue: item?.localizedName ?? "")
        _price = State(initialValue: item?.price.stringValue ?? "")
        _isNeeded = State(initialValue: item?.isNeeded ?? true)
        _category = State(initialValue: item?.category ?? nil)
    }
    
    private var item: ShoppingItem?
    
    @State private var categories = ShoppingCategories.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var localizedName: String
    @State private var price: String
    @State private var isNeeded: Bool
    @State private var category: ShoppingCategory?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nome", text: $name)
                        .autocapitalization(.sentences)
                    TextField("Nome em inglês", text: $localizedName)
                    TextField("Preço", text: $price)
                        .keyboardType(.decimalPad)
                    Toggle("Em falta", isOn: $isNeeded)
                    HStack {
                        Picker("Categoria", selection: $category) {
                            ForEach(categories.items, id: \.id) { item in
                                Text(item.name).tag(item as ShoppingCategory?)
                            }
                            Text("Geral").tag(nil as ShoppingCategory?)
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
        let editingItem = self.item ?? ShoppingItem()
        editingItem.name = self.name
        editingItem.localizedName = self.localizedName
        editingItem.price = self.price.doubleValue
        editingItem.isNeeded = self.isNeeded
        editingItem.category = self.category
        editingItem.save()
        dismiss()
    }
}

struct ShoppingItemFormView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingItemFormView()
    }
}
