//
//  CoreDataManager.swift
//  CryptoCurrencyWallet
//
//  Created by Руслан Новиков on 19.10.2026.
//
import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer
    
    private init(){
        persistentContainer = NSPersistentContainer(name: "CryptoModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error as NSError?{
                fatalError("Ошибка инициализации кордата \(error), \(error.userInfo)")
            }
        }
        //автоматически сохраняет изменения при записи из фонового потока
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    //контекст для работы на главном потоке (чтение UI) для более короткого обращения к viewContext
    var viewContext: NSManagedObjectContext{//экземпляр NSPersistentContainer
        return persistentContainer.viewContext
    }
    //функция сохранения изменений из контекста на диск
    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("CoreData succesfully wrote data on a hardware")
            } catch {
                let nserror = error as NSError
                print("save data fail due to error \(nserror)")
            }
        }
    }
}
