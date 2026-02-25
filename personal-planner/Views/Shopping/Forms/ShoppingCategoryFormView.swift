//
//  ShoppingCategoryFormView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-23.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct ShoppingCategoryFormView: View {
    init() {
        self.init(with: nil)
    }
    
    init(with shoppingCategory: ShoppingCategory?) {
        self.item = shoppingCategory
        _name = State(initialValue: item?.name ?? "")
    }
    
    private var item: ShoppingCategory?
    
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nome", text: $name)
                }
            }
            .navigationBarTitle(self.item != nil ? "Editar categoria" : "Nova categoria", displayMode: .inline)
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
        let editingItem = self.item ?? ShoppingCategory()
        editingItem.name = self.name
        editingItem.save()
        dismiss()
    }
}

struct ShoppingCategoryFormView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingCategoryFormView()
    }
}
