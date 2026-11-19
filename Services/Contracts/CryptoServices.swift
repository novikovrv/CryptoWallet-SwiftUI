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

protocol KeychainServiceProtocol {
    func save(_ value: String, service: String, account: String) -> Bool
    func read(service: String, account: String) -> String?
    func delete(service: String, account: String) -> Bool
}
