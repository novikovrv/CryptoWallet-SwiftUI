import Foundation
import SwiftData

enum SDCoinMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SDCoinSchemaV1.self, SDCoinSchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: SDCoinSchemaV1.self,
        toVersion: SDCoinSchemaV2.self,
        willMigrate: nil,
        didMigrate: { context in
            // Извлекаем монеты старого формата
            let descriptor = FetchDescriptor<SDCoinSchemaV1.SDCoinV1>()
            let oldCoins = try context.fetch(descriptor)
            
            for oldCoin in oldCoins {
                // Создаем монету нового формата, копируя описание из descriptionText в details
                let newCoin = SDCoinSchemaV2.SDCoinV2(
                    id: oldCoin.id,
                    name: oldCoin.name,
                    price: oldCoin.price,
                    details: oldCoin.descriptionText, // <--- Перенос данных!
                    priceChange24h: oldCoin.priceChange24h
                )
                context.insert(newCoin)
                context.delete(oldCoin) // Удаляем старую, чтобы не дублировать
            }
            try context.save()
        }
    )
}
