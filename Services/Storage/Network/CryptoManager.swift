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
        
        // 2. Безопасно собираем URL через URLComponents
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api" + ".coingecko.com"
        components.path = "/api/v3/simple/price"
        components.queryItems = [
            URLQueryItem(name: "ids", value: ids),
            URLQueryItem(name: "vs_currencies", value: "usd"),
            URLQueryItem(name: "include_24hr_change", value: "true")
        ]
        
        guard let url = components.url else {
            print("❌ Сеть: Не удалось собрать URL")
            return []
        }
        print("❌ Сеть: Удалось собрать \(url)")
        
        do {
            // 3. Выполняем запрос в сеть
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
            let decodedPrices = try JSONDecoder().decode([String: CoinPriceInfo].self, from: data)
            
            // 5. Превращаем ответ сервера в чистые CryptoDTO для ViewModel
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
}
