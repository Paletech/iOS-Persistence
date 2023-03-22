//
//  File.swift
//  
//
//  Created by LEMIN DAHOVICH on 21.03.2023.
//

import CoreData
import OSLog

public extension NSManagedObjectContext {
    
    func insertObject<A: NSManagedObject>() -> A where A: Managed {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else {
            fatalError("Wrong object type")
        }
        return obj
    }
    
    func performChanges(block: @escaping () -> Void) {
        perform {
            block()
            let success = self.saveOrRollback()
            os_log("[CoreData] Saving result: \(success)")
        }
    }
    
    func performChangesAndWait(block: () -> Void) {
        performAndWait {
            block()
            self.saveOrRollback()
        }
    }
    
    @discardableResult
    private func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }
}
