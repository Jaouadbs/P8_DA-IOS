//
//  UserDataViewModelTests.swift
//  AristaTests
//
//  Created by Jaouad on 03/03/2026.

//  Ce qu'on teste :
//      Comportement quand la base est vide
//      Comportement quand le repository lève une erreur
//      Remplissage correct des propriétés Published quand l'utilisateur existe
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
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.errorMessage!.isEmpty)
        // Les propriétés doivent rester à leurs valeurs par défaut
        XCTAssertEqual(viewModel.firstName, "")
        XCTAssertEqual(viewModel.lastName,  "")
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
        XCTAssertNotNil(viewModel.errorMessage)
        // Les données ne doivent pas être renseignées en cas d'erreur
        XCTAssertEqual(viewModel.firstName, "")
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
        XCTAssertEqual(viewModel.firstName,          "Charlotte")
        XCTAssertEqual(viewModel.lastName,           "Razoul")
        XCTAssertEqual(viewModel.email,              "charlotte@example.com")
        XCTAssertEqual(viewModel.dailyStepGoal,      10_000)
        XCTAssertEqual(viewModel.sleepHoursGoal,     480)
        XCTAssertEqual(viewModel.hydrationMlGoal,    2_000)
        XCTAssertEqual(viewModel.caloriesBurnedGoal, 500)
        // Aucune erreur ne doit être affichée si le chargement a réussi
        XCTAssertNil(viewModel.errorMessage)
    }
}
