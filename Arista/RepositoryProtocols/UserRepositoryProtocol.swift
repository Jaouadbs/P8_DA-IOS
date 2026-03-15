//
//  UserRepositoryProtocol.swift
//  Arista
//
//  Created by Jaouad on 13/03/2026.
//  Absraction de la couche accès aux données utilisateur.
//  Les ViewModels dépendent de ce protocole, pas de l'implémentation CoreData

import Foundation

protocol UserRepositoryProtocol {
    /// Récupère l'unique utilisateur de l'application.
    /// Returns: 'UserModel " si un user existe, sinon 'nil'
    func getUser() throws -> UserModel?
}
