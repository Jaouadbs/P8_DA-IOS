//
//  ExerciseListView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

struct ExerciseListView: View {
    @ObservedObject var viewModel : ExerciseListViewModel
    @State private var showAddExercise = false
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.exercises.isEmpty {
                    ContentUnavailableView("Aucun exercice",
                                           systemImage: "figure.run",
                                           description: Text("Ajouter votre premier exercice via le bouton +")
                    )
                } else {
                    List {
                        ForEach(viewModel.exercises) { exercise in
                            ExerciseRow(exercise: exercise)
                        }
                        .onDelete { offsets in viewModel.deleteExercise(at: offsets)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Exercices")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddExercise = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.indigo)
                    }
                }
                // Permet d'activer le mode édition pour supprimer plusieurs éléments
                ToolbarItem(placement: .topBarLeading) {
                    if !viewModel.exercises.isEmpty {
                        EditButton()
                    }
                }
            }
            .onAppear{ viewModel.reload()}
            .sheet(isPresented: $showAddExercise,
                   onDismiss: { viewModel.reload()}) {
                AddExerciseView(viewModel: viewModel.addExerciseViewModel)
            }
                   .alert("Erreur", isPresented: .constant(viewModel.errorMessage != nil)){
                       Button("OK") {}
                   } message: {
                       Text(viewModel.errorMessage ?? "")
                   }
        }
    }
}

// MARK: - Sous-vue ExerciseRow

private struct ExerciseRow: View {
    let exercise: ExerciseModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: ExerciseListViewModel.icon(for: exercise.category))
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44,height: 44)
                .background(ExerciseListViewModel.color(for: exercise.category).gradient)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack (alignment: .leading, spacing: 6) {
                
                HStack {
                    Text(exercise.category.capitalized )
                        .fontWeight(.semibold)
                        .font(.headline)
                    Spacer()
                    Text(exercise.startDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 16){
                    Label(
                        ExerciseListViewModel.formattedDuration(exercise.duration),
                        systemImage: "clock"
                    )
                    Label(
                        exercise.intensity.capitalized ,
                        systemImage: "bolt.fill"
                    )
                    
                }
                
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}


// MARK: - Previews

#Preview("Liste vide") {
    // On utilise un repository de simulation (Mock) qui ne nécessite pas Core Data
    let mockRepo = PreviewExerciseRepository(withData: false)
    let mockUserRepo = PreviewUserRepository()
    let viewModel = ExerciseListViewModel(exerciseRepository: mockRepo, userRepository: mockUserRepo)
    
    return ExerciseListView(viewModel: viewModel)
}

#Preview("Avec exercices") {
    let mockRepo = PreviewExerciseRepository(withData: true)
    let mockUserRepo = PreviewUserRepository()
    let viewModel = ExerciseListViewModel(exerciseRepository: mockRepo, userRepository: mockUserRepo)
    
    return ExerciseListView(viewModel: viewModel)
}

// MARK: - Classes de simulation pour la Preview
// Ces classes respectent les protocoles mais n'importent pas CoreData.

private struct PreviewExerciseRepository: ExerciseRepositoryProtocol {
    let withData: Bool
    
    func getExercises() throws -> [ExerciseModel] {
        guard withData else { return [] }
        return [
            ExerciseModel(id: UUID(), category: "musculation", duration: 30, intensity: "elevee", startDate: Date()),
            ExerciseModel(id: UUID(), category: "cardio", duration: 30, intensity: "elevee", startDate: Date()),
            ExerciseModel(id: UUID(), category: "yoga", duration: 60, intensity: "faible", startDate: Date().addingTimeInterval(-86400)),
            ExerciseModel(id: UUID(), category: "marche", duration: 30, intensity: "elevee", startDate: Date()),
            ExerciseModel(id: UUID(), category: "sport", duration: 30, intensity: "moyen", startDate: Date()),
            ExerciseModel(id: UUID(), category: "autres", duration: 30, intensity: "elevee", startDate: Date()),
            ExerciseModel(id: UUID(), category: "musculation", duration: 30, intensity: "elevee", startDate: Date()),
            ExerciseModel(id: UUID(), category: "cardio", duration: 30, intensity: "elevee", startDate: Date()),
            ExerciseModel(id: UUID(), category: "yoga", duration: 60, intensity: "faible", startDate: Date().addingTimeInterval(-86400)),
            ExerciseModel(id: UUID(), category: "marche", duration: 30, intensity: "elevee", startDate: Date()),
            ExerciseModel(id: UUID(), category: "sport", duration: 30, intensity: "moyen", startDate: Date()),
            ExerciseModel(id: UUID(), category: "autres", duration: 30, intensity: "elevee", startDate: Date()),
            
        ]
    }
    
    func addExercise(category: String, duration: Int64, intensity: String, startDate: Date) throws {}
    func deleteExercise(withId id: UUID) throws {}
}

private struct PreviewUserRepository: UserRepositoryProtocol {
    func getUser() throws -> UserModel? { return nil }
}

