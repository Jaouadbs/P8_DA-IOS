//
//  ExerciseListViewModelTests.swift
//  AristaTests
//
//  Created by Jaouad on 03/03/2026.
//
//  Tests synchrones — aucun import CoreData, aucun Combine, aucun XCTestExpectation.
//  Le MockExerciseRepository remplace complètement la couche persistance.
//

import XCTest
@testable import Arista

final class ExerciseListViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeViewModel(
        exercises: [ExerciseModel] = [],
        exerciseError: Error? = nil
    ) -> ExerciseListViewModel {
        ExerciseListViewModel(
            exerciseRepository: MockExerciseRepository(exercises: exercises, error: exerciseError),
            userRepository:     MockUserRepository(user: makeCharlotte())
        )
    }

    private func makeCharlotte() -> UserModel {
        UserModel(firstName: "Charlotte", lastName: "Razoul",
                email: "charlotte@example.com",
                dailyStepGoal: 10_000, sleepHoursGoal: 480,
                hydrationMlGoal: 2_000, caloriesBurnedGoal: 500)
    }

    // MARK: - Tests — fetch

    func test_WhenNoExerciseInRepository_ExercisesIsEmpty() {
        let viewModel = makeViewModel(exercises: [])

        XCTAssertTrue(viewModel.exercises.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }

    func test_WhenOneExerciseInRepository_ExercisesContainsThatExercise() {
        let date = Date()
        let model = ExerciseModel(id: UUID(), category: "cardio", duration: 45,
                                  intensity: "elevee", startDate: date)
        let viewModel = makeViewModel(exercises: [model])

        XCTAssertEqual(viewModel.exercises.count, 1)
        XCTAssertEqual(viewModel.exercises[0].category,  "cardio")
        XCTAssertEqual(viewModel.exercises[0].duration,  45)
        XCTAssertEqual(viewModel.exercises[0].intensity, "elevee")
        XCTAssertEqual(viewModel.exercises[0].startDate, date)
    }

    func test_WhenMultipleExercisesInRepository_OrderIsPreservedAsReturnedByRepository() {
        let exercises = [
            ExerciseModel(id: UUID(), category: "cardio",      duration: 30, intensity: "elevee",  startDate: Date()),
            ExerciseModel(id: UUID(), category: "musculation", duration: 45, intensity: "moderee", startDate: Date(timeIntervalSinceNow: -(60*60*24))),
            ExerciseModel(id: UUID(), category: "yoga",        duration: 60, intensity: "faible",  startDate: Date(timeIntervalSinceNow: -(60*60*24*2)))
        ]
        let viewModel = makeViewModel(exercises: exercises)

        XCTAssertEqual(viewModel.exercises.count, 3)
        XCTAssertEqual(viewModel.exercises[0].category, "cardio")
        XCTAssertEqual(viewModel.exercises[1].category, "musculation")
        XCTAssertEqual(viewModel.exercises[2].category, "yoga")
    }

    func test_WhenRepositoryThrows_ErrorMessageIsSet() {
        let viewModel = makeViewModel(exerciseError: NSError(domain: "test", code: 1))

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.exercises.isEmpty)
    }

    // MARK: - Tests — reload

    func test_WhenReloadIsCalled_RepositoryIsQueriedAgain() {
        let mockRepo = MockExerciseRepository(exercises: [])
        let viewModel = ExerciseListViewModel(
            exerciseRepository: mockRepo,
            userRepository:     MockUserRepository(user: makeCharlotte())
        )
        XCTAssertEqual(mockRepo.getExercisesCallCount, 1)

        viewModel.reload()

        XCTAssertEqual(mockRepo.getExercisesCallCount, 2)
    }

    func test_WhenExerciseAddedThenReload_NewExerciseAppearsInList() {
        let mockRepo = MockExerciseRepository(exercises: [])
        let viewModel = ExerciseListViewModel(
            exerciseRepository: mockRepo,
            userRepository:     MockUserRepository(user: makeCharlotte())
        )
        XCTAssertTrue(viewModel.exercises.isEmpty)

        try? mockRepo.addExercise(
            category: "sport", duration: 20, intensity: "tres_elevee", startDate: Date()
        )
        viewModel.reload()

        XCTAssertEqual(viewModel.exercises.count, 1)
        XCTAssertEqual(viewModel.exercises[0].category, "sport")
    }

    // MARK: - Tests — delete

    func test_WhenDeletingExercise_ExerciseIsRemovedFromList() {
        let model    = ExerciseModel(id: UUID(), category: "cardio", duration: 30,
                                     intensity: "moderee", startDate: Date())
        let mockRepo = MockExerciseRepository(exercises: [model])
        let viewModel = ExerciseListViewModel(
            exerciseRepository: mockRepo,
            userRepository:     MockUserRepository(user: makeCharlotte())
        )
        XCTAssertEqual(viewModel.exercises.count, 1)

        viewModel.deleteExercise(at: IndexSet(integer: 0))

        XCTAssertTrue(viewModel.exercises.isEmpty)
        XCTAssertEqual(mockRepo.deleteExerciseCallCount, 1)
    }

    func test_WhenDeleteThrows_ErrorMessageIsSet() {
        let model    = ExerciseModel(id: UUID(), category: "yoga", duration: 45,
                                     intensity: "faible", startDate: Date())
        let mockRepo = MockExerciseRepository(exercises: [model])
        let viewModel = ExerciseListViewModel(
            exerciseRepository: mockRepo,
            userRepository:     MockUserRepository(user: makeCharlotte())
        )
        // Erreur configurée après l'init pour ne pas bloquer le fetch initial
        mockRepo.errorToThrow = NSError(domain: "test", code: 2)

        viewModel.deleteExercise(at: IndexSet(integer: 0))

        XCTAssertNotNil(viewModel.errorMessage)
    }
}
