//
//  AristaApp.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

@main
struct AristaApp: App {
    // On recupère le controleur de persistence
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            // On recupère le viewContext
            let context = persistenceController.container.viewContext

            //Repositories
            /// On crée les instances des repo
            let userRepo        = UserRepository(viewContext: context)
            let exerciseRepo    = ExerciseRepository(viewContext: context)
            let sleepRepo       = SleepRepository(viewContext: context)

            // ViewModels
            /// On injecte les repositories dans les ViewModels
            let userVM      = UserDataViewModel(repository: userRepo)
            let exerciseVM  = ExerciseListViewModel(exerciseRepository: exerciseRepo, userRepository: userRepo)
            let sleepVM     = SleepHistoryViewModel(repository: sleepRepo)

            // Vues
            /// On affiche l'interface principale et on distribue les ViewModels aux vues
            TabView {
                UserDataView(viewModel: userVM)
                    .tabItem{ Label("Utilisateur", systemImage: "person.circle.fill")}

                ExerciseListView(viewModel: exerciseVM)
                    .tabItem { Label("Exercices", systemImage: "figure.run") }

                SleepHistoryView(viewModel: sleepVM)
                    .tabItem { Label("Sommeil",   systemImage: "moon.zzz.fill") }

            }
            // Couleur de l'application
            .tint(.indigo)
        }
    }
}
