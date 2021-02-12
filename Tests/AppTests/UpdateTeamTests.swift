@testable import App
import XCTVapor
import Fluent

final class UpdateTeamTests: XCTestCase {
    
    static var allTests = [
        ("testUpdateTeam", testUpdateTeam)
    ]
    
    var app: Application = {
        let app = Application(.testing)
        try! configure(app)
        return app
    }()
    var context: UnauthorizedRoutingContext!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        try app.autoMigrate().wait()
        
        context = UnauthorizedRoutingContext(
            eventLoop: app.eventLoopGroup.next(),
            db: app.db
        )
        
        _ = try RegisterCaptainEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(
                email: "test@t.com",
                name: "captain1",
                newTeamName: "team1",
                requiresFloater: false
            )
        )
        .wait()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        try app.autoRevert().wait()
        app.shutdown()
    }
    
    func testUpdateTeam() throws {
        // Given
        let team = try Team.query(on: app.db).first().unwrap(or: Abort(.notFound)).wait()
        let user = try User.query(on: app.db).first().unwrap(or: Abort(.notFound)).wait()
        
        XCTAssertEqual(team.name, "team1")
        XCTAssertEqual(team.requiresFloater, false)
        
        // When
        let context = AuthorizedRoutingContext(
            eventLoop: app.eventLoopGroup.next(),
            db: app.db,
            auth: try user.generateAuthPayload(),
            s3: app.s3.manager)
        
        let res = try UpdateTeamEndpoint.run(
            context: context,
            parameters: .init(id: try team.requireID().uuidString),
            query: (),
            body: .init(
                name: "Electric Boogaloo"
            )
        )
        .wait()
        
        // Expect
        let updatedTeam = try Team.query(on: app.db).first().unwrap(or: Abort(.notFound)).wait()
        XCTAssertEqual(res, .ok)
        XCTAssertEqual(updatedTeam.name, "Electric Boogaloo")
    }
    
    func testUpdateTeam_fromNonCaptain() throws {
        // Given

        let team = try Team.query(on: app.db).first().unwrap(or: Abort(.notFound)).wait()

        _ = try RegisterTeamMemberEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(
                email: "membr@t.com",
                name: "member",
                existingTeamId: team.requireID()
            )
        )
        .wait()
        
        let user = try User.query(on: app.db)
            .filter(\.$name == "member")
            .first().unwrap(or: Abort(.notFound)).wait()
                
        // When
        let context = AuthorizedRoutingContext(
            eventLoop: app.eventLoopGroup.next(),
            db: app.db,
            auth: try user.generateAuthPayload(),
            s3: app.s3.manager)
        
        // Expect
        XCTAssertThrowsError(try UpdateTeamEndpoint.run(
            context: context,
            parameters: .init(id: try team.requireID().uuidString),
            query: (),
            body: .init(
                name: "Electric Boogaloo"
            )
        ).wait()) { err in
            XCTAssertEqual((err as? Abort)?.status, .badRequest)
        }
        
        let updatedTeam = try Team.query(on: app.db).first().unwrap(or: Abort(.notFound)).wait()
        XCTAssertEqual(updatedTeam.name, "team1")
        XCTAssertEqual(updatedTeam.requiresFloater, false)
    }
    
}
