//
//  Coin + Extensions.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 02.11.2026.
//
extension Coin{
    init(from sdCoin: SDCoin){
        self.id = sdCoin.id
        self.name = sdCoin.name
        self.price = sdCoin.price
        self.description = sdCoin.descriptionText
        self.priceChange24h = sdCoin.priceChange24h
    }
}
