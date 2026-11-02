//
//  ContentView.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 06.10.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = CryptoViewModel()
    var body: some View {
        NavigationStack {
            List(viewModel.coins) {coin in
                NavigationLink(value: coin) {
                    HStack {
                        Text(coin.name)
                            .font(.headline)
                        Spacer()
                        Text(coin.price.formatted(.currency(code: "USD")))
                        //Text("\(coin.price)")
                        //Text(coin.price.formatted())
                       // Text(String(format: "$%.2f", coin.price))
                            .font(.subheadline)
                            //.foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Крипто-Кошелек")
            .navigationDestination(for: Coin.self){ selectedCoin in
                CoinDetailView(coin:selectedCoin)
 
            }
            .task {
                await viewModel.loadCryptoData()
            }
            .refreshable {
                await viewModel.loadCryptoData()
            }
        }
        
        VStack {
            Image(systemName: "sun.max.circle.fill")
                .imageScale(.large)
            //.foregroundStyle(.tint)
                .font(.system(size: 210))
                //.foregroundColor(.orange)
                .shadow(color: .black, radius: 10, x: 0, y: 20)
            
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    
    ContentView()
}
