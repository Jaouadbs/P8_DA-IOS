//
//  SleepRepository.swift
//  Arista
//
//  Created by Jaouad on 23/02/2026.
//

import Foundation
import CoreData

struct SleepRepository {
    
    let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }
    
    /// Récupère toutes les sessions de sommeil, triées par date décroissante
    func getSleepSessions() throws -> [Sleep] {
        let request = Sleep.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(SortDescriptor<Sleep>(\.startDate, order: .reverse))
        ]
        return try viewContext.fetch(request)
    }
    
}

