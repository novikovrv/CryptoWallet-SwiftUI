//
//  CDCoin + Extensions.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 29.10.2026.
//

import Foundation

extension CDCoin {
    var coinsFromCoreDataToSwiftUIModel: Coin {
        return Coin(id: self.id ?? UUID(),
                    name: self.name ?? "Unknown",
                    price: self.price,
                    description: self.descriptionText ?? " ",
                    priceChange24h: self.priceChange24h)
    }
}

