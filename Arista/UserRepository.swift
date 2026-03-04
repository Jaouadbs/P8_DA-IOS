//
//  File.swift
//  Arista
//
//  Created by Jaouad on 23/02/2026.
//

import Foundation
import CoreData

    struct UserRepository {

        let viewContext: NSManagedObjectContext
        
        // Initialisation avec le contexte de persistance partagé
        init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
            self.viewContext = viewContext
        }

        // Récupère l'utilisateur unique de la base de données
        func getUser() throws -> User? {
            let request = User.fetchRequest()
            request.fetchLimit = 1
            return try viewContext.fetch(request).first
    }
}
