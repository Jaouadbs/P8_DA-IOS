//
//  UserDataViewModelTests.swift
//  AristaTests
//
//  Created by Jaouad on 03/03/2026.
//


import XCTest
import CoreData
import Combine
@testable import Arista

final class UserDataViewModelTests: XCTestCase {

    var cancellables = Set<AnyCancellable>()

    func test_WhenNoUserIsInDatabase_ErrorMessageIsSet() {
        let persistence = PersistenceController(inMemory: true)
        emptyUsers(context: persistence.container.viewContext)

        let viewModel   = UserDataViewModel(context: persistence.container.viewContext)
        let expectation = XCTestExpectation(description: "error message set")

        viewModel.$errorMessage
            .compactMap { $0 }
            .sink { message in
                XCTAssertFalse(message.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5)
    }

    func test_WhenUserExistsInDatabase_PropertiesAreCorrectlyFilled() {
        let persistence = PersistenceController(inMemory: true)
        emptyUsers(context: persistence.container.viewContext)

        addUser(context: persistence.container.viewContext,
                firstName: "Charlotte", lastName: "Razoul",
                email: "charlotte@example.com", stepGoal: 10_000,
                sleepGoal: 480, hydrationGoal: 2_000, caloriesGoal: 500)

        let viewModel   = UserDataViewModel(context: persistence.container.viewContext)
        let expectation = XCTestExpectation(description: "properties filled")

        viewModel.$firstName
            .filter { !$0.isEmpty }
            .sink { _ in
                XCTAssertEqual(viewModel.firstName,          "Charlotte")
                XCTAssertEqual(viewModel.lastName,           "Razoul")
                XCTAssertEqual(viewModel.email,              "charlotte@example.com")
                XCTAssertEqual(viewModel.dailyStepGoal,      10_000)
                XCTAssertEqual(viewModel.sleepHoursGoal,     480)
                XCTAssertEqual(viewModel.hydrationMlGoal,    2_000)
                XCTAssertEqual(viewModel.caloriesBurnedGoal, 500)
                XCTAssertNil(viewModel.errorMessage)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5)
    }

    // MARK: - Helpers

    private func emptyUsers(context: NSManagedObjectContext) {
        let request = User.fetchRequest()
        let objects = try! context.fetch(request)
        objects.forEach { context.delete($0) }
        try! context.save()
    }

    private func addUser(context: NSManagedObjectContext, firstName: String, lastName: String,
                         email: String, stepGoal: Int64, sleepGoal: Int64,
                         hydrationGoal: Int64, caloriesGoal: Int64) {
        let user                = User(context: context)
        user.id                 = UUID()
        user.firstName          = firstName
        user.lastName           = lastName
        user.email              = email
        user.dailyStepGoal      = stepGoal
        user.sleepHoursGoal     = sleepGoal
        user.hydrationMlGoal    = hydrationGoal
        user.caloriesBurnedGoal = caloriesGoal
        user.createdAt          = Date()
        user.updatedAt          = Date()
        try! context.save()
    }
}
