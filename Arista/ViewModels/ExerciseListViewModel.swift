//
//  ExerciseListViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import SwiftUI
import CoreData

class ExerciseListViewModel: ObservableObject {
    
    // MARK: - Published
    
    @Published var exercises: [Exercise] = []
    @Published var errorMessage: String?
    
    // MARK: - Private
    
    private let viewContext: NSManagedObjectContext
    
    // MARK: - Init
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
        fetchExercises()
    }
    
    // MARK: - fetch
    
    private func fetchExercises() {
        // TODO: fetch data in CoreData and replace dumb value below with appropriate information
        do {
            exercises = try ExerciseRepository(viewContext: viewContext).getExercises()
            
        } catch {
            errorMessage = "Erreur lors la récupération des exercices."
            print("ExerciseListViewModel - fetchExercises : \(error.localizedDescription)")
        }
    }
    
    // Relance la requête-  appelé via onAppear et onDismiss de la vue liste
    func reload() {
        fetchExercises()
    }
    
    // Supprime un ou plusieurs exercices
    func deleteExercise(at offsets: IndexSet) {
        offsets.forEach { index in
            let exercise = exercises[index]
            do {
                try ExerciseRepository(viewContext: viewContext).deleteExercise(exercise)
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
        case "yoga":        return "figure.mind.add.body"
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


