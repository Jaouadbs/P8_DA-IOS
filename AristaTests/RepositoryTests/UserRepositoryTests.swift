//
//  UserRepositoryTests.swift
//  AristaTests
//
//  Created by Jaouad on 03/03/2026.
//  Tests d'intégration pour la persistance utilisateur.
//  Vérifie que le Repository communique correctement avec CoreData.

import XCTest
import CoreData
@testable import Arista

final class UserRepositoryTests: XCTestCase {

    // MARK: - Propriétés

    var persistenceController: PersistenceController!
    var context : NSManagedObjectContext!

    // MARK: - Configuration / Nettoyage

    /// Préparer l'environnement avant chaque test
    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
        context               = persistenceController.container.viewContext
    }
    /// Nettoie la base après chaque test
    override func tearDownWithError() throws {
        let request = User.fetchRequest()
        let users =  try  context.fetch(request)

        // On supprime tous les utilisateurs pour repartir à zero au prochain test
        users.forEach {context.delete($0)}
        try context.save()

        context = nil
        persistenceController = nil
    }
    // MARK: - Tests

    /// Verifie que le repository gère correctement une BDD vide
    func test_WhenNoUserInDatabase_GetUser_ReturnsNil() throws {

        // GIVEN
        let repository = UserRepository(viewContext: context)

        // WHEN
        let result = try repository.getUser()

        // THEN : On s'attend à recevoir nil
        XCTAssertNil(result)
    }

    /// Vérifie que les données enregistrées sont correctement lues et transformées
    func test_WhenOneUserInDatabase_GetUser_ReturnsThatUser() throws {
        // GIVEN
        insertUser(
            firstName:          "Charlotte",
            lastName:           "Razoul",
            email:              "charlotte@example.com",
            dailyStepGoal:      10_000,
            sleepHoursGoal:     480,
            hydrationMlGoal:    2_000,
            caloriesBurnedGoal: 500
        )

        let repository = UserRepository(viewContext:context)

        //WHEN : on recupère l'user via le repository
        let result = try repository.getUser()

        //THEN : Les data recupérées doivent etre indentiques
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.firstName,      "Charlotte")
        XCTAssertEqual(result?.lastName,       "Razoul")
        XCTAssertEqual(result?.email,          "charlotte@example.com")
        XCTAssertEqual(result?.dailyStepGoal,  10_000)
        XCTAssertEqual(result?.sleepHoursGoal, 480)
        XCTAssertEqual(result?.hydrationMlGoal, 2_000)
        XCTAssertEqual(result?.caloriesBurnedGoal, 500)
    }

    /// Vérifie que le fetchLimit est bien respecté (un seul utilisateur retourné)
    func test_WhenMultipleUsersInDatabase_GetUser_ReturnsExactlyOneUser() throws {
        // GIVEN : On insère deux utilisateurs différents
        insertUser(firstName: "Charlotte", lastName: "Razoul", email: "c@ex.com",
                   dailyStepGoal: 100, sleepHoursGoal: 100, hydrationMlGoal: 100, caloriesBurnedGoal: 100)
        insertUser(firstName: "Alice", lastName: "Dupont", email: "a@ex.com",
                   dailyStepGoal: 200, sleepHoursGoal: 200, hydrationMlGoal: 200, caloriesBurnedGoal: 200)

        let repository = UserRepository(viewContext: context)

        // WHEN
        let result = try repository.getUser()

        // THEN : fetchLimit = 1 garantit qu'un seul UserModel est retourné
        XCTAssertNotNil(result)
    }

    /// Vérifie le découplage : le Repository doit renvoyer un UserModel , pas un objet Core Data
    func test_GetUser_ReturnsUserModel_NotCoreDataEntity() throws {
        // GIVEN
        insertUser(
            firstName: "Charlotte",
            lastName: "Razoul",
            email: "c@ex.com",
            dailyStepGoal: 100,
            sleepHoursGoal: 100,
            hydrationMlGoal: 100,
            caloriesBurnedGoal: 100)

        let repository = UserRepository(viewContext: context)

        // WHEN
        let result = try repository.getUser()

        // THEN : On vérifie que le type retourné est bien UserModel
        XCTAssertNotNil(result)
        XCTAssertTrue(type(of: result!) == UserModel.self)
    }

    // MARK: - Helpers

    /// Méthode pour insérer un User "NSManagedObject" dans le contexte de test
    @discardableResult
    private func insertUser (
        firstName:          String,
        lastName:           String,
        email:              String,
        dailyStepGoal:      Int64,
        sleepHoursGoal:     Int64,
        hydrationMlGoal:    Int64,
        caloriesBurnedGoal: Int64
    ) -> User {
        let user = User(context: context)
        user.id = UUID()
        user.firstName = firstName
        user.lastName = lastName
        user.email = email
        user.dailyStepGoal = dailyStepGoal
        user.sleepHoursGoal = sleepHoursGoal
        user.hydrationMlGoal = hydrationMlGoal
        user.caloriesBurnedGoal = caloriesBurnedGoal
        user.createdAt = Date()
        user.updatedAt = Date()
        try! context.save()         // On force la sauvegarde pour le test
        return user
    }
}
