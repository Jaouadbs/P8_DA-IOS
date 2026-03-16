//
//  ExerciseListViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//  Dépend uniquement de ExerciseRepositoryProtocol.
//  Gère la logique de la liste des exercices et la suppression

import Foundation
import SwiftUI


class ExerciseListViewModel: ObservableObject {
    
    // MARK: - Published
    
    @Published var exercises: [ExerciseModel] = []
    @Published var errorMessage: String?
    
    // MARK: - Child ViewModel
    /// On crée le ViewModel d'ajout.
    /// Cela permet de partager les meme repo
    let addExerciseViewModel: AddExerciseViewModel
    
    // MARK: - Private
    private let repository : ExerciseRepositoryProtocol
    
    // MARK: - Init
    /// L'initialiseur reçoit les deux repositories nécessaires.
    init(exerciseRepository: ExerciseRepositoryProtocol,
         userRepository:     UserRepositoryProtocol) {
        self.repository = exerciseRepository
        
        // On initialise le sous-ViewModel pour l'ajout d'exercice.
        self.addExerciseViewModel = AddExerciseViewModel (
            exerciseRepository: exerciseRepository,
            userRepository:     userRepository
        )
        
        // Premier chargement des données.
        fetchExercises()
    }
    
    // MARK: - Actions
    
    // Recharge la liste des exercices depuis le Repository
    func fetchExercises() {
        do {
            //On recupère les ExerciseModel
            exercises = try repository.getExercises()
        } catch {
            errorMessage = "Erreur lors de chargement des exercices."
            print("ExerciseListViewModel - reload : \(error.localizedDescription)")
        }
    }
    
    // Relance la requête-  appelé via onAppear et onDismiss de la vue liste
    func reload() {
        fetchExercises()
    }
    
    // Supprime un exercice suite à un balayage (swipe-to-delete) dans la List.
    func deleteExercise(at offsets: IndexSet) {
        offsets.forEach { index in
            let exercise = exercises[index]
            do {
                try repository.deleteExercise(withId: exercise.id)
            } catch {
                errorMessage = "Erreur lors de la suppression de l'exercice."
                print("ExerciseListViewModel - deleteExercise : \(error.localizedDescription)")
            }
        }
        // Maj locale dans relancer la requête complete
        exercises.remove(atOffsets: offsets)
    }
    
    // MARK: - Formatage
    
    /// Convertit une durée en minutes (Int64) en chaîne lisible (ex: 45 → "45 min")
    static func formattedDuration(_ minutes: Int64) -> String {
        return"\(minutes) min"
    }
    
    /// Retourne le nom de l'icône SF Symbols correspondant à une catégorie d'exercice
    static func icon(for category: String?) -> String {
        switch category {
        case "cardio":      return "heart.fill"
        case "musculation": return "dumbbell.fill"
        case "yoga":        return "figure.mind.and.body"
        case "marche":      return "figure.walk"
        case "sport":       return "sportscourt.fill"
        default:            return "figure.mixed.cardio"
        }
    }
    
    /// Retourne la couleur associée à une catégorie d'exercice
    static func color(for category: String?) -> Color {
        switch category {
        case "cardio":      return .red
        case "musculation": return .blue
        case "yoga":        return .green
        case "marche":      return .orange
        case "sport":       return .purple
        default:            return .gray
        }
    }
}


