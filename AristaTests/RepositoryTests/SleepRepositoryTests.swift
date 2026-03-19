//
//  SleepRepositoryTests.swift
//  AristaTests
//
//  Created by Jaouad on 03/03/2026.
//      Tests d'intégration pour la couche SleepRepository.
//       Vérifie que les sessions de sommeil sont bien lues et triées dans Core Data.
//      On s'assure que les relations avec l'utilisateur (User) sont respectées.
//

import XCTest
import CoreData
@testable import Arista

final class SleepRepositoryTests: XCTestCase {

    // MARK: - Propriétés

    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!

    /// Utilisateur de référence
    var sharedUser: User!

    // MARK: - Configuration / Nettoyage

    override func setUpWithError() throws {

        // Initialisation de la base  (In-Memory)
        persistenceController = PersistenceController(inMemory: true)
        context               = persistenceController.container.viewContext

        // Création du profil utilisateur nécessaire pour l'existence des sessions Sleep
        let user                = User(context: context)
        user.id                 = UUID()
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
        // Nettoyage complet des entités pour éviter que les tests ne se polluent entre eux
        for entity in ["Sleep", "User"] {
            let request = NSFetchRequest<NSManagedObject>(entityName: entity)
            let objects = try context.fetch(request)
            objects.forEach { context.delete($0) }
        }
        try context.save()

        sharedUser            = nil
        context               = nil
        persistenceController = nil
    }

    // MARK: - Tests — lecture

    func test_WhenNoSessionInDatabase_GetSleepSessions_ReturnsEmptyList() throws {
        // GIVEN : Un repository sur une base vide
        let repository = SleepRepository(viewContext: context)

        // WHEN : On demande les sessions
        let result = try repository.getSleepSessions()

        // THEN : On vérifie que le tableau est vide
        XCTAssertTrue(result.isEmpty)
    }

    func test_WhenOneSessionInDatabase_GetSleepSessions_ReturnsThatSession() throws {
        // GIVEN : On insère une nuit de sommeil
        let date = Date()
        insertSleep(category: "nuit", duration: 480, quality: "bonne", startDate: date)

        let repository = SleepRepository(viewContext: context)

        // WHEN
        let result = try repository.getSleepSessions()

        // THEN : On vérifie que les données mappées dans le SleepModel sont exactes
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].category, "nuit")
        XCTAssertEqual(result[0].duration, 480)
        XCTAssertEqual(result[0].quality, "bonne")
        XCTAssertEqual(result[0].startDate, date)
    }

    func test_WhenMultipleSessionsInDatabase_GetSleepSessions_ReturnsSortedByDateDescending() throws {
        // GIVEN : Création de 3 dates différentes (Aujourd'hui, Hier, Avant-hier)
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60 * 60 * 24))
        let date3 = Date(timeIntervalSinceNow: -(60 * 60 * 24 * 2))

        // On insère les sessions dans le désordre chronologique pour tester le tri
        insertSleep(category: "nuit", duration: 330, quality: "mauvaise", startDate: date3)
        insertSleep(category: "sieste", duration: 90, quality: "bonne", startDate: date1)
        insertSleep(category: "nuit", duration: 480, quality: "excellente", startDate: date2)

        let repository = SleepRepository(viewContext: context)

        // WHEN : Récupération des données
        let result = try repository.getSleepSessions()

        // THEN : On vérifie que le tri est décroissant (date1 > date2 > date3)
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0].category, "sieste")   // Date 1 (Plus récente)
        XCTAssertEqual(result[1].category, "nuit")     // Date 2
        XCTAssertEqual(result[2].quality, "mauvaise")  // Date 3 (Plus ancienne)
    }
    func test_GetSleepSessions_ReturnsSleepModels_NotCoreDataEntities() throws {
        // GIVEN
        insertSleep(category: "nuit", duration: 420, quality: "moyenne", startDate: Date())
        let repository = SleepRepository(viewContext: context)

        // WHEN
        let result = try repository.getSleepSessions()

        // THEN : on vérifie que le Repository traduit bien
        // les entités 'Sleep' en structures 'SleepModel'.
        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(type(of: result[0]) == SleepModel.self)
    }

    func test_WhenSessionHasEndDate_EndDateIsPreservedInSleepModel() throws {
        // GIVEN : On définit une date de début et une date de fin précise
        let startDate = Date(timeIntervalSinceNow: -(60 * 60 * 8))
        let endDate = Date()
        insertSleep(category: "nuit", duration: 480, quality: "bonne",
                    startDate: startDate, endDate: endDate)
        let repository = SleepRepository(viewContext: context)

        // WHEN
        let result = try repository.getSleepSessions()

        // THEN : On s'assure que l'endDate n'est pas perdue lors de la conversion en SleepModel
        XCTAssertNotNil(result[0].endDate)
        XCTAssertEqual(result[0].endDate, endDate)
    }

    // MARK: - Helpers

        /// Insère une session Sleep dans Core Data et la lie à l'utilisateur partagé.
        @discardableResult
        private func insertSleep(
            category: String,
            duration: Int64,
            quality: String,
            startDate: Date,
            endDate: Date? = nil
        ) -> Sleep {
            let session = Sleep(context: context)
            session.id = UUID()
            session.category = category
            session.duration = duration
            session.quality = quality
            session.startDate = startDate

            // Si aucune date de fin n'est fournie, on la calcule par rapport à la durée (en minutes)
            session.endDate = endDate ?? Date(timeIntervalSince1970: startDate.timeIntervalSince1970 + Double(duration * 60))

            // Relation cruciale avec l'utilisateur
            session.user = sharedUser

            try! context.save()
            return session
        }

}
