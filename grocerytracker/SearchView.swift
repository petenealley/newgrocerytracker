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
    
    // Computed property for filtered transactions
    var filteredTransactions: [Transaction] {
        transactions.filter { transaction in
            let searchMatch = searchText.isEmpty ||
            transaction.itemDescription.localizedStandardContains(searchText) ||
            transaction.storeName.localizedStandardContains(searchText) ||
            transaction.storeLocation.localizedStandardContains(searchText) ||
            (transaction.brandName ?? "").localizedStandardContains(searchText) ||
            transaction.productFamily.localizedStandardContains(searchText)
            let dateMatch = !filterByDate || Calendar.current.isDate(transaction.transactionDate, inSameDayAs: selectedDate)
            return searchMatch && dateMatch
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Apply pastel blue background across the entire screen
                Color.pastelBlue
                    .ignoresSafeArea()
                
                // Main content with semi-transparent white background for contrast
                VStack {
                    // Search input with clear button
                    HStack {
                        TextField("Search (Item, Store, Location, Brand, Family)", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        if !searchText.isEmpty || filterByDate {
                            Button(action: clearSearch) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    
                    // Date filter toggle
                    Toggle("Filter by Date", isOn: $filterByDate)
                        .padding(.horizontal)
                    
                    // Date picker (visible when filterByDate is true)
                    if filterByDate {
                        DatePicker("Transaction Date", selection: $selectedDate, displayedComponents: .date)
                            .padding(.horizontal)
                    }
                    
                    // Transaction list
                    List(filteredTransactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
                .background(Color.white.opacity(0.8)) // Semi-transparent white for readability
                .cornerRadius(10)
                .padding()
            }
            .navigationTitle("Search")
        }
    }
    
    // Clear search and reset filters
    private func clearSearch() {
        searchText = ""
        filterByDate = false
        selectedDate = Date()
    }
}

// SwiftUI Preview
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .modelContainer(for: Transaction.self, inMemory: true)
    }
}
