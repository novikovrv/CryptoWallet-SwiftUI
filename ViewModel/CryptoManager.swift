//
//  CryptoManager.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 12.10.2026.
//
import Foundation
class CryptoManager {
    
    func fetchCrypto(for coin: String) async throws -> (Double, String, Double){
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        switch coin {
        case "BTC": return (Double.random(in: 64000...98000),"Description BTC", Double.random(in:-100...100))
        case "ETH": return (Double.random(in: 3000...9000),"Description ETH", Double.random(in:-100...100))
        case "SOUL": return (Double.random(in: 11...1333),"Description SOUL", Double.random(in:-100...100))
        default: return (Double.random(in: 1...10),"Description Default", Double.random(in:-100...100))
        }
        
        //        let urlString = "https//Currency.com/crypto"
        //        guard let url = URL(string: urlString) else {
        //            throw URLError(.badURL)
        //        }
        //
        //        var (data, _) = try await URLSession.shared.data(from: url)
        //
        //        struct CryptoNames: Codable{
        //            var name: String
        //            var price: String
        //        }
        //
        //        let decodedData = try JSONDecoder().decode(CryptoNames.self, from: data)
        //
        //        guard let doublePrice = Double(decodedData.price) else {
        //            throw URLError(.cannotParseResponse)
        //        }
        //
        //        return doublePrice
        //
    }
    
}
