//
//  CryptoDTO.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 06.11.2026.
//

import Foundation

// Модель для парсинга JSON от эндпоинта /api/v3/simple/price
nonisolated struct CoinPriceInfo: Decodable, Sendable {
    let usd: Double
    let usd24hChange: Double?
    
    enum CodingKeys: String, CodingKey {//пометка для JsonDecoder
        case usd
        case usd24hChange = "usd_24h_change"
    }
}

// Ваша чистая транспортная модель (остается без изменений)
nonisolated struct CryptoDTO: Sendable {
    let name: String
    let price: Double
    let description: String
    let change: Double
}
