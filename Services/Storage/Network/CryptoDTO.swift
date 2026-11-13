//
//  CryptoDTO.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 06.11.2026.
//

import Foundation

// чистая транспортная модель
nonisolated struct CryptoDTO: Sendable {
    let name: String
    let price: Double
    let description: String
    let change: Double
}

// Модель для парсинга JSON от эндпоинта /api/v3/simple/price
nonisolated struct CoinPriceInfo: Decodable, Sendable {
    let usd: Double
    let usd24hChange: Double?
    
    enum CodingKeys: String, CodingKey {//пометка для JsonDecoder
        case usd
        case usd24hChange = "usd_24h_change"
    }
}


// 1. Модель для парсинга JSON от CoinGecko
nonisolated struct MarketChartResponse: Decodable, Sendable {
    let prices: [[Double]]
}

// 2. Чистая модель точки для графика SwiftUI Charts
nonisolated struct PricePoint: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let price: Double
}

