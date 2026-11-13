//
//  CoinModel.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 06.10.2026.
//
import Foundation

struct Coin: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let price: Double
    let description: String
    let priceChange24h: Double
}
