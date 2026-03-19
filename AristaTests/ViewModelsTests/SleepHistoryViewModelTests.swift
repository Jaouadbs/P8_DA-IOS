//
//  SleepHistoryViewModelTests.swift
//  AristaTests
//
//  Created by Jaouad on 03/03/2026.
//
//  Ce qu'on teste :
//      Chargement des sessions depuis le repository (vide, 1 session, plusieurs)
//      Comportement en cas d'erreur du repository
//      Formatage statique des durées (formattedDuration)
//      Icône et couleur selon la qualité du sommeil
//

import XCTest
@testable import Arista

final class SleepHistoryViewModelTests: XCTestCase {

    // MARK: - Tests — chargement des sessions

    /// Vérifie que sleepSessions est vide quand le repository ne contient aucune session.
    /// Aucun message d'erreur ne doit être affiché dans ce cas — c'est un état normal.
    func test_WhenNoSessionInRepository_SleepSessionsIsEmpty() {
        // GIVEN — repository vide
        let repository = MockSleepRepository(sessions: [])

        // WHEN — le ViewModel charge les données à l'init
        let viewModel = SleepHistoryViewModel(repository: repository)

        // THEN
        XCTAssertTrue(viewModel.sleepSessions.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }

    /// Vérifie que la session retournée par le repository est bien exposée dans sleepSessions,
    /// avec toutes ses propriétés correctement mappées.
    func test_WhenOneSessionInRepository_SleepSessionsContainsThatSession() {
        // GIVEN — une session de nuit de 8h de bonne qualité
        let date    = Date()
        let session = SleepModel(
            id:        UUID(),
            category:  "nuit",
            duration:  480,     // 8h en minutes
            quality:   "bonne",
            startDate: date,
            endDate:   nil
        )
        let repository = MockSleepRepository(sessions: [session])

        // WHEN
        let viewModel = SleepHistoryViewModel(repository: repository)

        // THEN
        XCTAssertEqual(viewModel.sleepSessions.count, 1)
        XCTAssertEqual(viewModel.sleepSessions[0].category,  "nuit")
        XCTAssertEqual(viewModel.sleepSessions[0].duration,  480)
        XCTAssertEqual(viewModel.sleepSessions[0].quality,   "bonne")
        XCTAssertEqual(viewModel.sleepSessions[0].startDate, date)
    }

    /// Vérifie que l'ordre des sessions est conservé tel que retourné par le repository.
    /// C'est le repository qui est responsable du tri décroissant — le ViewModel se contente d'afficher.
    func test_WhenMultipleSessionsInRepository_OrderIsPreservedAsReturnedByRepository() {
        // GIVEN — 3 sessions déjà triées du plus récent au plus ancien (comme le ferait SleepRepository)
        let sessions = [
            SleepModel(id: UUID(), category: "sieste", duration: 90,  quality: "bonne",
                       startDate: Date(),                                endDate: nil),
            SleepModel(id: UUID(), category: "nuit",   duration: 480, quality: "excellente",
                       startDate: Date(timeIntervalSinceNow: -(60*60*24)),   endDate: nil),
            SleepModel(id: UUID(), category: "nuit",   duration: 330, quality: "mauvaise",
                       startDate: Date(timeIntervalSinceNow: -(60*60*24*2)), endDate: nil)
        ]
        let repository = MockSleepRepository(sessions: sessions)

        // WHEN
        let viewModel = SleepHistoryViewModel(repository: repository)

        // THEN — l'ordre du mock est respecté
        XCTAssertEqual(viewModel.sleepSessions.count, 3)
        XCTAssertEqual(viewModel.sleepSessions[0].category, "sieste")
        XCTAssertEqual(viewModel.sleepSessions[1].category, "nuit")
        XCTAssertEqual(viewModel.sleepSessions[2].quality,  "mauvaise")
    }

    /// Vérifie que sleepSessions reste vide et qu'un message d'erreur est affiché
    /// si le repository lève une exception
    func test_WhenRepositoryThrows_ErrorMessageIsSetAndListIsEmpty() {
        // GIVEN — le repository simule une erreur de lecture
        let repository = MockSleepRepository(
            sessions: [],
            error: NSError(domain: "CoreData", code: 1,
                           userInfo: [NSLocalizedDescriptionKey: "Impossible de lire la base"])
        )

        // WHEN
        let viewModel = SleepHistoryViewModel(repository: repository)

        // THEN
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.sleepSessions.isEmpty)
    }

    // MARK: - Tests — formattedDuration 

    /// Vérifie que formattedDuration() retourne la bonne chaîne pour des durées variées.
    /// La fonction static est testée directement sans instancier le ViewModel.
    func test_FormattedDuration_ReturnsCorrectString() {
        // Moins d'une heure → format "X min" (h == 0)
        XCTAssertEqual(SleepHistoryViewModel.formattedDuration(45), "45min")
        // Durées rondes en heures
        XCTAssertEqual(SleepHistoryViewModel.formattedDuration(480), "8h")
        XCTAssertEqual(SleepHistoryViewModel.formattedDuration(60),  "1h")

        // Durées avec minutes résiduelles
        XCTAssertEqual(SleepHistoryViewModel.formattedDuration(90),  "1h30")
        XCTAssertEqual(SleepHistoryViewModel.formattedDuration(330), "5h30")
        XCTAssertEqual(SleepHistoryViewModel.formattedDuration(75),  "1h15")
    }

    // MARK: - Tests — qualityIcon (static)

    /// Vérifie que qualityIcon() retourne le bon nom d'icône SF Symbols pour chaque qualité.
    func test_QualityIcon_ReturnsCorrectIconForEachQuality() {
        XCTAssertEqual(SleepHistoryViewModel.qualityIcon(for: "mauvaise"),   "xmark.circle.fill")
        XCTAssertEqual(SleepHistoryViewModel.qualityIcon(for: "moyenne"),    "minus.circle.fill")
        XCTAssertEqual(SleepHistoryViewModel.qualityIcon(for: "bonne"),      "checkmark.circle.fill")
        XCTAssertEqual(SleepHistoryViewModel.qualityIcon(for: "excellente"), "star.circle.fill")
        XCTAssertEqual(SleepHistoryViewModel.qualityIcon(for: nil),          "circle")
    }
    // MARK: - Tests — qualityColor (static)
    /// Vérifie que qualityColor() retourne la bonne couleur pour chaque qualité.
    /// La fonction static est testée directement sans instancier le ViewModel.
    func test_QualityColor_ReturnsCorrectColorForEachQuality() {
        XCTAssertEqual(SleepHistoryViewModel.qualityColor(for: "mauvaise"),   .red)
        XCTAssertEqual(SleepHistoryViewModel.qualityColor(for: "moyenne"),    .orange)
        XCTAssertEqual(SleepHistoryViewModel.qualityColor(for: "bonne"),      .green)
        XCTAssertEqual(SleepHistoryViewModel.qualityColor(for: "excellente"), .yellow)
        XCTAssertEqual(SleepHistoryViewModel.qualityColor(for: nil),          .secondary)

    }
}
