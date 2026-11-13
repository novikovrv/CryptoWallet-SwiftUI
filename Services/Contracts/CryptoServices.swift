//
//  CryptoServices.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 09.11.2026.
//

import Foundation

protocol CryptoNetworkServiceProtocol: Sendable {
    func fetchAllCrypto(names: [String]) async -> [CryptoDTO]
    func fetchWeeklyChart(for symbol: String) async throws -> [PricePoint]
}

@MainActor
protocol CryptoStorageServiceProtocol {
    func fetchLocalCoins() -> [Coin]
    func saveCoins(_ coins: [Coin])
}
