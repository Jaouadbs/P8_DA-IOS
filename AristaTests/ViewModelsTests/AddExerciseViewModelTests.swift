//
//  AddExerciseViewModelTests..swift
//  AristaTests
//
//  Created by Jaouad on 03/03/2026.
//

import XCTest
import CoreData
import Combine
@testable import Arista

final class AddExerciseViewModelTests: XCTestCase {
    
    var cancellables = Set<AnyCancellable>()
    
    func test_WhenDurationIsZero_AddExercise_ReturnsFalseAndSetsErrorMessage() {
        let persistence = PersistenceController(inMemory: true)
        makeUser(context: persistence.container.viewContext)
        
        let viewModel      = AddExerciseViewModel(context: persistence.container.viewContext)
        viewModel.category = "cardio"
        viewModel.duration = 0   // invalide
        
        let result = viewModel.addExercise()
        
        XCTAssertFalse(result)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func test_WhenCategoryIsEmpty_AddExercise_ReturnsFalseAndSetsErrorMessage() {
        let persistence = PersistenceController(inMemory: true)
        makeUser(context: persistence.container.viewContext)
        
        let viewModel      = AddExerciseViewModel(context: persistence.container.viewContext)
        viewModel.category = "   "  // invalide — espaces uniquement
        viewModel.duration = 30
        
        let result = viewModel.addExercise()
        
        XCTAssertFalse(result)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func test_WhenDataIsValid_AddExercise_ReturnsTrueAndExerciseIsPersisted() {
        let persistence = PersistenceController(inMemory: true)
        emptyExercises(context: persistence.container.viewContext)
        makeUser(context: persistence.container.viewContext)
        
        let viewModel      = AddExerciseViewModel(context: persistence.container.viewContext)
        viewModel.category = "yoga"
        viewModel.duration = 45
        viewModel.intensity = "faible"
        viewModel.startTime = Date()
        
        let result = viewModel.addExercise()
        
        XCTAssertTrue(result)
        XCTAssertNil(viewModel.errorMessage)
        
        let exercises = try! ExerciseRepository(viewContext: persistence.container.viewContext)
            .getExercises()
        XCTAssertEqual(exercises.count,          1)
        XCTAssertEqual(exercises.first?.category,  "yoga")
        XCTAssertEqual(exercises.first?.duration,  45)
        XCTAssertEqual(exercises.first?.intensity, "faible")
    }
    
    func test_DisplayIntensity_ReturnsCorrectLabels() {
        XCTAssertEqual(AddExerciseViewModel.displayIntensity("faible"),      "Faible")
        XCTAssertEqual(AddExerciseViewModel.displayIntensity("moderee"),     "Modérée")
        XCTAssertEqual(AddExerciseViewModel.displayIntensity("elevee"),      "Elevée")
        XCTAssertEqual(AddExerciseViewModel.displayIntensity("tres_elevee"), "Très élevée")
    }
    
    // MARK: - Helpers
    
    private func emptyExercises(context: NSManagedObjectContext) {
        let request = Exercise.fetchRequest()
        let objects = try! context.fetch(request)
        objects.forEach { context.delete($0) }
        try! context.save()
    }
    
    @discardableResult
    private func makeUser(context: NSManagedObjectContext) -> User {
        let user       = User(context: context)
        user.id        = UUID()
        user.firstName = "Charlotte"
        user.lastName  = "Razoul"
        try! context.save()
        return user
    }
}
