//
//  CoinDetailView.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 16.10.2026.
//

import SwiftUI

struct CoinDetailView: View {
    let coin: Coin
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bitcoinsign.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.orange)
                .padding(.top)
            
            Text(coin.name)
                .font(.largeTitle)
                .bold()
            
            HStack {
                Text(String(format: "$%.2f", coin.price))
                    .font(.title2)
                    .bold()
                Text(String(format: "%.2f%%", coin.priceChange24h))
                    .font(.title3)
                    .foregroundColor(coin.priceChange24h >= 0 ? .green : .red)
            }
            
            Divider()
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("O монете")
                    .font(.title)
                Text(coin.description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            Spacer() // Выталкивает контент наверх
        }
        .navigationTitle(coin.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
#Preview {
    CoinDetailView(
        coin: Coin(
            id: UUID(),
            name: "Bitcoin",
            price: 65000.0,
            description: "Первая и самая популярная криптовалюта в мире.",
            priceChange24h: -2.5
        )
    )
}
