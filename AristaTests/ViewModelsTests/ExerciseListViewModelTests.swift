//
//  ExerciseListViewModelTests.swift
//  AristaTests
//
//  Created by Jaouad on 03/03/2026.
//
//
//  Le MockExerciseRepository remplace complètement la couche persistance.
//  L'objectif est de vérifier que le ViewModel réagit correctement aux données reçues.


import XCTest
@testable import Arista

final class ExerciseListViewModelTests: XCTestCase {
    
    // MARK: - Helpers
    
    /// ViewModel prêt à l'emploi avec des données simulées
    private func makeViewModel(
        exercises: [ExerciseModel] = [],
        exerciseError: Error? = nil
    ) -> ExerciseListViewModel {
        ExerciseListViewModel(
            exerciseRepository: MockExerciseRepository(exercises: exercises, error: exerciseError),
            userRepository:     MockUserRepository(user: makeCharlotte())
        )
    }
    /// Simule un utilisateur par défaut pour le UserRepository.
    private func makeCharlotte() -> UserModel {
        UserModel(firstName: "Charlotte", lastName: "Razoul",
                  email: "charlotte@example.com",dailyStepGoal: 10_000, sleepHoursGoal: 480,hydrationMlGoal: 2_000, caloriesBurnedGoal: 500)
    }
    
    // MARK: - Tests — fetch
    
    func test_WhenNoExerciseInRepository_ExercisesIsEmpty() {
        //GIVEN : Repo Vide
        let viewModel = makeViewModel(exercises: [])
        
        // THEN : Liste doit  etre vide et aucune erreur
        XCTAssertTrue(viewModel.exercises.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func test_WhenOneExerciseInRepository_ExercisesContainsThatExercise() {
        // GIVEN : Un repository avec 1 exercice de cardio
        let date = Date()
        let model = ExerciseModel(id: UUID(), category: "cardio", duration: 45,intensity: "elevee", startDate: date)
        let viewModel = makeViewModel(exercises: [model])
        
        // THEN : Le ViewModel doit exposer exactement cet exercice avec les bonnes valeurs
        XCTAssertEqual(viewModel.exercises.count, 1)
        XCTAssertEqual(viewModel.exercises[0].category,  "cardio")
        XCTAssertEqual(viewModel.exercises[0].duration,  45)
        XCTAssertEqual(viewModel.exercises[0].intensity, "elevee")
        XCTAssertEqual(viewModel.exercises[0].startDate, date)
    }
    
    func test_WhenMultipleExercisesInRepository_OrderIsPreservedAsReturnedByRepository() {
        // GIVEN : Une liste d'exercices
        let exercises = [
            ExerciseModel(id: UUID(), category: "cardio", duration: 30, intensity: "elevee", startDate: Date()),
            ExerciseModel(id: UUID(), category: "musculation", duration: 45, intensity: "moderee", startDate: Date(timeIntervalSinceNow: -(60*60*24))),
            ExerciseModel(id: UUID(), category: "yoga",duration: 60, intensity: "faible",  startDate: Date(timeIntervalSinceNow: -(60*60*24*2)))
        ]
        let viewModel = makeViewModel(exercises: exercises)
        
        // THEN : On vérifie que le ViewModel n'a pas modifié l'ordre des éléments
        XCTAssertEqual(viewModel.exercises.count, 3)
        XCTAssertEqual(viewModel.exercises[0].category, "cardio")
        XCTAssertEqual(viewModel.exercises[1].category, "musculation")
        XCTAssertEqual(viewModel.exercises[2].category, "yoga")
    }
    
    func test_WhenRepositoryThrows_ErrorMessageIsSet() {
        // GIVEN : Un repository qui renvoie une erreur lors de la lecture
        let viewModel = makeViewModel(exerciseError: NSError(domain: "test", code: 1))
        
        // THEN : Le ViewModel doit capturer l'erreur et l'afficher à l'utilisateur
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.exercises.isEmpty)
    }
    
    // MARK: - Tests — reload
    
    func test_WhenReloadIsCalled_RepositoryIsQueriedAgain() {
        // GIVEN : Un ViewModel initialisé (le premier fetch a déjà eu lieu)
        let mockRepo = MockExerciseRepository(exercises: [])
        let viewModel = ExerciseListViewModel(
            exerciseRepository: mockRepo,
            userRepository:     MockUserRepository(user: makeCharlotte())
        )
        XCTAssertEqual(mockRepo.getExercisesCallCount, 1)
        
        // WHEN : On force le rechargement
        viewModel.reload()
        
        // THEN : Le compteur d'appels du repository doit être passé à 2
        XCTAssertEqual(mockRepo.getExercisesCallCount, 2)
    }
    
    func test_WhenExerciseAddedThenReload_NewExerciseAppearsInList() {
        // GIVEN : Un ViewModel vide au départ
        let mockRepo = MockExerciseRepository(exercises: [])
        let viewModel = ExerciseListViewModel(
            exerciseRepository: mockRepo,
            userRepository:     MockUserRepository(user: makeCharlotte())
        )
        XCTAssertTrue(viewModel.exercises.isEmpty)
        
        // WHEN : On ajoute un exercice directement dans le Mock, puis on recharge le ViewModel
        try? mockRepo.addExercise(
            category: "sport", duration: 20, intensity: "tres_elevee", startDate: Date()
        )
        viewModel.reload()
        
        // THEN : Le nouvel exercice doit maintenant être visible dans le ViewModel
        XCTAssertEqual(viewModel.exercises.count, 1)
        XCTAssertEqual(viewModel.exercises[0].category, "sport")
    }
    
    // MARK: - Tests — delete
    
    func test_WhenDeletingExercise_ExerciseIsRemovedFromList() {
        // GIVEN : Un ViewModel avec un exercice
        let model    = ExerciseModel(id: UUID(), category: "cardio", duration: 30,intensity: "moderee", startDate: Date())
        let mockRepo = MockExerciseRepository(exercises: [model])
        let viewModel = ExerciseListViewModel(
            exerciseRepository: mockRepo,
            userRepository:     MockUserRepository(user: makeCharlotte())
        )
        XCTAssertEqual(viewModel.exercises.count, 1)
        
        // WHEN : On supprime l'élément à l'index 0
        viewModel.deleteExercise(at: IndexSet(integer: 0))
        
        // THEN : La liste doit être vide et le repo doit avoir reçu l'ordre de suppression
        XCTAssertTrue(viewModel.exercises.isEmpty)
        XCTAssertEqual(mockRepo.deleteExerciseCallCount, 1)
    }
    
    func test_WhenDeleteThrows_ErrorMessageIsSet() {
        // GIVEN
        let model    = ExerciseModel(id: UUID(), category: "yoga", duration: 45,intensity: "faible", startDate: Date())
        let mockRepo = MockExerciseRepository(exercises: [model])
        let viewModel = ExerciseListViewModel(
            exerciseRepository: mockRepo,
            userRepository:     MockUserRepository(user: makeCharlotte())
        )
        // On configure une erreur qui ne se déclenchera que lors de la suppression
        mockRepo.errorToThrow = NSError(domain: "test", code: 2)
        
        // WHEN : On tente de supprimer
        viewModel.deleteExercise(at: IndexSet(integer: 0))
        
        // THEN : Le ViewModel doit détecter l'échec et mettre à jour le message d'erreur
        XCTAssertNotNil(viewModel.errorMessage)
    }
    // MARK: - Tests — formattedDuration (static)

    /// Vérifie que formattedDuration() convertit correctement les minutes en chaîne lisible.
    func test_FormattedDuration_ReturnsCorrectString() {
        XCTAssertEqual(ExerciseListViewModel.formattedDuration(0),   "0 min")
        XCTAssertEqual(ExerciseListViewModel.formattedDuration(30),  "30 min")
        XCTAssertEqual(ExerciseListViewModel.formattedDuration(45),  "45 min")
        XCTAssertEqual(ExerciseListViewModel.formattedDuration(120), "120 min")
    }

    // MARK: - Tests — icon(for:) (static)

    /// Vérifie que icon(for:) retourne le bon nom SF Symbols pour chaque catégorie.
    func test_Icon_ReturnsCorrectIconForEachCategory() {
        XCTAssertEqual(ExerciseListViewModel.icon(for: "cardio"),      "heart.fill")
        XCTAssertEqual(ExerciseListViewModel.icon(for: "musculation"), "dumbbell.fill")
        XCTAssertEqual(ExerciseListViewModel.icon(for: "yoga"),        "figure.mind.and.body")
        XCTAssertEqual(ExerciseListViewModel.icon(for: "marche"),      "figure.walk")
        XCTAssertEqual(ExerciseListViewModel.icon(for: "sport"),       "sportscourt.fill")
        XCTAssertEqual(ExerciseListViewModel.icon(for: "autre"),       "figure.mixed.cardio")
        XCTAssertEqual(ExerciseListViewModel.icon(for: nil),           "figure.mixed.cardio")
    }

    // MARK: - Tests — color(for:) (static)

    /// Vérifie que color(for:) retourne la bonne couleur pour chaque catégorie.
    func test_Color_ReturnsCorrectColorForEachCategory() {
        XCTAssertEqual(ExerciseListViewModel.color(for: "cardio"),      .red)
        XCTAssertEqual(ExerciseListViewModel.color(for: "musculation"), .blue)
        XCTAssertEqual(ExerciseListViewModel.color(for: "yoga"),        .green)
        XCTAssertEqual(ExerciseListViewModel.color(for: "marche"),      .orange)
        XCTAssertEqual(ExerciseListViewModel.color(for: "sport"),       .purple)
        XCTAssertEqual(ExerciseListViewModel.color(for: "autre"),       .gray)
        XCTAssertEqual(ExerciseListViewModel.color(for: nil),           .gray)
    }
}
