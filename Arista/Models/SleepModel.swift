//
//  SleepModel.swift
//  Arista
//
//  Created by Jaouad on 13/03/2026.
//  Objet de transfert de données - ne dépend pas de CoreData
//  Utilisé par SleepRepositoryProtocol et SleepHisotoryViewModel.

import Foundation

struct SleepModel: Identifiable {
    let id:         UUID
    let category:   String  //  "nuit" , "sieste"
    let duration:   Int64   // minutes entières
    let quality:    String  // "mauvaise", "moyenne", "bonne", "excellente"
    let startDate:  Date
    let endDate:    Date?
}
