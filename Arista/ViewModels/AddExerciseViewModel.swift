//
//  AddExerciseViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//  Dépend uniquement des protocoles Repository.

import Foundation


final class AddExerciseViewModel: ObservableObject {
    
    // MARK: - Valeurs ENUM
    
    // Listes utilisées pour remplir les Pickers dans la vue.
    static let categories : [String] = ["cardio", "musculation", "yoga", "marche", "sport", "autre"]
    static let intensities: [String] = ["faible", "moderee", "elevee", "tres_elevee"]
    
    // MARK: - Published
    // Propriétés liées aux composants de formulaire (Picker, Stepper, DatePicker).
    @Published var category: String     = "cardio"
    @Published var startTime: Date      = Date()
    @Published var duration: Int64      = 30
    @Published var intensity: String    = "moderee"
    @Published var errorMessage: String?
    
    // MARK: - Private
    
    // On utilise les protocoles pour rester indépendant de l'implémentation réelle (CoreData).
    private var exerciseRepository : ExerciseRepositoryProtocol
    private var userRepository : UserRepositoryProtocol
    
    // MARK: - Init
    init(
        exerciseRepository: any ExerciseRepositoryProtocol,
        userRepository: any UserRepositoryProtocol
    ) {
        self.exerciseRepository = exerciseRepository
        self.userRepository = userRepository
    }
    
    // MARK: - Actions
    
    /// Tente d'ajouter un exercice après avoir validé les saisies.
    /// Returns: true si l'ajout réussi, false sinon
    func addExercise() -> Bool {
        errorMessage = nil
        
        // Vérifie que la catégorie n'est pas vide
        guard !category.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Veuillez sélectionner une catégorie"
            return false
        }
        // Vérifie que la durée n'est pas null
        guard duration > 0 else {
            errorMessage = "La durée doit étre supérieure à 0 minute."
            return false
        }
        // Vérifie qu'un utilisateur existe en base avant de lier l'exercice
        guard (try? userRepository.getUser()) != nil else {
            errorMessage = "Aucun utilisateur trouvé. Impossible d'enregistrer l'exercice"
            return false
        }
        //Envoi des données au Repository
        do {
            try exerciseRepository.addExercise(
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
    /// Retourne le libellé lisible pour l'utilisateur
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
