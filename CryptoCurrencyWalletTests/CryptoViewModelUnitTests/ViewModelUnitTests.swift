import XCTest
@testable import CryptoCurrencyWallet

// 1. Фейковая сеть: мгновенно возвращает заранее заданные данные
nonisolated final class MockCryptoNetwork: CryptoNetworkServiceProtocol {
    let mockDTOs: [CryptoDTO]//констаната по требованию протокола sendable
    init(mockDTOs: [CryptoDTO] = [
           CryptoDTO(name: "BTC", price: 70000.0, description: "Test BTC", change: 2.5),
           CryptoDTO(name: "ETH", price: 3500.0, description: "Test ETH", change: -1.2)
       ]) {
           self.mockDTOs = mockDTOs
       }
    
    func fetchAllCrypto(names: [String]) async -> [CryptoDTO] {
        return mockDTOs
    }
    func fetchWeeklyChart(for symbol: String) async throws -> [PricePoint] {
        return []
    }
}

// 2. Фейковое хранилище: просто держит массив в памяти без SwiftData
@MainActor
final class MockCryptoStorage: CryptoStorageServiceProtocol {
    var savedCoins: [Coin] = []
    
    func fetchLocalCoins() -> [Coin] {
        return savedCoins.sorted { $0.name < $1.name }
    }
    
    func saveCoins(_ coins: [Coin]) {
        self.savedCoins = coins
    }
}

// 3. Сам тест (обратите внимание: import SwiftData больше даже не нужен!)
final class CryptoViewModelUnitTests: XCTestCase {

    @MainActor
    func testLoadCryptoDataMapsAndSavesCorrectly() async {
        // ARRANGE
        let mockNetwork = MockCryptoNetwork()
        let mockStorage = MockCryptoStorage()
        let viewModel = CryptoViewModel(network: mockNetwork, repository: mockStorage)
        
        // ACT
        await viewModel.loadCryptoData()
        
        // ASSERT
        XCTAssertEqual(viewModel.coins.count, 2, "ViewModel должна загрузить 2 монеты из Mock-сети")
        XCTAssertEqual(mockStorage.savedCoins.count, 2, "Монеты должны быть переданы в хранилище")
        XCTAssertEqual(viewModel.coins.first?.name, "BTC", "Список должен быть отсортирован по алфавиту")
        XCTAssertEqual(viewModel.coins.first?.price, 70000.0)
    }
}

