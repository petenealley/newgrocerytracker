//
//  TransactionListView.swift
//  grocerytracker
//
//  Created by Pete Nealley on 3/10/25.
//
import SwiftUI
import SwiftData
import UIKit

struct TransactionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.transactionDate, order: .reverse) var transactions: [Transaction]
    @State private var transactionToDelete: Transaction? = nil
    @State private var showDeleteConfirmation = false
    @State private var showingDocumentPicker = false
    @State private var showingShareSheet = false
    @State private var showingConfirmation = false
    @State private var importedTransactions: [Transaction]?
    @State private var csvFileURL: URL?
    
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
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button("Import CSV") {
                                showingDocumentPicker = true
                            }
                            Button("Export CSV") {
                                exportCSV()
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                .sheet(isPresented: $showingDocumentPicker) {
                    DocumentPicker { url in
                        parseCSV(url: url)
                    }
                }
                .sheet(isPresented: $showingShareSheet) {
                    if let url = csvFileURL {
                        ShareSheet(activityItems: [url])
                    }
                }
                .confirmationDialog("Found \(importedTransactions?.count ?? 0) transactions to import. Replace existing data?", isPresented: $showingConfirmation) {
                    Button("Replace", role: .destructive) {
                        replaceData()
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
            .confirmationDialog(
                "Are you sure you want to delete this transaction?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    if let transaction = transactionToDelete {
                        modelContext.delete(transaction)
                        do {
                            try modelContext.save()
                        } catch {
                            print("Error deleting transaction: \(error)")
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
    
    /// Parses the selected CSV file and prepares transactions for import.
    private func parseCSV(url: URL) {
        do {
            let data = try String(contentsOf: url)
            let lines = data.components(separatedBy: .newlines)
            guard lines.count > 1 else { return } // Ensure there's at least a header and one data row
            let headers = lines[0].components(separatedBy: ",")
            // Expected headers: itemDescription,quantity,unitOfMeasure,productFamily,pricePaid,transactionDate,storeName,storeLocation,brandName
            var transactions: [Transaction] = []
            for line in lines.dropFirst() where !line.isEmpty {
                let fields = line.components(separatedBy: ",")
                if fields.count == 9 {
                    let itemDescription = fields[0]
                    let quantity = Double(fields[1]) ?? 0
                    let unitOfMeasure = fields[2]
                    let productFamily = fields[3]
                    let pricePaid = Double(fields[4]) ?? 0
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let transactionDate = dateFormatter.date(from: fields[5]) ?? Date()
                    let storeName = fields[6]
                    let storeLocation = fields[7]
                    let brandName = fields[8].isEmpty ? nil : fields[8]
                    let transaction = Transaction(
                        id: UUID(),
                        itemDescription: itemDescription,
                        quantity: quantity,
                        unitOfMeasure: unitOfMeasure,
                        productFamily: productFamily,
                        pricePaid: pricePaid,
                        transactionDate: transactionDate,
                        storeName: storeName,
                        storeLocation: storeLocation,
                        brandName: brandName
                    )
                    transactions.append(transaction)
                }
            }
            importedTransactions = transactions
            showingConfirmation = true
        } catch {
            print("Error reading CSV file: \(error)")
        }
    }
    
    /// Replaces existing transactions with the imported ones.
    private func replaceData() {
        if let newTransactions = importedTransactions {
            let fetchRequest = FetchDescriptor<Transaction>()
            do {
                let existing = try modelContext.fetch(fetchRequest)
                for transaction in existing {
                    modelContext.delete(transaction)
                }
                for transaction in newTransactions {
                    modelContext.insert(transaction)
                }
                try modelContext.save()
                importedTransactions = nil
            } catch {
                print("Error replacing data: \(error)")
            }
        }
    }
    
    /// Exports current transactions to a CSV file and triggers the share sheet.
    private func exportCSV() {
        let fetchRequest = FetchDescriptor<Transaction>()
        do {
            let transactions = try modelContext.fetch(fetchRequest)
            guard !transactions.isEmpty else {
                print("No transactions to export")
                return
            }
            var csvString = "itemDescription,quantity,unitOfMeasure,productFamily,pricePaid,transactionDate,storeName,storeLocation,brandName\n"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            for transaction in transactions {
                let brand = transaction.brandName ?? ""
                let dateString = dateFormatter.string(from: transaction.transactionDate)
                let line = [
                    transaction.itemDescription,
                    String(transaction.quantity),
                    transaction.unitOfMeasure,
                    transaction.productFamily,
                    String(transaction.pricePaid),
                    dateString,
                    transaction.storeName,
                    transaction.storeLocation,
                    brand
                ].joined(separator: ",")
                csvString += line + "\n"
            }
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("transactions.csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            csvFileURL = fileURL
            showingShareSheet = true
        } catch {
            print("Error exporting CSV: \(error)")
        }
    }
}

/// Represents the UIKit document picker for selecting a CSV file.
struct DocumentPicker: UIViewControllerRepresentable {
    var callback: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.commaSeparatedText])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                parent.callback(url)
            }
        }
    }
}

/// Represents the UIKit share sheet for sharing the CSV file.
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
