//
//  SDCoinSchemas.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 04.11.2026.
//

import Foundation
import SwiftData

enum SDCoinSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        get {
                return [SDCoinV1.self]
            }
    }
    
    @Model
    class SDCoinV1 {
        @Attribute(.unique) var id: UUID
        var name: String
        var price: Double
        var descriptionText: String
        var priceChange24h: Double
        
        init(id: UUID = UUID(), name: String, price: Double, descriptionText: String, priceChange24h: Double){
            self.id = id
            self.name = name
            self.price = price
            self.descriptionText = descriptionText
            self.priceChange24h = priceChange24h
        }
    }
}

enum SDCoinSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [SDCoinV2.self]
    }
    @Model
    class SDCoinV2 {
        @Attribute(.unique) var id: UUID
        var name: String
        var price: Double
        var details: String
        var priceChange24h: Double
        
        init(id: UUID = UUID(), name: String, price: Double, details: String, priceChange24h: Double){
            self.id = id
            self.name = name
            self.price = price
            self.details = details
            self.priceChange24h = priceChange24h
        }
    }
}

