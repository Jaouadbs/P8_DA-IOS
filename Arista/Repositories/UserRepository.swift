//
//  File.swift
//  Arista
//
//  Created by Jaouad on 23/02/2026.
//  Seul fichier autorisé à accèder à CoreData pour l'entité User.
//  Retourne des UserModel

import Foundation
import CoreData

struct UserRepository : UserRepositoryProtocol {
    
    let viewContext: NSManagedObjectContext
    
    // Initialisation avec le contexte de persistance partagé
    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }
    
    // Récupère l'utilisateur et le convertit en UserModel
    func getUser() throws -> UserModel? {
        let request = User.fetchRequest()
        request.fetchLimit = 1
        guard let user =  try viewContext.fetch(request).first else { return nil}
        
        return UserModel(
            firstName :             user.firstName      ?? "",
            lastName:               user.lastName       ?? "",
            email:                  user.email          ?? "",
            dailyStepGoal:          user.dailyStepGoal,
            sleepHoursGoal:         user.sleepHoursGoal,
            hydrationMlGoal:        user.hydrationMlGoal,
            caloriesBurnedGoal:     user.caloriesBurnedGoal
        )
    }
}




