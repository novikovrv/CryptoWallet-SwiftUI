//
//  CoinRowView.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 11.11.2026.
//
import SwiftUI

struct CoinRowView: View {
    let coin: Coin
    
    var body: some View {
    
        HStack(spacing: 14) {
            // 1. Круглая иконка монеты с фоном
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundColor(iconColor)
            }
            
            // 2. Название и тикер монеты
            VStack(alignment: .leading, spacing: 4) {
                Text(coin.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(coin.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1) // Обрезаем длинный текст в 1 строку
            }
            
            Spacer()
            
            // 3. Цена и процент изменения за 24ч
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "$%.2f", coin.price))
                    .font(.headline)
                    .bold()
                
                // Цветной бейдж с процентами
                HStack(spacing: 2) {
                    Image(systemName: coin.priceChange24h >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption2)
                    
                    Text(String(format: "%.2f%%", abs(coin.priceChange24h)))
                        .font(.caption)
                        .bold()
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(isPositive ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                .foregroundColor(isPositive ? .green : .red)
                .cornerRadius(6)
            }
        }
        .padding(.vertical, 4)
    }
    
    // Вспомогательные вычисляемые свойства (Computed Properties) для чистоты кода
    private var isPositive: Bool {
        coin.priceChange24h >= 0
    }
    
    private var iconName: String {
        switch coin.name.uppercased() {
        case "BTC": return "bitcoinsign"
        case "ETH": return "diamond.fill"
        case "SOL", "SOUL": return "sun.max.fill"
        default: return "dollarsign.circle"
        }
    }
    
    private var iconColor: Color {
        switch coin.name.uppercased() {
        case "BTC": return .orange
        case "ETH": return .indigo
        case "SOL", "SOUL": return .purple
        default: return .blue
        }
    }
}




#Preview {
    CoinRowView( coin: Coin(
        id: UUID(),
        name: "BTC",
        price: 65000.0,
        description: "Первая и самая популярная криптовалюта в мире.",
        priceChange24h: -2.5
    ))
}

