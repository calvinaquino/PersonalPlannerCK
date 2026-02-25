//
//  TransactionCategoryFormView.swift
//  personal-planner
//
//  Created by Calvin De Aquino on 2020-02-23.
//  Copyright © 2020 Calvin Aquino. All rights reserved.
//

import SwiftUI

struct TransactionCategoryFormView: View {
    init() {
        self.init(with: nil)
    }
    
    init(with transactionCategory: TransactionCategory?) {
        self.item = transactionCategory
        _name = State(initialValue: item?.name ?? "")
        _budget = State(initialValue: item?.budget.stringCurrencyValue ?? "")
    }
    
    private var item: TransactionCategory?
    
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String
    @State private var budget: String
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nome", text: $name)
                    TextField("Orçamento", text: $budget)
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
        let editingItem = self.item ?? TransactionCategory()
        editingItem.name = self.name
        editingItem.budget = self.budget.doubleValue
        editingItem.save()
        dismiss()
    }
}

struct TransactionCategoryFormView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionCategoryFormView()
    }
}
