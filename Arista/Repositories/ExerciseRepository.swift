//
//  ExerciseRepository.swift
//  Arista
//
//  Created by Jaouad on 23/02/2026.
//

import Foundation
import CoreData

struct ExerciseRepository {

    let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }

    /// Récupère tous les exercices, triés du plus récent au plus ancien
    func getExercises() throws -> [Exercise] {

        let request = Exercise.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(SortDescriptor<Exercise>(\.startDate, order:.reverse))
        ]
        return try viewContext.fetch(request)
    }

    /// Ajoute un nouvel exerice lié à l'user existant
    ///  - Parameters:
    ///   - category: ENUM — "cardio" ,"musculation" , "yoga" , "marche" , "sport" , "autre"
    ///   - duration: Durée en minutes (Decimal 6,2)
    ///   - intensity: ENUM — "faible" , "moderee" ,"elevee" , "tres_elevee"
    ///   - startDate: Date et heure de début
    func addExercise(
        category: String,
        duration: Int64,
        intensity: String,
        startDate: Date
    ) throws {
        let newExercise         = Exercise(context: viewContext)
        newExercise.id          = UUID()
        newExercise.category    = category
        newExercise.duration    = duration
        newExercise.intensity   = intensity
        newExercise.startDate   = startDate
        // Relation User, Chaque exercice est lié à un utilisateur spécifique
        newExercise.user        = try UserRepository(viewContext: viewContext).getUser()
        try viewContext.save()
    }
    /// Supprime un exercice de la DB
    func deleteExercise(_ exercise: Exercise) throws {
        viewContext.delete(exercise)
        try viewContext.save()
    }
}
