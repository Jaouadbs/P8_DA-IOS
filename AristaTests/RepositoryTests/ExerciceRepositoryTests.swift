//
//  ExerciceRepositoryTests.swift
//  AristaTests
//
//  Created by Jaouad on 03/03/2026.
//

import XCTest
import CoreData
@testable import Arista

final class ExerciseRepositoryTests: XCTestCase {
    
    func test_WhenNoExerciseIsInDatabase_GetExercises_ReturnsEmptyList() {
        let persistence = PersistenceController(inMemory: true)
        emptyExercises(context: persistence.container.viewContext)
        
        let repo      = ExerciseRepository(viewContext: persistence.container.viewContext)
        let exercises = try! repo.getExercises()
        
        XCTAssertTrue(exercises.isEmpty)
    }
    
    func test_WhenAddingOneExercise_GetExercises_ReturnsListWithThatExercise() {
        let persistence = PersistenceController(inMemory: true)
        emptyExercises(context: persistence.container.viewContext)
        
        let date = Date()
        addExercise(context: persistence.container.viewContext,
                    category: "cardio", duration: 45,
                    intensity: "moderee", startDate: date)
        
        let repo      = ExerciseRepository(viewContext: persistence.container.viewContext)
        let exercises = try! repo.getExercises()
        
        XCTAssertFalse(exercises.isEmpty)
        XCTAssertEqual(exercises.first?.category,  "cardio")
        XCTAssertEqual(exercises.first?.duration,  45)
        XCTAssertEqual(exercises.first?.intensity, "moderee")
        XCTAssertEqual(exercises.first?.startDate, date)
    }
    
    func test_WhenAddingMultipleExercises_GetExercises_ReturnsListFromMostRecentToOldest() {
        let persistence = PersistenceController(inMemory: true)
        emptyExercises(context: persistence.container.viewContext)
        
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60 * 60 * 24))
        let date3 = Date(timeIntervalSinceNow: -(60 * 60 * 24 * 2))
        
        addExercise(context: persistence.container.viewContext,
                    category: "cardio",      duration: 30, intensity: "elevee",  startDate: date1)
        addExercise(context: persistence.container.viewContext,
                    category: "yoga",        duration: 60, intensity: "faible",  startDate: date3)
        addExercise(context: persistence.container.viewContext,
                    category: "musculation", duration: 45, intensity: "moderee", startDate: date2)
        
        let repo      = ExerciseRepository(viewContext: persistence.container.viewContext)
        let exercises = try! repo.getExercises()
        
        XCTAssertEqual(exercises.count, 3)
        XCTAssertEqual(exercises[0].category, "cardio")
        XCTAssertEqual(exercises[1].category, "musculation")
        XCTAssertEqual(exercises[2].category, "yoga")
    }
    
    func test_WhenAddingExercise_ExerciseIsPersistedInDatabase() {
        let persistence = PersistenceController(inMemory: true)
        emptyExercises(context: persistence.container.viewContext)
        
        let user       = User(context: persistence.container.viewContext)
        user.id        = UUID()
        user.firstName = "Test"
        user.lastName  = "User"
        try! persistence.container.viewContext.save()
        
        let date = Date()
        let repo = ExerciseRepository(viewContext: persistence.container.viewContext)
        try! repo.addExercise(category: "musculation", duration: 60,
                              intensity: "elevee", startDate: date)
        
        let exercises = try! repo.getExercises()
        XCTAssertEqual(exercises.count, 1)
        XCTAssertEqual(exercises.first?.category,  "musculation")
        XCTAssertEqual(exercises.first?.duration,  60)
        XCTAssertEqual(exercises.first?.intensity, "elevee")
        XCTAssertEqual(exercises.first?.startDate, date)
    }
    
    func test_WhenDeletingExercise_ExerciseIsRemovedFromDatabase() {
        let persistence = PersistenceController(inMemory: true)
        emptyExercises(context: persistence.container.viewContext)
        
        addExercise(context: persistence.container.viewContext,
                    category: "cardio", duration: 30,
                    intensity: "moderee", startDate: Date())
        
        let repo      = ExerciseRepository(viewContext: persistence.container.viewContext)
        let exercises = try! repo.getExercises()
        XCTAssertEqual(exercises.count, 1)
        
        try! repo.deleteExercise(exercises.first!)
        let exercisesAfterDelete = try! repo.getExercises()
        XCTAssertTrue(exercisesAfterDelete.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func emptyExercises(context: NSManagedObjectContext) {
        let request = Exercise.fetchRequest()
        let objects = try! context.fetch(request)
        objects.forEach { context.delete($0) }
        try! context.save()
    }
    
    private func addExercise(context: NSManagedObjectContext, category: String,
                             duration: Int64, intensity: String, startDate: Date) {
        let user       = User(context: context)
        user.id        = UUID()
        user.firstName = "Test"
        user.lastName  = "User"
        try! context.save()
        
        let exercise       = Exercise(context: context)
        exercise.id        = UUID()
        exercise.category  = category
        exercise.duration  = duration
        exercise.intensity = intensity
        exercise.startDate = startDate
        exercise.user      = user
        try! context.save()
    }
}
