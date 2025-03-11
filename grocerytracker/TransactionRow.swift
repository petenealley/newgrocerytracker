//
//  TransactionRow.swift
//  grocerytracker
//
//  Created by Pete Nealley on 3/10/25.
//
import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(transaction.itemDescription)
                .font(.headline)
            if let brand = transaction.brandName, !brand.isEmpty {
                Text("Brand: \(brand)")
                    .font(.subheadline)
            }
            Text("Date: \(transaction.transactionDate, formatter: dateFormatter)")
            Text("Store: \(transaction.storeName) - \(transaction.storeLocation)")
            Text("Paid: \(transaction.pricePaid, format: .currency(code: "USD"))")
            if transaction.quantity > 0 {
                Text("Price/Unit: \(transaction.pricePerUnit, format: .currency(code: "USD")) per \(transaction.unitOfMeasure)")
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()

struct TransactionRow_Previews: PreviewProvider {
    static var previews: some View {
        TransactionRow(transaction: Transaction(
            itemDescription: "Apple",
            quantity: 2,
            unitOfMeasure: "each",
            productFamily: "Produce",
            pricePaid: 1.99,
            transactionDate: Date(),
            storeName: "Safeway",
            storeLocation: "123 Main St",
            brandName: "Generic"
        ))
        .previewLayout(.sizeThatFits)
    }
}
