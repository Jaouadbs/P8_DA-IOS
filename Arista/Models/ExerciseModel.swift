//
//  ExerciseModel.swift
//  Arista
//
//  Created by Jaouad on 13/03/2026.
// Objet de tranfert de données - ne dépend pas de CoreData
// Utilisé par ExerciseRepositoryProtocol et ExerciseListViewModel.

import Foundation

struct ExerciseModel: Identifiable {
    let id :         UUID
    let category:    String
    let duration:    Int64         // Minutes entières
    let intensity:   String
    let startDate:   Date
}
