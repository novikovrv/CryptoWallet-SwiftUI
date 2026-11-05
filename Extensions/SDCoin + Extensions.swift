//
//  SDCoin + Extensions.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 02.11.2026.
//
import Foundation
import SwiftData

extension SDCoin {
    convenience init(from coin: Coin) {
        self.init(
            id: coin.id,
            name: coin.name,
            price: coin.price,
            details: coin.description,
            priceChange24h: coin.priceChange24h
        )
    }
}
