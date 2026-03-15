//
//  UserModel.swift
//  Arista
//
//  Created by Jaouad on 13/03/2026.

// Objet de tranfert de données - ne dépend pas de CoreData
// Utilisé par UserRepositoryProtocol et UserDataViewModel

import Foundation

struct UserModel {
    let firstName:          String
    let lastName:           String
    let email :             String
    let dailyStepGoal:      Int64
    let sleepHoursGoal:     Int64   // en minutes
    let hydrationMlGoal:    Int64
    let caloriesBurnedGoal: Int64
}
