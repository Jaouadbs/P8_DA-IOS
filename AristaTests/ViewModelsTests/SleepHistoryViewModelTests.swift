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
        XCTAssertTrue(viewModel.sleepSessions.isEmpty, "La liste doit être vide si le repository est vide")
        XCTAssertNil(viewModel.errorMessage,           "Aucune erreur ne doit être affichée pour une liste vide")
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
        XCTAssertEqual(viewModel.sleepSessions.count, 1,       "La liste doit contenir 1 session")
        XCTAssertEqual(viewModel.sleepSessions[0].category,  "nuit",  "La catégorie doit être 'nuit'")
        XCTAssertEqual(viewModel.sleepSessions[0].duration,  480,     "La durée doit être 480 minutes")
        XCTAssertEqual(viewModel.sleepSessions[0].quality,   "bonne", "La qualité doit être 'bonne'")
        XCTAssertEqual(viewModel.sleepSessions[0].startDate, date,    "La date doit être correctement transmise")
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
        XCTAssertEqual(viewModel.sleepSessions.count, 3,          "La liste doit contenir 3 sessions")
        XCTAssertEqual(viewModel.sleepSessions[0].category, "sieste",    "La sieste (la + récente) doit être en premier")
        XCTAssertEqual(viewModel.sleepSessions[1].category, "nuit",      "La nuit d'hier doit être en second")
        XCTAssertEqual(viewModel.sleepSessions[2].quality,  "mauvaise",  "La nuit la plus ancienne doit être en dernier")
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
        XCTAssertNotNil(viewModel.errorMessage,        "Un message d'erreur doit être affiché")
        XCTAssertTrue(viewModel.sleepSessions.isEmpty, "La liste doit rester vide en cas d'erreur")
    }

    // MARK: - Tests — formattedDuration 

    /// Vérifie que formattedDuration() retourne la bonne chaîne pour des durées variées.
    /// La fonction static est testée directement sans instancier le ViewModel.
    func test_FormattedDuration_ReturnsCorrectString() {
        // Durées rondes en heures
        XCTAssertEqual(SleepHistoryViewModel.formattedDuration(480), "8 h",    "480 min = 8 h exactement")
        XCTAssertEqual(SleepHistoryViewModel.formattedDuration(60),  "1 h",    "60 min = 1 h exactement")

        // Durées avec minutes résiduelles
        XCTAssertEqual(SleepHistoryViewModel.formattedDuration(90),  "1h30",  "90 min = 1h30")
        XCTAssertEqual(SleepHistoryViewModel.formattedDuration(330), "5h30",  "330 min = 5h30")
        XCTAssertEqual(SleepHistoryViewModel.formattedDuration(75),  "1h15",  "75 min = 1h15")
    }

    // MARK: - Tests — qualityIcon (static)

    /// Vérifie que qualityIcon() retourne le bon nom d'icône SF Symbols pour chaque qualité.
    func test_QualityIcon_ReturnsCorrectIconForEachQuality() {
        XCTAssertEqual(SleepHistoryViewModel.qualityIcon(for: "mauvaise"),   "xmark.circle.fill",
                       "mauvaise → icône d'erreur")
        XCTAssertEqual(SleepHistoryViewModel.qualityIcon(for: "moyenne"),    "minus.circle.fill",
                       "moyenne → icône neutre")
        XCTAssertEqual(SleepHistoryViewModel.qualityIcon(for: "bonne"),      "checkmark.circle.fill",
                       "bonne → icône de succès")
        XCTAssertEqual(SleepHistoryViewModel.qualityIcon(for: "excellente"), "star.circle.fill",
                       "excellente → icône étoile")
        XCTAssertEqual(SleepHistoryViewModel.qualityIcon(for: nil),          "circle",
                       "nil → icône par défaut")
    }
}
