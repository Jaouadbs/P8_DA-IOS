//
//  AddExerciseView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct AddExerciseView: View {
    
    @StateObject private var viewModel = AddExerciseViewModel ()
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
            .toolbar {
                ToolbarItem(placement: .cancellationAction){
                    Button("Annuler") { dismiss()}
                }
                ToolbarItem(placement: .confirmationAction){
                    Button("Enregistrer") {
                        if viewModel.addExercise() { dismiss()}
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Erreur",isPresented: .constant(viewModel.errorMessage != nil)){
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

// MARK: PREVIEW

#Preview {
    makeAddExercisePreview()
}

private func makeAddExercisePreview() -> some View {
    let persistence = PersistenceController.preview
    let context     = persistence.container.viewContext
    
    let user = User(context: context)
    user.id = UUID()
    user.firstName = "Charlotte"
    user.lastName = "Razoul"
    try? context.save()
    
    return AddExerciseView()
        .environment(\.managedObjectContext, context)
}
