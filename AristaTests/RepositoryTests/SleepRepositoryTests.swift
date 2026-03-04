//
//  SleepRepositoryTests.swift
//  AristaTests
//
//  Created by Jaouad on 03/03/2026.
//

import XCTest
import CoreData
@testable import Arista

final class SleepRepositoryTests: XCTestCase {

    func test_WhenNoSessionIsInDatabase_GetSleepSessions_ReturnsEmptyList() {
        let persistence = PersistenceController(inMemory: true)
        emptySessions(context: persistence.container.viewContext)

        let repo     = SleepRepository(viewContext: persistence.container.viewContext)
        let sessions = try! repo.getSleepSessions()

        XCTAssertTrue(sessions.isEmpty)
    }

    func test_WhenAddingOneSession_GetSleepSessions_ReturnsListWithThatSession() {
        let persistence = PersistenceController(inMemory: true)
        emptySessions(context: persistence.container.viewContext)

        let date = Date()
        let user = makeUser(context: persistence.container.viewContext)
        addSession(context: persistence.container.viewContext,
                   startDate: date, duration: 450,
                   quality: "bonne", category: "nuit", user: user)

        let repo     = SleepRepository(viewContext: persistence.container.viewContext)
        let sessions = try! repo.getSleepSessions()

        XCTAssertFalse(sessions.isEmpty)
        XCTAssertEqual(sessions.first?.duration,  450)
        XCTAssertEqual(sessions.first?.quality,   "bonne")
        XCTAssertEqual(sessions.first?.category,  "nuit")
        XCTAssertEqual(sessions.first?.startDate, date)
    }

    func test_WhenAddingMultipleSessions_GetSleepSessions_ReturnsListFromMostRecentToOldest() {
        let persistence = PersistenceController(inMemory: true)
        emptySessions(context: persistence.container.viewContext)

        let user  = makeUser(context: persistence.container.viewContext)
        let date1 = Date()
        let date2 = Date(timeIntervalSinceNow: -(60 * 60 * 24))
        let date3 = Date(timeIntervalSinceNow: -(60 * 60 * 24 * 2))

        addSession(context: persistence.container.viewContext,
                   startDate: date3, duration: 480, quality: "excellente", category: "nuit", user: user)
        addSession(context: persistence.container.viewContext,
                   startDate: date1, duration: 360, quality: "moyenne", category: "nuit", user: user)
        addSession(context: persistence.container.viewContext,
                   startDate: date2, duration: 90, quality: "bonne", category: "sieste", user: user)

        let repo     = SleepRepository(viewContext: persistence.container.viewContext)
        let sessions = try! repo.getSleepSessions()

        XCTAssertEqual(sessions.count, 3)
        XCTAssertEqual(sessions[0].startDate, date1)
        XCTAssertEqual(sessions[1].startDate, date2)
        XCTAssertEqual(sessions[2].startDate, date3)
    }

    // MARK: - Helpers

    private func emptySessions(context: NSManagedObjectContext) {
        let request = Sleep.fetchRequest()
        let objects = try! context.fetch(request)
        objects.forEach { context.delete($0) }
        try! context.save()
    }

    @discardableResult
    private func makeUser(context: NSManagedObjectContext) -> User {
        let user       = User(context: context)
        user.id        = UUID()
        user.firstName = "Charlotte"
        user.lastName  = "Razoul"
        try! context.save()
        return user
    }

    private func addSession(context: NSManagedObjectContext, startDate: Date,
                            duration: Int64, quality: String, category: String, user: User) {
        let session       = Sleep(context: context)
        session.id        = UUID()
        session.startDate = startDate
        session.endDate   = startDate.addingTimeInterval(TimeInterval(duration * 60))
        session.duration  = duration
        session.quality   = quality
        session.category  = category
        session.user      = user
        try! context.save()
    }
}
