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
            let itemMatch = searchText.isEmpty || transaction.itemDescription.localizedStandardContains(searchText)
            let storeNameMatch = searchText.isEmpty || transaction.storeName.localizedStandardContains(searchText)
            let storeLocationMatch = searchText.isEmpty || transaction.storeLocation.localizedStandardContains(searchText)
            let dateMatch = !filterByDate || Calendar.current.isDate(transaction.transactionDate, inSameDayAs: selectedDate)
            return (itemMatch || storeNameMatch || storeLocationMatch) && dateMatch
        }
        print("Filtered transactions count: \(filtered.count)") // Debugging output
        return filtered
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Search Criteria Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Search Criteria")
                            .font(.headline)
                        
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
                        
                        Toggle("Filter by Date", isOn: $filterByDate)
                        
                        if filterByDate {
                            DatePicker("Transaction Date", selection: $selectedDate, displayedComponents: .date)
                        }
                    }
                    .padding()
                    
                    // Transaction List with default styling
                    List(filteredTransactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
                .padding()
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
