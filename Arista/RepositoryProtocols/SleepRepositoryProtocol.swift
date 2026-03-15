//
//  SleepRepositoryProtocol.swift
//  Arista
//
//  Created by Jaouad on 13/03/2026.
//  Abstraction de la couche accès aux données sommeil.
//  Les ViewModels dépendent de ce protocole, pas de l'implémentation

import Foundation

protocol SleepRepositoryProtocol {
    /// Récupère toutes les sessions de sommeil, trièes de la plus récente à la plus ancienne.
    func getSleepSessions() throws -> [SleepModel]
}
