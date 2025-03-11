//
//  SearchView.swift
//  grocerytracker
//
//  Created by Pete Nealley on 3/10/25.
//
import SwiftUI
import SwiftData

struct SearchView: View {
    @Query(sort: \Transaction.transactionDate, order: .reverse) var transactions: [Transaction]
    @State private var searchText = ""
    @State private var filterByDate = false
    @State private var selectedDate = Date()
    
    var filteredTransactions: [Transaction] {
        let filtered = transactions.filter { transaction in
            // Search text condition: true if empty or matches any field
            let searchMatch = searchText.isEmpty ||
            transaction.itemDescription.localizedStandardContains(searchText) ||
            transaction.storeName.localizedStandardContains(searchText) ||
            transaction.storeLocation.localizedStandardContains(searchText)
            // Date condition: true if filter is off or dates match
            let dateMatch = !filterByDate || Calendar.current.isDate(transaction.transactionDate, inSameDayAs: selectedDate)
            // Combine conditions: transaction must satisfy both
            return searchMatch && dateMatch
        }
        print("Filtered transactions count: \(filtered.count)") // Debugging output
        return filtered
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Input with Clear Button
                HStack {
                    TextField("Search (Item, Store, Location)", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    if !searchText.isEmpty || filterByDate {
                        Button(action: clearSearch) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                
                // Date Filter Toggle
                Toggle("Filter by Date", isOn: $filterByDate)
                    .padding(.horizontal)
                
                // Date Picker (shown only when filterByDate is true)
                if filterByDate {
                    DatePicker("Transaction Date", selection: $selectedDate, displayedComponents: .date)
                        .padding(.horizontal)
                }
                
                // Transaction List
                List(filteredTransactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
            .navigationTitle("Search")
        }
    }
    
    private func clearSearch() {
        searchText = ""
        filterByDate = false
        selectedDate = Date()
    }
}
