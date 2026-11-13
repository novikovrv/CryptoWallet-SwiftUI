//
//  ContentView.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 06.10.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // Получаем контекст SwiftData из окружения системы
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = CryptoViewModel()
    
    private var totalBalance: Double {
        viewModel.coins.reduce(0) { $0 + $1.price }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Если массив пустой (идет самая первая загрузка) — показываем спиннер
                if viewModel.coins.isEmpty {
                    ProgressView("Загрузка котировок...")
                        .scaleEffect(1.2)
                } else {
                    List {
                        // СЕКЦИЯ 1: Карточка общего баланса
                        Section {
                            balanceCard
                                .listRowInsets(EdgeInsets()) // Убираем стандартные отступы ячейки
                                .listRowBackground(Color.clear)
                        }
                        
                        // СЕКЦИЯ 2: Список активов
                        Section("Ваши активы") {
                            ForEach(viewModel.coins) { coin in
                                NavigationLink(value: coin) {
                                    CoinRowView(coin: coin)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped) // Современный стиль списков iOS
                }
            }
            .navigationTitle("Крипто-Кошелек")
            .navigationDestination(for: Coin.self){ selectedCoin in
                CoinDetailView(coin:selectedCoin)
                
            }
            .task {
                let realRepository = CryptoRepository(context: modelContext)
                viewModel.updateRepository(with: realRepository)
                viewModel.fetchLocalCoins()
//                while !Task.isCancelled {
//                    await viewModel.loadCryptoData()
//                    try? await Task.sleep(for: .seconds(30))
//                }
            }
            .refreshable {
                await viewModel.loadCryptoData()
            }
        }
    }
    
    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Общий баланс портфеля")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Text(String(format: "$%.2f", totalBalance))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            // Плавная анимация перекатывания цифр при обновлении цен!
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.blue, Color.indigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Color.indigo.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ContentView()
    // Создает временную базу SwiftData в оперативной памяти специально для холста
        .modelContainer(for: SDCoin.self, inMemory: true)
    
}
