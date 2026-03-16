//
//  SleepHistoryView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI


struct SleepHistoryView: View {

    @ObservedObject  var viewModel : SleepHistoryViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.sleepSessions.isEmpty {
                    ContentUnavailableView(
                        "Aucun session",
                        systemImage: "moon.zzz.fill",
                        description: Text("Vos données de sommeil apparaîtront ici")
                    )
                } else {
                    List(viewModel.sleepSessions) { session in
                        SleepRow(session: session)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Historique de Sommeil")
            .alert("Errur", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

// MARK: - Sous-vue SleepRow
private struct SleepRow: View {
    let session: SleepModel

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // l'icone fixe à gauche
            Image(systemName: session.category == "sieste" ? "sun.haze.fill" : "moon.stars.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    (session.category == "sieste" ? Color.orange : Color.indigo).gradient
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))

            // bloc de données
            VStack(alignment: .leading,spacing: 6) {
                // Ligne du titre + Date
                HStack {
                    Text(session.category.capitalized)
                        .fontWeight(.semibold)
                    Spacer()

                    // La Date  poussée à droite
                    Text(session.startDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                // Ligne du bas / Durée et intensité
                HStack(spacing: 16) {
                    // La durée
                    Label(
                        SleepHistoryViewModel.formattedDuration(session.duration),
                        systemImage: "clock"
                    )
                    Label(
                        //Qualité de sommeil
                        session.quality.capitalized,
                        systemImage: SleepHistoryViewModel.qualityIcon(for: session.quality)
                    )
                    .foregroundStyle(SleepHistoryViewModel.qualityColor(for: session.quality))
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }

        .padding(.vertical, 8)
    }
}

// MARK: - Previews

#Preview("Historique Vide") {
    let mockRepo = PreviewSleepRepository(withData: false)
    let viewModel = SleepHistoryViewModel(repository: mockRepo)
    return SleepHistoryView(viewModel: viewModel)
}

#Preview("Avec Sessions") {
    let mockRepo = PreviewSleepRepository(withData: true)
    let viewModel = SleepHistoryViewModel(repository: mockRepo)
    return SleepHistoryView(viewModel: viewModel)
}

// MARK: - Mocks pour la Preview

private struct PreviewSleepRepository: SleepRepositoryProtocol {
    let withData: Bool

    func getSleepSessions() throws -> [SleepModel] {
        guard withData else { return [] }
        let now = Date()
        let night1Start = now
        let night1End = night1Start.addingTimeInterval(480 * 60)
        let napStart = now.addingTimeInterval(-43200)
        let napEnd = napStart.addingTimeInterval(45 * 60)
        let night2Start = now.addingTimeInterval(-86400)
        let night2End = night2Start.addingTimeInterval(360 * 60)
        return [
            SleepModel(id: UUID(), category: "Nuit", duration: 480, quality: "excellente", startDate: night1Start, endDate: night1End),
            SleepModel(id: UUID(), category: "Sieste", duration: 45, quality: "bonne", startDate: napStart, endDate: napEnd),
            SleepModel(id: UUID(), category: "Nuit", duration: 360, quality: "mauvaise", startDate: night2Start, endDate: night2End)
        ]
    }
}
