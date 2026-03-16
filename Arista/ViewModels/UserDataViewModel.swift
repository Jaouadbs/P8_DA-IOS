//
//  UserDataViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//  Dépend uniquement de UserRepositoryProtocol

import Foundation


final class UserDataViewModel: ObservableObject {
    
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
    // permet de passer un Repository ou un Mock pour les tests.
    private let repository: UserRepositoryProtocol
    
    // MARK: Init
    
    /// L'injection de dépendance . Le ViewModel reçoit son repository au moment de sa création.
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
        fetchUserData()
    }
    
    // MARK: - Fetch
    
    // récupère les données d'utilisateur via repository
    func fetchUserData() {
        do {
            //Le Repository nous renvoie un Data Transfert Object simple, pas une entité CoreData
            guard let user = try repository.getUser() else {
                errorMessage = "Aucun utilisateur trouvé."
                return
            }
            // On transfère les données du UserModel vers les propriétés @Published.-> Maj de la Vue.
            firstName          = user.firstName
            lastName           = user.lastName
            email              = user.email
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
