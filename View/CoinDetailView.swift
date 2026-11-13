//
//  CoinDetailView.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 16.10.2026.
//

import SwiftUI
import Charts

struct CoinDetailView: View {
    @State private var viewModel: CoinDetailViewModel
    
    // Принимаем монету из списка и инициализируем ViewModel
    init(coin: Coin, network: CryptoNetworkServiceProtocol = CryptoManager()) {
        //системная обертка State<CoinDetailViewModel>, которая отвечает за хранение объекта в памяти и обновление экрана при изменениях.
        _viewModel = State(initialValue: CoinDetailViewModel(coin: coin, network: network))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // 1. Шапка с текущей ценой и изменением за 24 часа
                headerSection
                
                // 2. Блок недельного графика
                chartSection
                
                // 3. Описание монеты
                VStack(alignment: .leading, spacing: 8) {
                    Text("О проекте")
                        .font(.headline)
                    Text(viewModel.coin.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.coin.name)
        .navigationBarTitleDisplayMode(.inline)
        // Загружаем данные при открытии экрана
        .task {
            await viewModel.loadWeeklyChart()
        }
    }
    
    // MARK: - Секция цены
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.coin.price.formatted(.currency(code: "USD")))
                .font(.system(size: 34, weight: .bold))
            
            let isPositive = viewModel.coin.priceChange24h >= 0
            HStack(spacing: 4) {
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                Text("\(abs(viewModel.coin.priceChange24h), specifier: "%.2f")% (24ч)")
            }
            .font(.subheadline.bold())
            .foregroundStyle(isPositive ? .green : .red)
        }
    }
    
    // MARK: - Секция графика Swift Charts
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Динамика за 7 дней")
                .font(.headline)
            //Group - контейнер обертка(делает стиль окна общим для всех вариантов загрузки)
            Group {
                if viewModel.isLoading {
                    ProgressView("Загрузка графика...")
                        .frame(maxWidth: .infinity, minHeight: 220)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 8) {
                        Text(error)
                            .foregroundStyle(.secondary)
                        Button("Повторить") {
                            Task { await viewModel.loadWeeklyChart() }
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, minHeight: 220)
                } else if !viewModel.priceHistory.isEmpty {
                    Chart(viewModel.priceHistory) { point in
                        // Линия цены
                        LineMark(
                            x: .value("Дата", point.date),
                            y: .value("Цена", point.price)
                        )
                        .foregroundStyle(chartColor)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                        
                        // Градиентная заливка под линией
                        AreaMark(
                            x: .value("Дата", point.date),
                            yStart: .value("Мин", minPrice),
                            yEnd: .value("Цена", point.price)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [chartColor.opacity(0.3), chartColor.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    // Масштабируем ось Y от минимальной до максимальной цены, чтобы график не был плоским
                    .chartYScale(domain: minPrice...maxPrice)
                    .frame(height: 220)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Вспомогательные вычисления для масштаба и цвета
    private var minPrice: Double {
        viewModel.priceHistory.map(\.price).min() ?? 0
    }
    
    private var maxPrice: Double {
        viewModel.priceHistory.map(\.price).max() ?? 100
    }
    
    private var chartColor: Color {
        guard let first = viewModel.priceHistory.first?.price,
              let last = viewModel.priceHistory.last?.price else { return .blue }
        return last >= first ? .green : .red
    }
}

#Preview {
    NavigationStack {
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
}
