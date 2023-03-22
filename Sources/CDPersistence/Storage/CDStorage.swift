//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 21.03.2023.
//

import CoreData

open class CDStorage {
    
    private let modelName: String
    private let bundle: Bundle
    
    public init(modelName: String, bundle: Bundle) {
        self.modelName = modelName
        self.bundle = bundle
    }
    
    public lazy var persistentContainer: NSPersistentContainer = {
        guard let modelURL = bundle.url(forResource: modelName, withExtension: "momd"),
              let objectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("\(modelName) cannot be found as a resource")
        }
        
        let container = NSPersistentContainer(name: modelName, managedObjectModel: objectModel)
        
        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                assertionFailure("\(self.modelName) Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
}
