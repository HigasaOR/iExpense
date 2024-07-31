//
//  ContentView.swift
//  iExpense
//
//  Created by Chien Lee on 2024/7/25.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses {
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }

    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }

        items = []
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()

    @State private var showingAddExpense = false

    var body: some View {
        NavigationStack {
            List {
                Section("Business Expenses") {
                    ForEach(expenses.items.filter { $0.type == "Business" }) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.type)
                            }

                            Spacer()
                            Text(item.amount, format: .currency(code: "USD"))
                                .fontWeight(item.amount <= 10 ? .medium : .bold)
                                .foregroundStyle(item.amount <= 100 ? .black : .red)
                        }
                    }
                    .onDelete(perform: removeBusinessItems)
                }

                Section("Personal Expenses") {
                    ForEach(expenses.items.filter { $0.type == "Personal" }) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.type)
                            }

                            Spacer()
                            Text(item.amount, format: .currency(code: "USD"))
                                .fontWeight(item.amount <= 10 ? .medium : .bold)
                                .foregroundStyle(item.amount <= 100 ? .black : .red)
                        }
                    }
                    .onDelete(perform: removePersonalItems)
                }
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button("Add Expense", systemImage: "plus") {
                    showingAddExpense = true
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: expenses)
            }
        }
    }

    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }

    func removeBusinessItems(at offsets: IndexSet) {
        var k = 0
        for i in 0 ... expenses.items.count {
            if expenses.items[i].type == "Business" {
                if k == offsets.first {
                    expenses.items.remove(at: i)
                    break
                }
                k += 1
            }
        }
    }

    func removePersonalItems(at offsets: IndexSet) {
        var k = 0
        for i in 0 ... expenses.items.count {
            if expenses.items[i].type == "Personal" {
                if k == offsets.first {
                    expenses.items.remove(at: i)
                    break
                }
                k += 1
            }
        }
    }
}

#Preview {
    ContentView()
}
