//
//  PortfolioDataService.swift
//  Crypto
//
//  Created by 김동락 on 2022/12/02.
//

import Foundation
import CoreData

class PortfolioDataService {
    
    private let container: NSPersistentContainer
    private let containerName: String = "PortfolioContainer"
    private let entityName: String = "PortfolioEntity"
    
    @Published var savedEntities: [PortfolioEntity] = []
    
    init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Error loading core data! \(error)")
            }
            self.getPortfolio()
        }
    }
    
    func updatePortfolio(coin: CoinModel, amout: Double) {
        if let entity = savedEntities.first(where: { $0.coinID == coin.id }){
            if amout > 0 {
                update(entity: entity, amount: amout)
            } else {
                delete(entity: entity)
            }
        } else {
            add(coin: coin, amount: amout)
        }
    }
    
    private func getPortfolio() {
        let request = NSFetchRequest<PortfolioEntity>(entityName: entityName)
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching portfolio entity! \(error)")
        }
    }
    
    private func add(coin: CoinModel, amount: Double) {
        let entity = PortfolioEntity(context: container.viewContext)
        entity.coinID = coin.id
        entity.amount = amount
        applyChanges()
    }
    
    private func update(entity: PortfolioEntity, amount: Double) {
        entity.amount = amount
        applyChanges()
    }
    
    private func delete(entity: PortfolioEntity) {
        container.viewContext.delete(entity)
        applyChanges()
    }
    
    private func save() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("Error saving to core data! \(error)")
        }
    }
    
    private func applyChanges() {
        save()
        getPortfolio()
    }
}
