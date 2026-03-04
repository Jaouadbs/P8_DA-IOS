//
//  AddExerciseViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

class AddExerciseViewModel: ObservableObject {
    
    // MARK: - Valeurs ENUM
    
    static let categories : [String] = ["cardio", "musculation", "yoga", "marche", "sport", "autre"]
    static let intensities: [String] = ["faible", "moderee", "elevee", "tres_elevee"]
    
    // MARK: - Published
    @Published var category: String     = "cardio"
    @Published var startTime: Date      = Date()
    @Published var duration: Int64      = 30
    @Published var intensity: String    = "moderee"
    @Published var errorMessage: String?
    
    // MARK: - Private
    
    private let viewContext: NSManagedObjectContext
    
    // MARK: - Initialisation
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
    }
    
    // MARK: - Methodes
    
    /// Tente d'ajouter un exercice en base  après validation.
    /// Returns: true si l'ajout a réussi, false sinon
    func addExercise() -> Bool {
        errorMessage = nil
        
        guard !category.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Veuillez sélectionner une catégorie"
            return false
        }
        guard duration > 0 else {
            errorMessage = "La durée doit étre supérieure à 0 minute."
            return false
        }
        // Vérifier si l'user est présent avant  l'appel au repository
        guard let  _ = try? UserRepository(viewContext: viewContext).getUser() else { errorMessage = "Aucun utilisateur trové. Impossible d'enregistrer l'exercice "
            return false
        }
        do {
            try ExerciseRepository(viewContext: viewContext).addExercise(
                category: category,
                duration: duration,
                intensity: intensity,
                startDate: startTime
            )
            return true
        } catch {
            errorMessage = "Erreur lors de l'enregistrement : \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Formatage
    /// Retourne le libellé lisible d'un niveau d'intensité brut
    static func displayIntensity (_ raw: String) -> String {
        switch raw {
        case "faible":          return "Faible"
        case "moderee":         return "Modérée"
        case "elevee":          return "Elevée"
        case "tres_elevee":     return "Très élevée"
        default:                return raw.capitalized
        }
    }
}
