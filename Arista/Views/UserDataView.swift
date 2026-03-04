//
//  UserDataView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI
import CoreData

struct UserDataView: View {
    @ObservedObject var viewModel : UserDataViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section("Identité") {
                    LabeledRow(icon: "person.fill", label: "Prénom", value: viewModel.firstName)
                    LabeledRow(icon: "person.fill", label: "Nom", value: viewModel.lastName)
                    LabeledRow(icon: "envelope.fill", label: "Email", value: viewModel.email)
                }
                Section("Objectifs quotidiens") {
                    LabeledRow(icon: "figure.walk", label: "Pas", value:"\( viewModel.dailyStepGoal) pas")
                    LabeledRow(icon: "moon.zzz.fill", label: "Sommeil", value: SleepHistoryViewModel.formattedDuration( viewModel.sleepHoursGoal))
                    LabeledRow(icon: "drop.fill", label: "Hydratation", value: "\(viewModel.hydrationMlGoal) ml")
                    LabeledRow(icon: "flame.fill", label: "Calories", value: "\(viewModel.hydrationMlGoal) kcal")
                }
            }
            .navigationTitle("Mon profil")
            .alert("Erreur", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

// MARK: Sous-vue LabeledRow
/// Composant d'afficae réutilisable pour une ligne icône / mabel / valeur
private struct LabeledRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.indigo)
                .frame(width: 24)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}


// MARK : Preiew

#Preview("Avec données") {
    makeUserDataPreview(withUser: true)
}

#Preview("Sans utilisateur - état d'erreur") {
    makeUserDataPreview(withUser: false)
    
}

private func makeUserDataPreview(withUser : Bool) -> some View {
    let persistence = PersistenceController(inMemory: true)
    let context = persistence.container.viewContext
    
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = User.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    do {
        try context.execute(deleteRequest)
        try context.save()
    } catch {
        print("Erreur lors de la suppression des données : \(error)")
    }
    
    if withUser {
        let user                = User(context:context)
        user.id                 = UUID()
        user.firstName          = "Charlotte"
        user.lastName           = "Razoul"
        user.email              = "charlotte.razoul@example.com"
        user.dailyStepGoal      = 10_000
        user.sleepHoursGoal     = 480
        user.hydrationMlGoal    = 2000
        user.caloriesBurnedGoal = 500
        user.createdAt          = Date()
        user.updatedAt          = Date()
        
        
        try? context.save()
    }
    
    return UserDataView(viewModel: UserDataViewModel(context: context))
        .environment(\.managedObjectContext,context)
    
}




