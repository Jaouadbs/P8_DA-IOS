//
//  ExerciseListView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI
import CoreData


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
                        ForEach(viewModel.exercises) { exercise in ExerciseRow(exercise: exercise)
                        }
                        .onDelete { offsets in
                            viewModel.deleteExercise(at: offsets)
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
                // Bouton supprimer natif
                ToolbarItem(placement: .topBarLeading) {
                    if !viewModel.exercises.isEmpty {
                        EditButton()
                    }
                }
            }
            .onAppear{ viewModel.reload()}
            .sheet(isPresented: $showAddExercise, onDismiss: { viewModel.reload()}) {
                AddExerciseView()
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
    let exercise: Exercise

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: ExerciseListViewModel.icon(for: exercise.category))
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44,height: 44)
                .background(ExerciseListViewModel.color(for: exercise.category).gradient)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.category?.capitalized ?? "_")
                    .fontWeight(.semibold)
                HStack(spacing: 8) {
                    Label(
                        ExerciseListViewModel.formattedDuration(exercise.duration),
                        systemImage: "clock"
                    )
                    Label(
                        exercise.intensity?.capitalized ?? "_",
                        systemImage: "bolt.fill"
                    )
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer()

            if let date = exercise.startDate{
                Text(date, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: Perviews

#Preview("Liste vide") {
    makeExercisePreview(withData: false)
}

#Preview("Avec exercices") {
    makeExercisePreview(withData: true)
}

private func makeExercisePreview(withData: Bool) -> some View {
    let persistence = PersistenceController.preview
    let context = persistence.container.viewContext

    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Exercise.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

    do {
        try context.execute(deleteRequest)
        try context.save()
    } catch {
        print("Erreur lors de la suppression des exercices : \(error)")
    }

    if withData {
        let user = User(context: context)
        user.id = UUID()
        user.firstName = "Charlotte"
        user.lastName = "Razoul"
        try? context.save()

        let exercicesData: [(String, Int64, String, TimeInterval)] = [
            ("cardio",      30, "elevee",      0),
            ("musculation", 60, "tres_elevee", -(60 * 60 * 24)),
            ("yoga",        45, "faible",      -(60 * 60 * 24 * 2)),
            ("marche",      90, "moderee",     -(60 * 60 * 24 * 3)),
            ("sport",       20, "elevee",      -(60 * 60 * 24 * 4))
        ]
        for data in exercicesData {
            let exercise = Exercise(context: context)
            exercise.id = UUID()
            exercise.category = data.0
            exercise.duration = data.1
            exercise.intensity = data.2
            exercise.startDate = Date(timeIntervalSinceNow: data.3)
            exercise.user = user
        }
        try? context.save()
    }
    return ExerciseListView(viewModel: ExerciseListViewModel(context: context))
        .environment(\.managedObjectContext, context)
}


