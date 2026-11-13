//
//  CryptoManager.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 12.10.2026.
//
import Foundation

enum NetworkError: Error {
    case invalidURL
    case badServerResponse(statusCode: Int)
}

nonisolated final class CryptoManager: CryptoNetworkServiceProtocol {
    
    // Сопоставляем тикеры вашего приложения с ID монет в базе CoinGecko
    private let coinIdMap: [String: String] = [
        "BTC": "bitcoin",
        "ETH": "ethereum",
        "NEAR": "near",
        "SOUL": "phantasma"
    ]
    
    // Читаемые описания для отображения на экране
    private let coinDescriptions: [String: String] = [
        "BTC": "Bitcoin — первая децентрализованная криптовалюта.",
        "ETH": "Ethereum — платформа для смарт-контрактов и DeFi.",
        "NEAR": "NEAR Protocol — высокопроизводительный блокчейн с шардингом.",
        "SOUL": "Phantasma — блокчейн для цифрового контента и игр."
    ]
    
    func fetchAllCrypto(names: [String]) async -> [CryptoDTO] {
        // 1. Переводим тикеры ["BTC", "NEAR"] в строку ID "bitcoin,near"
        let ids = names.compactMap { coinIdMap[$0.uppercased()] }.joined(separator: ",")
        guard !ids.isEmpty else { return [] }
        
        let queryItems = [
            URLQueryItem(name: "ids", value: ids),
            URLQueryItem(name: "vs_currencies", value: "usd"),
            URLQueryItem(name: "include_24hr_change", value: "true")
        ]
        
        do {
            // 3. Выполняем запрос в сеть
            let decodedPrices: [String: CoinPriceInfo] = try await performRequest(
                path: "/api/v3/simple/price",
                queryItems: queryItems
            )
            
            // 4. Превращаем ответ сервера в чистые CryptoDTO для ViewModel
            var resultDTOs: [CryptoDTO] = []
            
            for ticker in names {
                let upperTicker = ticker.uppercased()
                guard let coinId = coinIdMap[upperTicker],
                      let priceInfo = decodedPrices[coinId] else {
                    continue
                }
                
                let dto = CryptoDTO(
                    name: upperTicker,
                    price: priceInfo.usd,
                    description: coinDescriptions[upperTicker] ?? "Описание для \(upperTicker)",
                    change: priceInfo.usd24hChange ?? 0.0
                )
                resultDTOs.append(dto)
            }
            
            return resultDTOs
            
        } catch {
            print("❌ Ошибка сети: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Загрузка графика за 7 дней (тоже максимально чисто!)
    func fetchWeeklyChart(for symbol: String) async throws -> [PricePoint] {
        guard let coinId = coinIdMap[symbol.uppercased()] else {
            throw NetworkError.invalidURL
        }
        
        let queryItems = [
            URLQueryItem(name: "vs_currency", value: "usd"),
            URLQueryItem(name: "days", value: "7")
        ]
        
        // Используем тот же самый универсальный метод!
        let chartResponse: MarketChartResponse = try await performRequest(
            path: "/api/v3/coins/\(coinId)/market_chart",
            queryItems: queryItems
        )
        
        return chartResponse.prices.compactMap { pair in
            guard pair.count >= 2 else { return nil }
            // Берем первый элемент массива (индекс 0) — это время в миллисекундах
            let date = Date(timeIntervalSince1970: pair[0] / 1000.0)
            // Берем второй элемент массива (индекс 1) — это сама цена
            return PricePoint(date: date, price: pair[1])
        }
    }
    
    // MARK: - Единый универсальный движок для всех сетевых запросов (DRY)
    private func performRequest<T: Decodable> (path: String, queryItems: [URLQueryItem]) async throws -> T {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api" + ".coingecko.com"
        components.path = path
        components.queryItems = queryItems
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.badServerResponse(statusCode: 0)
        }
        //200 - 299 это успешний запрос
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ Сеть: Сервер вернул статус \(httpResponse.statusCode)")
            throw NetworkError.badServerResponse(statusCode: httpResponse.statusCode)
        }
        
        // 4. Декодируем JSON в словарь [IDМонеты: Данные]
        return try JSONDecoder().decode(T.self, from: data)
    }
}
