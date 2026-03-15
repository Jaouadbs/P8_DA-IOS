//
//  DefaultData.swift
//  Arista
//
//  Created by Jaouad on 26/02/2026.
//

import Foundation
import CoreData

struct DefaultData {
    
    let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }
    
    func apply() throws {
        let userRepository = UserRepository(viewContext: viewContext)
        let sleepRepository = SleepRepository(viewContext: viewContext)
        
        if (try? userRepository.getUser()) == nil {
            
            // -- User par défaut--------
            let initialUser                 = User(context: viewContext)
            initialUser.id                  = UUID()
            initialUser.firstName           = "Charlotte"
            initialUser.lastName            = "Razoul"
            initialUser.email               = "charlotte.razoul@example.com"
            initialUser.passwordHash        = ""
            initialUser.dailyStepGoal       = 10_000 // pas
            initialUser.sleepHoursGoal      = 480    // minutes(=8h)
            initialUser.hydrationMlGoal     = 2_000  // ml
            initialUser.caloriesBurnedGoal  = 500    // kcal
            initialUser.createdAt           = Date()
            initialUser.updatedAt           = Date()
            
            // -- Sessions de sommeil par défaut ----
            if try sleepRepository.getSleepSessions().isEmpty {
                let timeIntervalForDay: TimeInterval = 60 * 60 * 24
                
                let sleep1       = Sleep(context: viewContext)
                sleep1.id        = UUID()
                sleep1.startDate = Date(timeIntervalSinceNow: -timeIntervalForDay * 5)
                sleep1.endDate   = Date(timeIntervalSinceNow: -timeIntervalForDay * 5 + 7 * 3600)
                sleep1.duration  = 420 // minutes(= 7h)
                sleep1.quality   = "bonne"
                sleep1.category  = "nuit"
                sleep1.user      = initialUser
                
                let sleep2       = Sleep(context: viewContext)
                sleep2.id        = UUID()
                sleep2.startDate = Date(timeIntervalSinceNow: -timeIntervalForDay * 4)
                sleep2.endDate   = Date(timeIntervalSinceNow: -timeIntervalForDay * 4 + 6 * 3600)
                sleep2.duration  = 360 // minutes(= 6h)
                sleep2.quality   = "moyenne"
                sleep2.category  = "nuit"
                sleep2.user      = initialUser
                
                let sleep3       = Sleep(context: viewContext)
                sleep3.id        = UUID()
                sleep3.startDate = Date(timeIntervalSinceNow: -timeIntervalForDay * 3)
                sleep3.endDate   = Date(timeIntervalSinceNow: -timeIntervalForDay * 3 + 8 * 3600)
                sleep3.duration  = 480 // minutes(= 8h)
                sleep3.quality   = "excellente"
                sleep3.category  = "nuit"
                sleep3.user      = initialUser
                
                let sleep4       = Sleep(context: viewContext)
                sleep4.id        = UUID()
                sleep4.startDate = Date(timeIntervalSinceNow: -timeIntervalForDay * 2)
                sleep4.endDate   = Date(timeIntervalSinceNow: -timeIntervalForDay * 2 + 5.5 * 3600)
                sleep4.duration  = 330 // minutes(= 5h30)
                sleep4.quality   = "mauvaise"
                sleep4.category  = "nuit"
                sleep4.user      = initialUser
                
                let sleep5       = Sleep(context: viewContext)
                sleep5.id        = UUID()
                sleep5.startDate = Date(timeIntervalSinceNow: -timeIntervalForDay )
                sleep5.endDate   = Date(timeIntervalSinceNow: -timeIntervalForDay  + 1.5 * 3600)
                sleep5.duration  = 90 // minutes(= 1h30)
                sleep5.quality   = "bonne"
                sleep5.category  = "sieste"
                sleep5.user      = initialUser
                
            }
            try? viewContext.save()
        }
    }
}
