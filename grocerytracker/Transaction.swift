//
//  Transaction.swift
//  grocerytracker
//
//  Created by Pete Nealley on 3/10/25.
//
import SwiftUI
import SwiftData

@Model
class Transaction: Codable {
    var id: UUID
    var itemDescription: String
    var quantity: Double
    var unitOfMeasure: String
    var productFamily: String
    var pricePaid: Double
    var transactionDate: Date
    var storeName: String
    var storeLocation: String
    var brandName: String?
    
    var pricePerUnit: Double {
        quantity > 0 ? pricePaid / quantity : 0
    }
    
    init(id: UUID = UUID(), itemDescription: String, quantity: Double, unitOfMeasure: String, productFamily: String, pricePaid: Double, transactionDate: Date, storeName: String, storeLocation: String, brandName: String? = nil) {
        self.id = id
        self.itemDescription = itemDescription
        self.quantity = quantity
        self.unitOfMeasure = unitOfMeasure
        self.productFamily = productFamily
        self.pricePaid = pricePaid
        self.transactionDate = transactionDate
        self.storeName = storeName
        self.storeLocation = storeLocation
        self.brandName = brandName
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case itemDescription
        case quantity
        case unitOfMeasure
        case productFamily
        case pricePaid
        case transactionDate
        case storeName
        case storeLocation
        case brandName
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        itemDescription = try container.decode(String.self, forKey: .itemDescription)
        quantity = try container.decode(Double.self, forKey: .quantity)
        unitOfMeasure = try container.decode(String.self, forKey: .unitOfMeasure)
        productFamily = try container.decode(String.self, forKey: .productFamily)
        pricePaid = try container.decode(Double.self, forKey: .pricePaid)
        transactionDate = try container.decode(Date.self, forKey: .transactionDate)
        storeName = try container.decode(String.self, forKey: .storeName)
        storeLocation = try container.decode(String.self, forKey: .storeLocation)
        brandName = try container.decodeIfPresent(String.self, forKey: .brandName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(itemDescription, forKey: .itemDescription)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(unitOfMeasure, forKey: .unitOfMeasure)
        try container.encode(productFamily, forKey: .productFamily)
        try container.encode(pricePaid, forKey: .pricePaid)
        try container.encode(transactionDate, forKey: .transactionDate)
        try container.encode(storeName, forKey: .storeName)
        try container.encode(storeLocation, forKey: .storeLocation)
        try container.encodeIfPresent(brandName, forKey: .brandName)
    }
}
