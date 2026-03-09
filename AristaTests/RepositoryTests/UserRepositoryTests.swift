//
//  UserRepositoryTests.swift
//  AristaTests
//
//  Created by Jaouad on 03/03/2026.
//

import XCTest
import CoreData
@testable import Arista

final class UserRepositoryTests: XCTestCase {
    
    func test_WhenNoUserIsInDatabase_GetUser_ReturnsNil() {
        let persistence = PersistenceController(inMemory: true)
        emptyUsers(context: persistence.container.viewContext)
        
        let repo = UserRepository(viewContext: persistence.container.viewContext)
        let user = try! repo.getUser()
        
        XCTAssertNil(user)
    }
    
    func test_WhenUserExistsInDatabase_GetUser_ReturnsTheUser() {
        let persistence = PersistenceController(inMemory: true)
        emptyUsers(context: persistence.container.viewContext)
        
        addUser(context: persistence.container.viewContext,
                firstName: "Charlotte", lastName: "Razoul",
                email: "charlotte@example.com", stepGoal: 10_000, sleepGoal: 480)
        
        let repo = UserRepository(viewContext: persistence.container.viewContext)
        let user = try! repo.getUser()
        
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.firstName,      "Charlotte")
        XCTAssertEqual(user?.lastName,       "Razoul")
        XCTAssertEqual(user?.email,          "charlotte@example.com")
        XCTAssertEqual(user?.dailyStepGoal,  10_000)
        XCTAssertEqual(user?.sleepHoursGoal, 480)
    }
    
    func test_WhenMultipleUsersExist_GetUser_ReturnsOnlyOne() {
        let persistence = PersistenceController(inMemory: true)
        emptyUsers(context: persistence.container.viewContext)
        
        addUser(context: persistence.container.viewContext,
                firstName: "Alice", lastName: "A", email: "a@a.com", stepGoal: 8_000, sleepGoal: 420)
        addUser(context: persistence.container.viewContext,
                firstName: "Bob", lastName: "B", email: "b@b.com", stepGoal: 6_000, sleepGoal: 480)
        
        let repo = UserRepository(viewContext: persistence.container.viewContext)
        let user = try! repo.getUser()
        
        XCTAssertNotNil(user)
    }
    
    // MARK: - Helpers
    
    private func emptyUsers(context: NSManagedObjectContext) {
        let request = User.fetchRequest()
        let objects = try! context.fetch(request)
        objects.forEach { context.delete($0) }
        try! context.save()
    }
    
    private func addUser(context: NSManagedObjectContext, firstName: String, lastName: String,
                         email: String, stepGoal: Int64, sleepGoal: Int64) {
        let user            = User(context: context)
        user.id             = UUID()
        user.firstName      = firstName
        user.lastName       = lastName
        user.email          = email
        user.dailyStepGoal  = stepGoal
        user.sleepHoursGoal = sleepGoal
        user.createdAt      = Date()
        user.updatedAt      = Date()
        try! context.save()
    }
}
