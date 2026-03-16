//
//  SleepRepository.swift
//  Arista
//
//  Created by Jaouad on 23/02/2026.
//  Seul fichier autorisé à accèder à CoreData pour l'entité Sleep.
//  Retourne des SleepModels

import Foundation
import CoreData

struct SleepRepository: SleepRepositoryProtocol {
    
    let viewContext: NSManagedObjectContext
    
    // Initialisation: Par défaut, on utilise le contexte principal
    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }
    
    /// Récupère toutes les sessions de sommeil, triées par date décroissante
    /// les Convertit en SleepModel
    func getSleepSessions() throws -> [SleepModel] {
        let request = Sleep.fetchRequest()
        
        // Organise les resultats de manière décroissante
        request.sortDescriptors = [
            NSSortDescriptor(SortDescriptor<Sleep>(\.startDate, order: .reverse))
        ]
        //On utilise compactMap pour transformer chaque objet CoreData en un objet de transfert de données simple.
        return try viewContext.fetch(request).compactMap { session in
            
            // On verifié ici que les data essentielle ne sont pas nil
            guard let id        = session.id,
                  let category  = session.category,
                  let quality   = session.quality,
                  let startDate = session.startDate
            else {
                //Si les data manque, on ignore cette session( retourn nil)
                // compactMap supprimera automatiquement le nil de la liste finale
                return nil
            }
            // On crée une structure SleepModel propre et immuable
            // cela protège le reste de l'application des spécificités de CoreData.
            return SleepModel(
                id:         id,
                category:   category,
                duration:   session.duration,
                quality:    quality,
                startDate:  startDate,
                endDate:    session.endDate   //endDate Reste optionnel
            )
        }
    }
    
}

