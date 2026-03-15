//
//  ExerciseRepositoryProtocol.swift
//  Arista
//
//  Created by Jaouad on 13/03/2026.
//  Abstraction de la couche aux données exercice.
//  Les ViewModels dépendent de ce protocole, pas de l'implémentation CoreData.

import Foundation

protocol ExerciseRepositoryProtocol {
    /// Récupère tous les exercices, triés du plus récent au plus ancien.
    func getExercises() throws -> [ExerciseModel]

    /// Crée et persiste un nouvel exercice lié à l'utilisateur existant.
    func addExercise(
        category: String,
        duration: Int64,
        intensity: String,
        startDate: Date
    ) throws

    /// Supprime l'exercice indentifié par son UUID
    func deleteExercise(withId id: UUID) throws
}
