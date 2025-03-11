//
//  AddTransactionView.swift
//  grocerytracker
//
//  Created by Pete Nealley on 3/11/25.
//
import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var itemDescription = ""
    @State private var quantity = ""
    @State private var unitOfMeasure = ""
    @State private var productFamily = ""
    @State private var pricePaid = ""
    @State private var transactionDate = Date()
    @State private var storeName = ""
    @State private var storeLocation = ""
    @State private var brandName = ""
    @State private var showAlert = false
    
    // Computed property to calculate unit price
    private var unitPrice: String {
        guard let quantityDouble = Double(quantity),
              let priceDouble = Double(pricePaid),
              quantityDouble > 0 else {
            return "N/A"
        }
        let unitPrice = priceDouble / quantityDouble
        return String(format: "$%.2f", unitPrice)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Apply the pastel green background across the entire screen
                Color.pastelGreen
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Item Details Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Item Details")
                                .font(.headline)
                            TextField("Item Description", text: $itemDescription)
                            TextField("Quantity (e.g., 2)", text: $quantity)
                                .keyboardType(.decimalPad)
                            TextField("Unit (e.g., each, pound)", text: $unitOfMeasure)
                            TextField("Product Family", text: $productFamily)
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        
                        // Price and Date Section with Unit Price
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Price and Date")
                                .font(.headline)
                            TextField("Price Paid (e.g., 5.99)", text: $pricePaid)
                                .keyboardType(.decimalPad)
                            Text("Unit Price: \(unitPrice)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            DatePicker("Date", selection: $transactionDate, displayedComponents: .date)
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        
                        // Store Details Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Store Details")
                                .font(.headline)
                            TextField("Store Name", text: $storeName)
                            TextField("Store Location", text: $storeLocation)
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        
                        // Optional Section (Brand)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Optional")
                                .font(.headline)
                            TextField("Brand Name", text: $brandName)
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        
                        // Save Button
                        Button("Save") {
                            saveTransaction()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Transaction")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Input"), message: Text("Please fill in all required fields with valid data."), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func saveTransaction() {
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
        
        let transaction = Transaction(
            itemDescription: itemDescription,
            quantity: quantityDouble,
            unitOfMeasure: unitOfMeasure,
            productFamily: productFamily,
            pricePaid: priceDouble,
            transactionDate: transactionDate,
            storeName: storeName,
            storeLocation: storeLocation,
            brandName: brandName.isEmpty ? nil : brandName
        )
        modelContext.insert(transaction)
        do {
            try modelContext.save()
            clearFields()
        } catch {
            print("Error saving transaction: \(error)")
            showAlert = true
        }
    }
    
    private func clearFields() {
        itemDescription = ""
        quantity = ""
        unitOfMeasure = ""
        productFamily = ""
        pricePaid = ""
        transactionDate = Date()
        storeName = ""
        storeLocation = ""
        brandName = ""
    }
}

// Preview provider
struct AddTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        AddTransactionView()
            .modelContainer(for: Transaction.self, inMemory: true)
    }
}
