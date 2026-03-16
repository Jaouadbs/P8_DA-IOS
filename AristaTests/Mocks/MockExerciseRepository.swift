//
//  MockExerciseRepository.swift
//  AristaTests
//
//  Created by Jaouad on 15/03/2026.
//
//  Mock  simulant une base de données d'exercices.
//  Permet de vérifier à la fois les données renvoyées et la capture des arguments.
//
//

import Foundation
@testable import Arista

final class MockExerciseRepository: ExerciseRepositoryProtocol {

    // MARK: - Database en mémoire

    ///Simule le stockage CoreData.
    private var exercises: [ExerciseModel]

    // MARK: - Configuration

    /// Permet de simuler un crash du repository pour tester la gestion d'erreurs UI
    var errorToThrow: Error?


    // MARK: - Traçabilité

    ///Compteur d'appels
    private(set) var getExercisesCallCount = 0
    private(set) var addExercisesCallCount = 0
    private(set) var deleteExerciseCallCount = 0

    /// Capture des arguments. véifier que le VM transmets les bonnes données de formulaire
    private(set) var lastAddedCategory: String?
    private(set) var lastAddedDuration: Int64?
    private(set) var lastAddedIntensity: String?
    private(set) var lastAddedStartDate: Date?

    // MARK: - Initialisation

    init(exercises: [ExerciseModel] = [], error: Error? = nil) {
        self.exercises  = exercises
        self.errorToThrow = error
    }

    // MARK: - ExerciseRepositoryProtocol
    func getExercises() throws -> [ExerciseModel] {
        getExercisesCallCount += 1
        if let error = errorToThrow {throw error}
        return exercises
    }
    func addExercise(category: String, duration: Int64, intensity: String, startDate: Date) throws {
        addExercisesCallCount += 1
        if let error = errorToThrow {throw error }

        // On Capture les paramètres pour pouvoir faire des XCTAssert dessus plus tard
        lastAddedCategory = category
        lastAddedDuration = duration
        lastAddedIntensity = intensity
        lastAddedStartDate = startDate

        // On simule l'ajout réel pour que le prochain getExercises() reflète le changement
        let newExercise = ExerciseModel(
            id: UUID(),
            category: category,
            duration: duration,
            intensity: intensity,
            startDate: startDate
        )
        exercises.insert(newExercise, at: 0)
    }

    func deleteExercise(withId id: UUID) throws {
        deleteExerciseCallCount += 1
        if let error = errorToThrow {throw error}

        // Simule la suppression réelle
        exercises.removeAll() {$0.id == id }
    }
}
