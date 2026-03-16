//
//  UserDataView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

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
/// Composant d'affichage réutilisable pour une ligne icône / libellé / valeur
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


// MARK: - PREVIEWS

#Preview {
    // 1. Création d'un Repository de test (Mock)
    let mockRepo = MockUserRepository()
    
    // 2. Injection du Repo dans le ViewModel
    let viewModel = UserDataViewModel(repository: mockRepo)
    
    // 3. Retour de la vue avec le ViewModel prêt
    UserDataView(viewModel: viewModel)
}

// MARK: - Mock pour la Preview

/// Une version simplifiée du repository qui n'utilise pas Core Data,
/// juste pour l'affichage dans Xcode.
private struct MockUserRepository: UserRepositoryProtocol {
    func getUser() throws -> UserModel? {
        return UserModel(
            firstName: "Charlotte",
            lastName: "Razoul",
            email: "charlotte@arista.com",
            dailyStepGoal: 10000,
            sleepHoursGoal: 480, // 8 heures
            hydrationMlGoal: 2000,
            caloriesBurnedGoal: 500
        )
    }
}




