//
//  PersistenceController.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
// JB: initialise la base et insère l'utilisateur unique ainsi que les données de sommeil initiales

import CoreData

struct PersistenceController {
    
    // MARK: - Singleton
    
    /// Singleton partagé pour accèder au contrôleur de persistance
    static let shared = PersistenceController()
    
    // MARK: - Preview
    static var preview : PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        do {
            try viewContext.save()
        } catch {
            // Cas d'un probleme de configuration (entités mal définies,relations incorrects ...)
            let nsError = PersistenceError.previewSaveFailed(underlying: error)
            print("PersistenceController preview - \(nsError.errorDescription ?? "")")
        }
        return result
    } ()
    
    // MARK: - Container
    
    // Conteneur Core Data principal
    let container: NSPersistentContainer
    
    // MARK: - Initialisation
    // Initialise le contrôleur de persistance
    // Si true, les données sont stockées en mémoire, pour les tests et la visualisation
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Arista")
        
        // En mode mémoire, on redirige le store vers /dev/null pour éviter
        // toute écriture sur le disque. Utilisé par les tests et les previews.
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        /// Chargement du magasin persistant(base de données)
        container.loadPersistentStores { (storeDescription,error) in
            if let error = error  {
                // Pour le cas de la production
                // on logue l'erreur pour la traçabilité et on informe l'user
                let persistenceError = PersistenceError.storeLoadFailed(underlying: error)
                print("PersistenceController - Echec du chargement du store : \(persistenceError.errorDescription ?? "")")
            }
        }
        
        // Activation de la fusion automatique des chargements
        // Permet de synchroniser les modifications entres les contextes Core Data
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        
        // Insertion des données par défaut (utilisateur + sessions de sommeil).
        // Ignorée en mode inMemory pour garantir un environnement vierge
        // lors de l'exécution des tests unitaires.
        if inMemory == false {
            do {
                try DefaultData(viewContext: container.viewContext).apply()
            } catch {
                
                print("PersistenceController - Echec des données par défaut ")
            }
        }
    }
}


// MARK: - Erreurs possibles du PersistenceController
enum PersistenceError: LocalizedError {
    case storeLoadFailed(underlying: Error)
    case previewSaveFailed(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .storeLoadFailed(let error):
            return "Impossible de changer le store CoreData : \(error.localizedDescription)"
        case .previewSaveFailed(let error):
            return "Impossible d'initailiser le contexte de prévisualisation \(error.localizedDescription)"
        }
    }
}


