//
//  CryptoViewModelTests.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 09.11.2026.
//

import XCTest
import SwiftData
@testable import CryptoCurrencyWallet

final class CryptoViewModelTests: XCTestCase {

    @MainActor // Так как ViewModel работает на Главном потоке, тест тоже изолируем на MainActor
    func testLoadPricePopulatesCoinsAndSavesToSwiftData() async throws {
        
        // 1. ARRANGE (Подготовка изолированной базы данных SwiftData в памяти)
        // Создаем конфигурацию, которая говорит: хранить данные ТОЛЬКО в оперативной памяти (inMemory)
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        // Создаем тестовый контейнер(базу данных)
        let container = try ModelContainer(for: SDCoin.self, configurations: config)
        let testContext = container.mainContext//рабочая область для работы с базой данных
        let testRepository = CryptoRepository(context: testContext)
        
        // Инициализируем ViewModel и передаем ей наш тестовый, чистый контекст
        let viewModel = CryptoViewModel(repository: testRepository)
        
        // Убеждаемся, что изначально массив монет во ViewModel пустой
        XCTAssertTrue(viewModel.coins.isEmpty, "Изначально список монет во ViewModel должен быть пуст")
        
        // 2. ACT (Выполнение асинхронного действия)
        // Ключевое слово await приостанавливает тест, пока loadPrice() полностью не отработает во ViewModel
        await viewModel.loadCryptoData()
        
        // 3. ASSERT (Проверка результатов)
        // А) Проверяем, что массив во ViewModel заполнился данными из нашего симулятора сети
        XCTAssertFalse(viewModel.coins.isEmpty, "После загрузки массив монет не должен быть пустым")
        XCTAssertEqual(viewModel.coins.count, 3, "Симулятор сети должен был вернуть ровно 3 монеты (BTC, ETH, SOUL)")
        
        // Б) Проверяем, что SwiftData РЕАЛЬНО сохранила эти данные в тестовую базу на диске памяти
        let descriptor = FetchDescriptor<SDCoin>()
        let savedCoinsInDb = try testContext.fetch(descriptor)
        
        XCTAssertEqual(savedCoinsInDb.count, 3, "В локальной базе данных SwiftData должно быть сохранено ровно 3 монеты")
        
        // Проверяем конкретную монету в базе для максимальной точности
        let btcCoin = savedCoinsInDb.first(where: { $0.name == "BTC" })
        XCTAssertNotNil(btcCoin, "В базе данных обязательно должна присутствовать монета BTC")
    }
}
