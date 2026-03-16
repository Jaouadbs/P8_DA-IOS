//
//  UserDataViewModelTests.swift
//  AristaTests
//
//  Created by Jaouad on 03/03/2026.

//  Ce qu'on teste :
//  1. Comportement quand la base est vide (aucun utilisateur)
//  2. Comportement quand le repository lève une erreur
//  3. Remplissage correct des propriétés Published quand l'utilisateur existe
//

import XCTest
@testable import Arista

final class UserDataViewModelTests: XCTestCase {

    // MARK: - Helpers

    /// Crée un UserModel représentant Charlotte Razoul avec des valeurs connues.
    /// Réutilisé dans tous les tests qui nécessitent un utilisateur valide.
    private func makeCharlotte() -> UserModel {
        UserModel(
            firstName:          "Charlotte",
            lastName:           "Razoul",
            email:              "charlotte@example.com",
            dailyStepGoal:      10_000,
            sleepHoursGoal:     480,    // 8h en minutes
            hydrationMlGoal:    2_000,
            caloriesBurnedGoal: 500
        )
    }

    // MARK: - Tests — base vide

    /// Vérifie que errorMessage est renseigné quand le repository ne retourne aucun utilisateur.
    /// Les propriétés Published doivent rester à leurs valeurs par défaut (chaînes vides, 0).
    func test_WhenRepositoryReturnsNil_ErrorMessageIsSet() {
        // GIVEN — repository vide : aucun utilisateur en base
        let repo = MockUserRepository()
        repo.stubbedUser = nil

        // WHEN — le ViewModel tente de charger les données à l'init
        let viewModel = UserDataViewModel(repository: repo)

        // THEN — un message d'erreur doit être affiché à l'utilisateur
        XCTAssertNotNil(viewModel.errorMessage,         "errorMessage doit être défini si aucun utilisateur trouvé")
        XCTAssertFalse(viewModel.errorMessage!.isEmpty, "Le message d'erreur ne doit pas être vide")
        // Les propriétés doivent rester à leurs valeurs par défaut
        XCTAssertEqual(viewModel.firstName, "", "firstName doit rester vide si pas d'utilisateur")
        XCTAssertEqual(viewModel.lastName,  "", "lastName doit rester vide si pas d'utilisateur")
    }

    // MARK: - Tests — erreur du repository

    /// Vérifie que errorMessage est renseigné quand le repository lève une exception.
    /// Cela simule un problème de lecture CoreData (base corrompue, erreur d'I/O...).
    func test_WhenRepositoryThrows_ErrorMessageIsSet() {
        // GIVEN — le repository simule une erreur de lecture
        let repo = MockUserRepository()
        repo.errorToThrow = NSError(domain: "CoreData", code: 1)

        // WHEN
        let viewModel = UserDataViewModel(repository: repo)

        // THEN — le ViewModel doit capturer l'erreur et l'exposer via errorMessage
        XCTAssertNotNil(viewModel.errorMessage,
                        "errorMessage doit être défini si le repository lève une erreur")
        // Les données ne doivent pas être renseignées en cas d'erreur
        XCTAssertEqual(viewModel.firstName, "", "firstName doit rester vide en cas d'erreur")
    }

    // MARK: - Tests — cas nominal

    /// Vérifie que toutes les propriétés Published sont correctement remplies
    /// quand le repository retourne un utilisateur valide.
    func test_WhenUserExists_AllPropertiesAreCorrectlyFilled() {
        // GIVEN — Charlotte Razoul existe en base
        let repo = MockUserRepository()
        repo.stubbedUser = makeCharlotte()

        // WHEN
        let viewModel = UserDataViewModel(repository: repo)

        // THEN — toutes les propriétés doivent correspondre au UserModel retourné
        XCTAssertEqual(viewModel.firstName,          "Charlotte",             "Le prénom doit être correctement chargé")
        XCTAssertEqual(viewModel.lastName,           "Razoul",                "Le nom doit être correctement chargé")
        XCTAssertEqual(viewModel.email,              "charlotte@example.com", "L'email doit être correctement chargé")
        XCTAssertEqual(viewModel.dailyStepGoal,      10_000,                  "L'objectif de pas doit être correctement chargé")
        XCTAssertEqual(viewModel.sleepHoursGoal,     480,                     "L'objectif de sommeil (480 min = 8h) doit être correct")
        XCTAssertEqual(viewModel.hydrationMlGoal,    2_000,                   "L'objectif d'hydratation doit être correctement chargé")
        XCTAssertEqual(viewModel.caloriesBurnedGoal, 500,                     "L'objectif de calories doit être correctement chargé")
        // Aucune erreur ne doit être affichée si le chargement a réussi
        XCTAssertNil(viewModel.errorMessage, "errorMessage doit être nil si l'utilisateur est trouvé")
    }
}
