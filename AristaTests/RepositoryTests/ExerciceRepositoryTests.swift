//
//  ExerciceRepositoryTests.swift
//  AristaTests
//
//  Created by Jaouad on 03/03/2026.
//  Tests d'intégration pour la couche ExerciseRepository.
//  Vérifie les opérations CRUD  directement dans Core Data.
//  Seul fichier autorisé à manipuler le PersistenceController(inMemory: true)

import XCTest
import CoreData
@testable import Arista

final class ExerciseRepositoryTests: XCTestCase {

    // MARK: - Proprités
    var persistenceController : PersistenceController!
    var context: NSManagedObjectContext!

    /// Référence à un utilisateur persistant car un exercice Core Data
    /// nécessite une relation vers un objet 'User' pour être valide.
    var sharedUser: User!

    // MARK: - SetUp

    override func setUpWithError() throws {
        // initialisation d'une DB en RAM
        persistenceController = PersistenceController(inMemory: true)
        context               = persistenceController.container.viewContext
        // Création d'un user obligatoire pour sharedUser, requis pour la relation Exercise → User
        let user = User(context: context)
        user.id = UUID()
        user.firstName          = "Charlotte"
        user.lastName           = "Razoul"
        user.email              = "charlotte@example.com"
        user.dailyStepGoal      = 10_000
        user.sleepHoursGoal     = 480
        user.hydrationMlGoal    = 2_000
        user.caloriesBurnedGoal = 500
        user.createdAt          = Date()
        user.updatedAt          = Date()

        try context.save()
        sharedUser = user
    }

    override func tearDownWithError() throws {
        // Nettoyage de la base après chaque test
        for entity in ["Exercise", "User"] {
            let request = NSFetchRequest<NSManagedObject>(entityName: entity)
            let objects = try context.fetch(request)
            objects.forEach { context.delete($0) }
        }
        try context.save()

        sharedUser            = nil
        context               = nil
        persistenceController = nil
    }

    // MARK: - Tests de Read (Fetch)

    func test_WhenNoExerciseIsInDatabase_GetExercises_ReturnsEmptyList() throws {
        let repository = ExerciseRepository(viewContext: context)

        // On Verifie que le repository renvoie une liste vide pas un nil
        let result = try repository.getExercises()

        XCTAssertTrue(result.isEmpty, "La liste devrait  être vide au départ")
    }

    func test_WhenOneExerciseInDatabase_GetExercises_ReturnsThatExercise() throws {
        // GIVEN : On insère un exercice via le helper
        let date = Date()
        insertExercise(category: "cardio", duration: 45, intensity: "elevee", startDate: date)
        let repository = ExerciseRepository(viewContext: context)

        // WHEN : On récupère les exercices
        let result = try repository.getExercises()

        // THEN : On vérifie l'exactitude du mapping vers le UserModel
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].category, "cardio")
        XCTAssertEqual(result[0].duration, 45)
        XCTAssertEqual(result[0].intensity, "elevee")
        XCTAssertEqual(result[0].startDate, date)
    }

    func test_WhenMultipleExercisesInDatabase_GetExercises_ReturnsSortedByDateDescending() throws {
        // GIVEN : Insertion de 3 dates différentes (T0, T-1 jour, T-2 jours)
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60 * 60 * 24))
        let date3 = Date(timeIntervalSinceNow: -(60 * 60 * 24 * 2))

        // On insère volontairement dans le désordre chronologique
        insertExercise(category: "yoga", duration: 60, intensity: "faible", startDate: date3)
        insertExercise(category: "cardio", duration: 30, intensity: "elevee", startDate: date1)
        insertExercise(category: "musculation", duration: 45, intensity: "moderee", startDate: date2)

        let repository = ExerciseRepository(viewContext: context)

        // WHEN : Lecture des données
        let result = try repository.getExercises()

        // THEN : Vérification du tri (le plus récent en premier)
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].category, "cardio")      // Le plus récent
        XCTAssertEqual(result[1].category, "musculation")
        XCTAssertEqual(result[2].category, "yoga")        // Le plus ancien
    }

    func test_GetExercises_ReturnsExerciseModels_NotCoreDataEntities() throws {
        insertExercise(category: "marche", duration: 30, intensity: "faible", startDate: Date())
        let repository = ExerciseRepository(viewContext: context)

        let result = try repository.getExercises()

        //  on vérifie que la couche View ne reçoit jamais d'objets 'Exercise' de (CoreData)
        // mais uniquement des ExerciseModel.
        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(type(of: result[0]) == ExerciseModel.self)
    }

    // MARK: - Tests Create

    func test_WhenAddingExercise_GetExercises_ReturnsListWithThatExercise() throws {

        // GIVEN
        let repository = ExerciseRepository(viewContext: context)
        let date       = Date()

        // WHEN : On ajoute via la méthode  du repository
        try repository.addExercise(
            category: "sport",
            duration: 20,
            intensity: "tres_elevee",
            startDate: date
        )

        // THEN : On vérifie que c'est bien écrit en base
        let result = try repository.getExercises()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].category, "sport")
        XCTAssertEqual(result[0].duration,  20)
        XCTAssertEqual(result[0].intensity, "tres_elevee")
        XCTAssertEqual(result[0].startDate, date)
    }

    func test_WhenAddingExercise_ExerciseHasNonNilId() throws {
        // GIVEN
        let repository = ExerciseRepository(viewContext: context)

        // WHEN
        try repository.addExercise(category: "cardio", duration: 30, intensity: "moderee", startDate: Date()
        )

        // THEN
        // Vérifie qu'un UUID est bien généré lors de la création
        let result = try repository.getExercises()
        XCTAssertNotNil(result[0].id)
    }

    // MARK: - Tests — Delete

    func test_WhenDeletingExercise_GetExercises_ReturnsEmptyList() throws {
        // GIVEN : Une base avec un exercice existant
        insertExercise(category: "cardio", duration: 30, intensity: "moderee", startDate: Date())
        let repository = ExerciseRepository(viewContext: context)
        let exercises = try repository.getExercises()
        XCTAssertEqual(exercises.count, 1)
        let idToDelete = exercises[0].id

        // WHEN : Suppression par l'ID
        try repository.deleteExercise(withId: idToDelete)

        // THEN : La base doit être vide
        let result = try repository.getExercises()
        XCTAssertTrue(result.isEmpty)
    }

    func test_WhenDeletingOneExerciseAmongMany_OtherExercisesArePreserved() throws {
        // GIVEN : Deux exercices en base
        insertExercise(category: "cardio", duration: 30, intensity: "elevee", startDate: Date())
        insertExercise(category: "musculation", duration: 45, intensity: "moderee", startDate: Date(timeIntervalSinceNow: -3600))

        let repository = ExerciseRepository(viewContext: context)
        let exercises = try repository.getExercises()
        XCTAssertEqual(exercises.count, 2)

        // WHEN : On supprime le premier "cardio"
        try repository.deleteExercise(withId: exercises[0].id)

        // THEN : Le second doit rester intact
        let result = try repository.getExercises()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].category, "musculation")
    }


    // MARK: - Helpers (Méthodes privées d'insertion )

    @discardableResult
    private func insertExercise(
        category: String,
        duration: Int64,
        intensity: String,
        startDate: Date
    ) -> Exercise {
        let exercise        = Exercise(context: context)
        exercise.id         = UUID()
        exercise.category   = category
        exercise.duration   = duration
        exercise.intensity  = intensity
        exercise.startDate  = startDate

        // Attachement à l'utilisateur
        exercise.user = sharedUser

        try! context.save()
        return exercise
    }
}
