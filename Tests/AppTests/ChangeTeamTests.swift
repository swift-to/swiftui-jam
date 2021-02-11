@testable import App
import XCTVapor
import Fluent

final class ChangeTeamTests: XCTestCase {
    
    static var allTests = [
        ("testChangeTeam_fromOtherTeam", testChangeTeam_fromOtherTeam),
        ("testChangeTeam_fromRandomAssignment", testChangeTeam_fromRandomAssignment)
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
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        try app.autoRevert().wait()
        app.shutdown()
    }
    
    func testChangeTeam_fromOtherTeam() throws {
        // Given
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
        
        _ = try RegisterCaptainEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(
                email: "test2@t.com",
                name: "captain2",
                newTeamName: "team2",
                requiresFloater: false
            )
        )
        .wait()
        
        let teams = try Team.query(on: app.db).all().wait()
        
        guard teams.count == 2, let team1 = teams.first, let team2 = teams.last else {
            throw Abort(.internalServerError)
        }
        
        _ = try RegisterTeamMemberEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(email: "member@m.com", name: "member", existingTeamId: try team1.requireID())
        )
        .wait()
        
        guard let teamMember = try User
            .query(on: app.db)
            .sort(\.$createdAt, .ascending)
                .all().wait().last,
              let teamMemberId = teamMember.id else {
            throw Abort(.internalServerError)
        }
        
        XCTAssertEqual(teamMember.name, "member")
        
        let userTeam = try UserTeam.query(on: app.db)
            .filter(\.$user.$id == teamMemberId)
            .first()
            .unwrap(or: Abort(.notFound))
            .wait()
        
        try XCTAssertEqual(userTeam.$team.id, team1.requireID())
        
        // When
        
        let memberContext = AuthorizedRoutingContext(
            eventLoop: app.eventLoopGroup.next(),
            db: app.db,
            auth: try teamMember.generateAuthPayload(),
            s3: app.s3.manager)
        
        let res = try ChangeTeam.run(
            context: memberContext,
            parameters: (),
            query: (),
            body: .init(teamId: team2.requireID()))
            .wait()
        
        // Expect
        
        let userTeams = try UserTeam.query(on: app.db)
            .filter(\.$user.$id == teamMemberId)
            .all()
            .wait()
        
        XCTAssertEqual(res, .ok)
        XCTAssertEqual(userTeams.count, 1)
        try XCTAssertEqual(userTeams.first?.$team.id, team2.requireID())
        
    }
    
    func testChangeTeam_fromRandomAssignment() throws {
        // Given
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
        
        let team = try Team.query(on: app.db).first().unwrap(or: Abort(.notFound)).wait()
                
        _ = try RegisterAssignedTeamProgrammer.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(email: "assigned@m.com", name: "assigned", notes: "hello world")
        )
        .wait()
        
        guard let assignedProgrammer = try User
            .query(on: app.db)
            .sort(\.$createdAt, .ascending)
            .all().wait().last,
              let assignedProgrammerId = assignedProgrammer.id else {
            throw Abort(.internalServerError)
        }
        
        XCTAssertEqual(assignedProgrammer.name, "assigned")
        XCTAssertEqual(assignedProgrammer.requiresRandomAssignment, true)
        
        // When
        
        let authContext = AuthorizedRoutingContext(
            eventLoop: app.eventLoopGroup.next(),
            db: app.db,
            auth: try assignedProgrammer.generateAuthPayload(),
            s3: app.s3.manager)
        
        let res = try ChangeTeam.run(
            context: authContext,
            parameters: (),
            query: (),
            body: .init(teamId: team.requireID()))
            .wait()
        
        // Expect
        
        let userTeams = try UserTeam.query(on: app.db)
            .with(\.$user)
            .filter(\.$user.$id == assignedProgrammerId)
            .all()
            .wait()
        
        XCTAssertEqual(res, .ok)
        XCTAssertEqual(userTeams.count, 1)
        XCTAssertEqual(userTeams.first?.$team.id, try team.requireID())
        XCTAssertEqual(userTeams.first?.user.requiresRandomAssignment, false)
    }
    
}
