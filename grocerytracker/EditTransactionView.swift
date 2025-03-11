//
//  EditTransactionView.swift
//  grocerytracker
//
//  Created by Pete Nealley on 3/10/25.
//
import SwiftUI
import SwiftData

struct EditTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var itemDescription: String
    @State private var quantity: String
    @State private var unitOfMeasure: String
    @State private var productFamily: String
    @State private var pricePaid: String
    @State private var transactionDate: Date
    @State private var storeName: String
    @State private var storeLocation: String
    @State private var brandName: String
    @State private var showAlert = false
    
    let transaction: Transaction
    
    init(transaction: Transaction) {
        self.transaction = transaction
        _itemDescription = State(initialValue: transaction.itemDescription)
        _quantity = State(initialValue: String(transaction.quantity))
        _unitOfMeasure = State(initialValue: transaction.unitOfMeasure)
        _productFamily = State(initialValue: transaction.productFamily)
        _pricePaid = State(initialValue: String(transaction.pricePaid))
        _transactionDate = State(initialValue: transaction.transactionDate)
        _storeName = State(initialValue: transaction.storeName)
        _storeLocation = State(initialValue: transaction.storeLocation)
        _brandName = State(initialValue: transaction.brandName ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Description", text: $itemDescription)
                    TextField("Quantity (e.g., 2)", text: $quantity)
                        .keyboardType(.decimalPad)
                    TextField("Unit (e.g., each, pound)", text: $unitOfMeasure)
                    TextField("Product Family", text: $productFamily)
                }
                Section(header: Text("Price and Date")) {
                    TextField("Price Paid (e.g., 5.99)", text: $pricePaid)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $transactionDate, displayedComponents: .date)
                }
                Section(header: Text("Store Details")) {
                    TextField("Store Name", text: $storeName)
                    TextField("Store Location", text: $storeLocation)
                }
                Section(header: Text("Optional")) {
                    TextField("Brand Name", text: $brandName)
                }
                Button("Save Changes") {
                    saveChanges()
                }
            }
            .navigationTitle("Edit Transaction")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Input"), message: Text("Please fill in all required fields with valid data."), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func saveChanges() {
        guard !itemDescription.isEmpty,
              let quantityDouble = Double(quantity),
              !unitOfMeasure.isEmpty,
              !productFamily.isEmpty,
              let priceDouble = Double(pricePaid),
              !storeName.isEmpty,
              !storeLocation.isEmpty else {
            showAlert = true
            return
        }
        
        transaction.itemDescription = itemDescription
        transaction.quantity = quantityDouble
        transaction.unitOfMeasure = unitOfMeasure
        transaction.productFamily = productFamily
        transaction.pricePaid = priceDouble
        transaction.transactionDate = transactionDate
        transaction.storeName = storeName
        transaction.storeLocation = storeLocation
        transaction.brandName = brandName.isEmpty ? nil : brandName
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving changes: \(error)")
            showAlert = true
        }
    }
}

struct EditTransactionView_Previews: PreviewProvider {
    static var previews: some View {
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
        EditTransactionView(transaction: sampleTransaction)
            .modelContainer(for: Transaction.self, inMemory: true)
    }
}
