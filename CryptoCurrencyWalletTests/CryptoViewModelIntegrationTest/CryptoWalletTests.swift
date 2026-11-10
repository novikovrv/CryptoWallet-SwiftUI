import XCTest
// 🌟 КРИТИЧЕСКИ ВАЖНО: Импортируем твой проект, чтобы тесты видели твои классы и структуры
@testable import CryptoCurrencyWallet

final class CryptoWalletTests: XCTestCase {//final оптимизирует работу для компилятора(ему не нужно искать возможных наследников)
    
    // Тестируем наше расширение-конвертер
    func testCoinMappingFromSDCoin() {
        // 1. Arrange (Подготовка данных)
        let mockId = UUID()
        let sourceSDCoin = SDCoin(
            id: mockId,
            name: "Bitcoin",
            price: 65000.0,
            descriptionText: "Главная крипта",
            priceChange24h: 3.5
        )
        
        // 2. Act (Выполнение действия)
        let resultCoin = Coin(from: sourceSDCoin)
        
        // 3. Assert (Проверка результатов)
        // Проверяем, что все поля скопировались точь-в-точь
        XCTAssertEqual(resultCoin.id, mockId, "ID монеты должен совпадать")
        XCTAssertEqual(resultCoin.name, "Bitcoin", "Имя монеты должно совпадать")
        XCTAssertEqual(resultCoin.price, 65000.0, "Цена монеты должна совпадать")
        XCTAssertEqual(resultCoin.description, "Главная крипта", "Описание должно совпадать")
        XCTAssertEqual(resultCoin.priceChange24h, 3.5, "Проценты изменений должны совпадать")
    }
}
