//
//  TransactionListView.swift
//  grocerytracker
//
//  Created by Pete Nealley on 3/10/25.
//
import SwiftUI
import SwiftData

struct TransactionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.transactionDate, order: .reverse) var transactions: [Transaction]
    @State private var transactionToDelete: Transaction? = nil
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.pastelYellow.ignoresSafeArea()
                List {
                    ForEach(transactions) { transaction in
                        NavigationLink(destination: EditTransactionView(transaction: transaction)) {
                            TransactionRow(transaction: transaction)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                transactionToDelete = transaction
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listRowBackground(Color.white.opacity(0.8))
                .navigationTitle("Transactions")
            }
            .confirmationDialog(
                "Are you sure you want to delete this transaction?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let transaction = transactionToDelete {
                        withAnimation {
                            modelContext.delete(transaction)
                            do {
                                try modelContext.save()
                            } catch {
                                print("Error deleting transaction: \(error)")
                            }
                        }
                    }
                    transactionToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    transactionToDelete = nil
                }
            }
        }
    }
}

struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListView()
            .modelContainer(previewContainer)
    }
    
    static var previewContainer: ModelContainer = {
        let schema = Schema([Transaction.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: config)
        let sampleTransaction = Transaction(
            itemDescription: "Apple",
            quantity: 2,
            unitOfMeasure: "each",
            productFamily: "Produce",
            pricePaid: 1.99,
            transactionDate: Date(),
            storeName: "Safeway",
            storeLocation: "123 Main St",
            brandName: "Generic"
        )
        container.mainContext.insert(sampleTransaction)
        return container
    }()
}
