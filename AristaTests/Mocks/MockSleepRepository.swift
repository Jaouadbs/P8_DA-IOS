
//  MockSleepRepository.swift
//  AristaTests
//
//  Created by Jaouad on 15/03/2026.
//  Mock pour simuler l'historique de sommeil.
//  Permet de tester SleepHistoryViewModel sans dépendre de Core Data.

import Foundation
@testable import Arista

final class MockSleepRepository: SleepRepositoryProtocol {
    
    // MARK: - Configuration des données de tests
    
    //Liste de sessions que le mock va retourner
    var stubbedSessions: [SleepModel]
    
    var errorToThrow: Error?
    
    // MARK: - Traçabilité
    
    // Compteur d'appels. Important pour vérifier que le VM en rafraichit pas la liste inutilement
    private(set) var getSleepSessionsCallCount = 0
    
    // MARK: - Initialisation
    
    // init de mock avec des données par défaut ou une erreur
    init(sessions:[SleepModel] = [], error: Error? = nil) {
        self.stubbedSessions = sessions
        self.errorToThrow    = error
    }
    
    // MARK: - SleepRepositoryProtocol
    
    // Simule la récupérations des sessions de sommeil
    func getSleepSessions() throws -> [SleepModel] {
        getSleepSessionsCallCount += 1
        
        // simul l'échec si une erreur
        if let error = errorToThrow {throw error}
        
        // Retoune les données fictives
        return stubbedSessions
    }
}
