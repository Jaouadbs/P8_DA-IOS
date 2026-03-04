//
//  UserDataViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

class UserDataViewModel: ObservableObject {
    
    // MARK: - Published
    
    @Published var firstName: String         = ""
    @Published var lastName: String          = ""
    @Published var email: String             = ""
    @Published var dailyStepGoal: Int64      = 0
    @Published var sleepHoursGoal: Int64     = 0
    @Published var hydrationMlGoal: Int64    = 0
    @Published var caloriesBurnedGoal: Int64 = 0
    @Published var errorMessage: String?
    
    // MARK: - Private
    
    private let userRepository: UserRepository
    
    // MARK: Init
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.userRepository = UserRepository(viewContext: context)
        fetchUserData()
    }
    
    // MARK: - Fetch
    
    // récupère les données d'utilisateur via UserRepository
    private func fetchUserData() {
        // TODO: fetch data in CoreData and replace dumb value below with appropriate information
        
        do {
            guard let user = try userRepository.getUser() else {
                errorMessage = "Aucun utilisateur trouvé."
                return
            }
            firstName          = user.firstName            ?? ""
            lastName           = user.lastName             ?? ""
            email              = user.email                ?? ""
            dailyStepGoal      = user.dailyStepGoal
            sleepHoursGoal     = user.sleepHoursGoal
            hydrationMlGoal    = user.hydrationMlGoal
            caloriesBurnedGoal = user.caloriesBurnedGoal
            
        } catch {
            errorMessage = "Erreur lors de la récupération des données utilisateur."
            print("UserDataViewModel - fetchUserData : \(error.localizedDescription)")
        }
    }
}
