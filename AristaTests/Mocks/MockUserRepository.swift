//
//  MockUserRepository.swift
//  AristaTests
//
//  Created by Jaouad on 15/03/2026.
//
//  Ce Mock simule le comportement du vrai Repository sans toucher à Core Data.
//  Il permet de tester le ViewModel dans des conditions contrôlées (succès, erreur, données vides).
//

import Foundation
@testable import Arista

final class MockUserRepository : UserRepositoryProtocol {

    // MARK: - Configuration

    /// User fictif
    var stubbedUser: UserModel?

    /// Erreur optionnelle
    var errorToThrow: Error?

    // MARK: - Traçabilité

    ///Compteur d'appels
    ///Permet de vérifier dans le test que le viewModel à bien soulicité le repository le nbr de fois attendu
    private(set) var getUserCallCount = 0

    // MARK: - Initialisation
    /// configurer le mock à sa création

    init(user: UserModel? = nil,error: Error? = nil) {
        self.stubbedUser = user
        self.errorToThrow = error
    }

    // MARK: - Implémentation du protocole

    /// Methode qui remplace la vraie logique de CoreData
    func getUser() throws -> UserModel? {

        // On enregistre l'appel pour la vérification future
        getUserCallCount += 1

        if let error = errorToThrow{ throw error}

        // Sinon, on retourne l'User ou nil
        return stubbedUser
    }
}
