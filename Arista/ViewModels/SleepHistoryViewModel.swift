//
//  SleepHistoryViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//  Dépend uniquement de SleepRepositoryProtocol

import Foundation
import SwiftUI

class SleepHistoryViewModel: ObservableObject {
    
    // MARK: - Published
    
    @Published var sleepSessions: [SleepModel] = []
    @Published var errorMessage: String?
    
    // MARK: - Private
    ///Le protocole qui permet d'accéder aux données sans savoir comment elles sont stockées.
    private let repository : SleepRepositoryProtocol
    
    // MARK: - Init
    
    /// Initialisation avec injection du repository de sommeil
    init(repository: SleepRepositoryProtocol) {
        self.repository = repository
        fetchSleepSessions()
    }
    
    // MARK: - Fetch
    
    /// le ViewModel décide quand charger les données des sessions depuis le repository
    private func fetchSleepSessions() {
        do {
            sleepSessions = try repository.getSleepSessions()
            
        } catch {
            errorMessage = "Erreur lors de la récupération des sessions de sommeil."
            print("SleepHistoryViewModel - fetchSleepSessions \(error.localizedDescription)")
        }
    }
    
    // MARK: - Formatage
    
    /// Retourne la durée formatée en heure/minutes
    static func formattedDuration(_ minutes: Int64) -> String {
        let h = minutes / 60
        let m = minutes % 60
        
        // Cas de moins d'une heure
        if h == 0 {return"\(m) min"}
        // Cas d'une heure pile
        if m == 0 {return"\(h) h"}
        return "\(h)h\(String(format: "%02d", m))"
    }
    
    /// Retourne le nom de l'icone Symbols correspondant à une qualité de sommeil
    static func qualityIcon(for quality: String?) -> String {
        switch quality {
        case "mauvaise":   return "xmark.circle.fill"
        case "moyenne":    return "minus.circle.fill"
        case "bonne":      return "checkmark.circle.fill"
        case "excellente": return "star.circle.fill"
        default:           return "circle"
        }
    }
    
    /// Retourne la couleur associée à une qualité de sommeil
    static func qualityColor(for quality: String?) -> Color {
        switch quality {
        case "mauvaise":   return .red
        case "moyenne":    return .orange
        case "bonne":      return .green
        case "excellente": return .yellow
        default:           return .secondary
        }
    }
}


