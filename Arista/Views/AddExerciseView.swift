//
//  AddExerciseView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct AddExerciseView: View {
    
    @ObservedObject var viewModel: AddExerciseViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form{
                Section("Type d'exercice") {
                    Picker("Catégorie", selection: $viewModel.category) {
                        ForEach(AddExerciseViewModel.categories, id: \.self) { cat in Text(cat.capitalized).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Intensité", selection: $viewModel.intensity) {
                        ForEach(AddExerciseViewModel.intensities, id: \.self) { level in
                            //Libellé lisible fourni par le ViewModel
                            Text(AddExerciseViewModel.displayIntensity(level)).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Durée et horaire") {
                    Stepper(
                        "\(viewModel.duration) min",
                        value: $viewModel.duration,
                        in: 5...600,
                        step: 5
                    )
                    
                    DatePicker("Date et Heure",
                               selection: $viewModel.startTime,
                               displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }
            
            .navigationTitle("Ajouter un exercice")
            .navigationBarTitleDisplayMode(.inline)

            // Barre d'outils
            .toolbar {
                ToolbarItem(placement: .cancellationAction){
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction){
                    Button("Enregistrer") {
                        if viewModel.addExercise() {
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Erreur",isPresented: .constant(viewModel.errorMessage != nil)){
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

// MARK: PREVIEW

#Preview {
    // Injection d'un Mock pour la Preview sans CoreData
    let mockExerciseRepo = PreviewAddExerciseRepository()
    let mockUserRepo = PreviewAddUserRepository()

    let viewModel = AddExerciseViewModel(
        exerciseRepository: mockExerciseRepo,
        userRepository: mockUserRepo
    )

    return AddExerciseView(viewModel: viewModel)
}

// MARK: - Mocks pour la Preview

private struct PreviewAddExerciseRepository: ExerciseRepositoryProtocol {
    func getExercises() throws -> [ExerciseModel] { return [] }
    func addExercise(category: String, duration: Int64, intensity: String, startDate: Date) throws {
        print("Mock: Exercice enregistré !")
    }
    func deleteExercise(withId id: UUID) throws {}
}

private struct PreviewAddUserRepository: UserRepositoryProtocol {
    func getUser() throws -> UserModel? {
        // On simule un utilisateur présent pour que le bouton Enregistrer fonctionne dans la preview
        return UserModel(firstName: "Test", lastName: "User", email: "", dailyStepGoal: 0, sleepHoursGoal: 0, hydrationMlGoal: 0, caloriesBurnedGoal: 0)
    }
}
