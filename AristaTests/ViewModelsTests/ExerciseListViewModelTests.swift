//
//  ExerciseListViewModelTests.swift
//  AristaTests
//
//  Created by Jaouad on 03/03/2026.
//

import XCTest
import CoreData
import Combine
@testable import Arista

final class ExerciseListViewModelTests: XCTestCase {
    
    var cancellables = Set<AnyCancellable>()
    
    // Contexte et user partagé entre tous les tests
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var sharedUser: User!
    
    // MARK: - setUp / tearDown
    
    override func setUpWithError() throws {
        // Appelé avant chaque test — crée un contexte inMemory vierge
        // avec un utilisateur unique
        persistenceController = PersistenceController(inMemory: true)
        context               = persistenceController.container.viewContext
        
        emptyExercises()
        
        // Création de l'utilisateur partagé pour tous les tests
        let user       = User(context: context)
        user.id        = UUID()
        user.firstName = "Charlotte"
        user.lastName  = "Razoul"
        user.email     = "charlotte.razoul@example.com"
        user.dailyStepGoal      = 10_000
        user.sleepHoursGoal     = 480
        user.hydrationMlGoal    = 2_000
        user.caloriesBurnedGoal = 500
        user.createdAt = Date()
        user.updatedAt = Date()
        try context.save()
        
        sharedUser = user
    }
    
    override func tearDownWithError() throws {
        // Appelé après chaque test — nettoyage du contexte
        emptyExercises()
        sharedUser             = nil
        context                = nil
        persistenceController  = nil
        cancellables.removeAll()
    }
    
    // MARK: - Tests
    
    func test_WhenNoExerciseIsInDatabase_FetchExercises_ReturnsEmptyList() {
        let viewModel   = ExerciseListViewModel(context: context)
        let expectation = XCTestExpectation(description: "fetch empty list")
        
        viewModel.$exercises
            .sink { exercises in
                XCTAssertTrue(exercises.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10)
    }
    
    func test_WhenAddingOneExercise_FetchExercises_ReturnsListWithThatExercise() {
        let date = Date()
        addExercise(category: "cardio", duration: 45, intensity: "elevee", startDate: date)
        
        let viewModel   = ExerciseListViewModel(context: context)
        let expectation = XCTestExpectation(description: "fetch one exercise")
        
        viewModel.$exercises
            .sink { exercises in
                XCTAssertFalse(exercises.isEmpty)
                XCTAssertEqual(exercises.first?.category,  "cardio")
                XCTAssertEqual(exercises.first?.duration,  45)
                XCTAssertEqual(exercises.first?.intensity, "elevee")
                XCTAssertEqual(exercises.first?.startDate, date)
                // Vérifie que l'exercice est bien lié à Charlotte Razoul
                XCTAssertEqual(exercises.first?.user?.firstName, "Charlotte")
                XCTAssertEqual(exercises.first?.user?.lastName,  "Razoul")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10)
    }
    
    func test_WhenAddingMultipleExercises_FetchExercises_ReturnsListInRightOrder() {
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60 * 60 * 24))
        let date3 = Date(timeIntervalSinceNow: -(60 * 60 * 24 * 2))
        
        addExercise(category: "cardio",      duration: 30, intensity: "elevee",  startDate: date1)
        addExercise(category: "yoga",        duration: 60, intensity: "faible",  startDate: date3)
        addExercise(category: "musculation", duration: 45, intensity: "moderee", startDate: date2)
        
        let viewModel   = ExerciseListViewModel(context: context)
        let expectation = XCTestExpectation(description: "fetch ordered list")
        
        viewModel.$exercises
            .sink { exercises in
                XCTAssertEqual(exercises.count, 3)
                // Tri décroissant par date — le plus récent en premier
                XCTAssertEqual(exercises[0].category, "cardio")       // date1
                XCTAssertEqual(exercises[1].category, "musculation")  // date2
                XCTAssertEqual(exercises[2].category, "yoga")         // date3
                // Tous les exercices appartiennent au même utilisateur
                XCTAssertEqual(exercises[0].user?.firstName, "Charlotte")
                XCTAssertEqual(exercises[1].user?.firstName, "Charlotte")
                XCTAssertEqual(exercises[2].user?.firstName, "Charlotte")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10)
    }
    
    func test_WhenExerciseAddedAfterInit_Reload_UpdatesTheList() {
        let viewModel = ExerciseListViewModel(context: context)
        
        addExercise(category: "sport", duration: 20, intensity: "tres_elevee", startDate: Date())
        viewModel.reload()
        
        let expectation = XCTestExpectation(description: "reload updates list")
        
        viewModel.$exercises
            .sink { exercises in
                XCTAssertFalse(exercises.isEmpty)
                XCTAssertEqual(exercises.first?.category,          "sport")
                XCTAssertEqual(exercises.first?.user?.firstName,   "Charlotte")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10)
    }
    
    func test_WhenDeletingExercise_ExerciseIsRemovedFromList() {
        addExercise(category: "cardio", duration: 30, intensity: "moderee", startDate: Date())
        
        let viewModel = ExerciseListViewModel(context: context)
        XCTAssertEqual(viewModel.exercises.count, 1)
        
        viewModel.deleteExercise(at: IndexSet(integer: 0))
        
        let expectation = XCTestExpectation(description: "exercise deleted")
        
        viewModel.$exercises
            .sink { exercises in
                XCTAssertTrue(exercises.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 10)
    }
    
    // MARK: - Helpers
    
    /// Supprime tous les exercices du contexte — utilisé dans setUp et tearDown
    private func emptyExercises() {
        let request = Exercise.fetchRequest()
        let objects = try! context.fetch(request)
        objects.forEach { context.delete($0) }
        try! context.save()
    }
    
    /// Ajoute un exercice lié à sharedUser
    private func addExercise(
        category: String,
        duration: Int64,
        intensity: String,
        startDate: Date
    ) {
        let exercise       = Exercise(context: context)
        exercise.id        = UUID()
        exercise.category  = category
        exercise.duration  = duration
        exercise.intensity = intensity
        exercise.startDate = startDate
        exercise.user      = sharedUser   
        try! context.save()
    }
}
