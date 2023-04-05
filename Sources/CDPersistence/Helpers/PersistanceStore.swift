//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 21.03.2023.
//

import CoreData

protocol PersistenceStoreDelegate: AnyObject {
    func persistenceStore(didUpdateEntity update: Bool)
}

public enum CoreDataObjectContext {
    case view
    case background
}

open class PersistenceStore<Entity: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    
    private let persistentContainer: NSPersistentContainer
    public let managedObjectContext: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<Entity>!
    private var changeTypes: [NSFetchedResultsChangeType] = []
    weak var delegate: PersistenceStoreDelegate?
    
    public init(_ persistentContainer: NSPersistentContainer, contextType: CoreDataObjectContext = .view) {
        self.persistentContainer = persistentContainer
        
        switch contextType {
        case .view:
            managedObjectContext = persistentContainer.viewContext
        case .background:
            managedObjectContext = persistentContainer.newBackgroundContext()
        }
        
        super.init()
        
        if contextType == .background {
            setupMergeChangesObserver(for: managedObjectContext)
        }
    }
    
    // MARK: - Internal
    func configureResultsController(batchSize: Int = 5, limit: Int = 0,
                                    sortDescriptors: [NSSortDescriptor] = [],
                                    predicate: NSPredicate? = nil,
                                    notifyChangesOn changeTypes: [NSFetchedResultsChangeType] = [.insert, .delete, .move, .update]) {
        guard let entityName = Entity.entity().name else { fatalError() }
        
        let request =  NSFetchRequest<Entity>(entityName: entityName)
        request.fetchBatchSize = batchSize
        request.fetchLimit = limit
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.returnsObjectsAsFaults = false
        
        self.changeTypes = changeTypes
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: managedObjectContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange anyObject: Any,
                           at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard changeTypes.contains(type) else { return }
        
        if anyObject as? Entity != nil {
            delegate?.persistenceStore(didUpdateEntity: true)
        }
    }
    
    private func setupMergeChangesObserver(for context: NSManagedObjectContext) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mergeChangesFromBackgroundContext(notification:)),
                                               name: .NSManagedObjectContextDidSave,
                                               object: context)
    }
    
    @objc private func mergeChangesFromBackgroundContext(notification: Notification) {
        guard notification.object is NSManagedObjectContext else {
            return
        }
        
        persistentContainer.viewContext.perform {
            self.persistentContainer.viewContext.mergeChanges(fromContextDidSave: notification)
        }
    }
}
