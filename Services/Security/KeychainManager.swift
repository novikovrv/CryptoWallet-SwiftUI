//
//  KeyсhainManager.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 13.11.2026.
//
import Foundation
import Security

final class KeychainManager: KeychainServiceProtocol {
    
    static let shared = KeychainManager()
    private init() {}
    
    // Метод сохранения или перезаписи строки
    func save(_ value: String, service: String, account: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        // 1. Формируем координаты ячейки (Первичный ключ)
        let searchQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        // 2. Удаляем старую запись по координатам (без kSecValueData!)
        SecItemDelete(searchQuery as CFDictionary)
        
        // 3. Добавляем данные и уровень защиты для новой записи
        var addQuery = searchQuery
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // Метод чтения данных из Keychain
    func read(service: String, account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
    
    // Метод удаления (возвращает true, если удалено или записи уже не было)
    @discardableResult
    func delete(service: String, account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
