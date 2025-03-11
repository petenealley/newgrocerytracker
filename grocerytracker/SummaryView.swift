//
//  SummaryView.swift
//  grocerytracker
//
//  Created by Pete Nealley on 3/11/25.
//
import SwiftUI
import SwiftData

struct SummaryView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Apply pastel pink background across the entire screen
                Color.pastelPink
                    .ignoresSafeArea()
                
                // Main content with semi-transparent white background for contrast
                ProductFamilySummaryView()
                    .background(Color.white.opacity(0.8)) // Semi-transparent white for readability
                    .cornerRadius(10)
                    .padding()
            }
            .navigationTitle("Summary")
        }
    }
}

struct ProductFamilySummaryView: View {
    @Query var transactions: [Transaction]
    
    var summaryData: [String: [(item: String, transaction: Transaction)]] {
        // Group transactions by product family
        let groupedByFamily = Dictionary(grouping: transactions, by: { $0.productFamily })
        
        var result: [String: [(item: String, transaction: Transaction)]] = [:]
        
        for (family, familyTransactions) in groupedByFamily {
            // Group transactions within this family by item description
            let groupedByItem = Dictionary(grouping: familyTransactions, by: { $0.itemDescription })
            
            var items: [(item: String, transaction: Transaction)] = []
            
            for (item, itemTransactions) in groupedByItem {
                // Filter out transactions with quantity <= 0 to avoid division by zero
                let validTransactions = itemTransactions.filter { $0.quantity > 0 }
                if let minTransaction = validTransactions.min(by: { ($0.pricePaid / $0.quantity) < ($1.pricePaid / $1.quantity) }) {
                    items.append((item: item, transaction: minTransaction))
                }
            }
            
            // Sort items alphabetically by item description
            items.sort { $0.item < $1.item }
            result[family] = items
        }
        
        return result
    }
    
    var body: some View {
        List {
            // Iterate over product families in alphabetical order
            ForEach(Array(summaryData.keys).sorted(), id: \.self) { family in
                Section(header: Text(family)) {
                    // Iterate over items within this family
                    ForEach(summaryData[family]!, id: \.transaction.id) { itemData in
                        TransactionRow(transaction: itemData.transaction)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Lowest Cost per Unit by Item")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct FamilyDetailView: View {
    let family: String
    let transactions: [Transaction]
    
    var body: some View {
        List(transactions) { transaction in
            TransactionRow(transaction: transaction)
        }
        .navigationTitle(family)
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
            .modelContainer(for: Transaction.self, inMemory: true)
    }
}
