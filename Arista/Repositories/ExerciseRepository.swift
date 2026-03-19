//
//  ExerciseRepository.swift
//  Arista
//
//  Created by Jaouad on 23/02/2026.
//  Seul fichier autorisé à accèder à CoreData pour l'entité Exercise.
//  Retourne des ExerciseModel

import Foundation
import CoreData

struct ExerciseRepository : ExerciseRepositoryProtocol {
    
    let viewContext: NSManagedObjectContext
    
    // Initialisation avec le contexte de CoreData
    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }
    
    // MARK: - ExerciseRepositoryProtocol
    
    /// Récupère les données et fait le nettoyage
    func getExercises() throws -> [ExerciseModel] {
        let request = Exercise.fetchRequest()
        
        request.sortDescriptors = [
            NSSortDescriptor(SortDescriptor<Exercise>(\.startDate, order:.reverse))
        ]
        // Récupère les entités CoreData et on les transforme
        return try viewContext.fetch(request).compactMap { exercise in
            // check si les données Obligatoire existent
            guard let id        = exercise.id,
                  let category  = exercise.category,
                  let intensity = exercise.intensity,
                  let startDate = exercise.startDate
                    
            else {
                return nil
            }
            // si tout est bon, on crée un objet ExerciseModel qui peut aller dans la vue
            return ExerciseModel(
                id:         id,
                category:   category,
                duration:   exercise.duration,
                intensity:  intensity,
                startDate:  startDate
            )
        }
    }
    
    /// Ajoute un nouvel exerice lié à l'user existant
    //  - Parameters:
    //  category: ENUM — "cardio" ,"musculation" , "yoga" , "marche" , "sport" , "autre"
    //  duration: Durée en minutes (Decimal 6,2)
    //  ntensity: ENUM — "faible" , "moderee" ,"elevee" , "tres_elevee"
    //  startDate: Date et heure de début
    func addExercise(
        category: String,
        duration: Int64,
        intensity: String,
        startDate: Date
    ) throws {
        // On recupère d'abord l'user
        let userEntity = try fetchUserEntity()
        
        // On crée un nouvel objetExercise dans le context
        let newExercise         = Exercise(context: viewContext)
        newExercise.id          = UUID()
        newExercise.category    = category
        newExercise.duration    = duration
        newExercise.intensity   = intensity
        newExercise.startDate   = startDate
        newExercise.user        = userEntity  // on fait le lien avec l'utilisateur
        
        // On enregistre physiquement sur le disque
        try viewContext.save()
    }
    /// Supprime un exercice de la DB par id
    func deleteExercise(withId id:UUID) throws {
        let request = Exercise.fetchRequest()
        
        //On utilise un filtre (Predicate) pour trouver l'exercice precis
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let results = try viewContext.fetch(request)
        
        // On demande la suppression de chaque resultat trouvé
        results.forEach { viewContext.delete($0)}
        
        // On valide la suppression
        try viewContext.save()
    }
    
    // MARK: - Privé
    // Recupère l'user Actuel. pour lier les exercices
    private func fetchUserEntity() throws -> User {
        let request = User.fetchRequest()
        request.fetchLimit = 1      // On ne veut qu'un seul utilisateur
        
        guard let user = try viewContext.fetch(request).first else {
            //si pas d'User, on lance l'erreur
            throw RepositoryError.userNotFound
        }
        return user
    }
}

// MARK: - Erreurs
enum RepositoryError : LocalizedError {
    case userNotFound
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "Aucun utilisateur trouvé. Impossible d'enregistrer l'exercice"
        }
    }
}

