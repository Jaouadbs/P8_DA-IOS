//
//  SleepHistoryView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI
import CoreData

struct SleepHistoryView: View {
    @ObservedObject  var viewModel : SleepHistoryViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.sleepSessions.isEmpty {
                    ContentUnavailableView(
                        "Aucun session",
                        systemImage: "moon.zzz.fill",
                        description: Text("vos données de sommeil apparaîtront ici")
                    )
                } else {
                    List(viewModel.sleepSessions) { session in SleepRow(session: session)
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
    let session: Sleep
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: session.category == "sieste" ? "sun.haze.fill" : "moon.stars.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    (session.category == "sieste" ? Color.orange : Color.indigo).gradient
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading,spacing: 4) {
                Text(session.category?.capitalized ?? "_")
                    .fontWeight(.semibold)
                HStack(spacing: 8) {
                    Label(
                        SleepHistoryViewModel.formattedDuration(session.duration),
                        systemImage: "clock"
                    )
                    Label(
                        session.quality?.capitalized ?? "_",
                        systemImage: SleepHistoryViewModel.qualityIcon(for: session.quality)
                    )
                    .foregroundStyle(SleepHistoryViewModel.qualityColor(for: session.quality))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                
                if let start = session.startDate {
                    Text(start, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: Preview


#Preview("Liste vide") {
    let persistence = PersistenceController(inMemory: true)
    let context = persistence.container.viewContext
    return SleepHistoryView(viewModel: SleepHistoryViewModel(context: context))
        .environment(\.managedObjectContext, context)
}

#Preview("Avec sessions") {
    makeSleepHistoryPreview(withData: true)
}

private func makeSleepHistoryPreview(withData: Bool) -> some View {
    let persistence = PersistenceController.preview
    let context = persistence.container.viewContext
    
    if withData {
        let user = User(context: context)
        user.id = UUID()
        user.firstName = "Charlotte"
        user.lastName = "Razoul"
        try? context.save()
        
        let sessionsData: [(Int64, String, String, TimeInterval)] = [
            (90,  "bonne",      "sieste", -(60 * 60 * 2)),
            (480, "excellente", "nuit",   -(60 * 60 * 24)),
            (330, "mauvaise",   "nuit",   -(60 * 60 * 24 * 2)),
            (360, "moyenne",    "nuit",   -(60 * 60 * 24 * 3)),
            (420, "bonne",      "nuit",   -(60 * 60 * 24 * 4)),
        ]
        for data in sessionsData {
            let session        = Sleep(context: context)
            session.id        = UUID()
            session.duration  = data.0
            session.quality   = data.1
            session.category  = data.2
            session.startDate  = Date(timeIntervalSinceNow: data.3)
            session.endDate    = Date(timeIntervalSinceNow: data.3 + Double(data.0 * 60))
            session.user       = user
        }
        try? context.save()
    }
    return SleepHistoryView(viewModel: SleepHistoryViewModel(context: context))
        .environment(\.managedObjectContext, context)
}



