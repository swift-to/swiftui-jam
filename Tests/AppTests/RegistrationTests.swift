@testable import App
import XCTVapor
import Fluent

final class RegistrationTests: XCTestCase {

    static var allTests = [
        ("testRegisterCaptainEndpoint", testRegisterCaptainEndpoint),
        ("testRegisterAssignedTeamProgrammer", testRegisterAssignedTeamProgrammer),
        ("testRegisterFloaterEndpoint", testRegisterFloaterEndpoint),
        ("testRegisterTeamMemberEndpoint", testRegisterTeamMemberEndpoint)
    ]
    
    var app: Application!
    var context: UnauthorizedRoutingContext!

    override func setUpWithError() throws {
        try super.setUpWithError()

        app = Application(.testing)
        try configure(app)
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
    
    func testRegisterCaptainEndpoint() throws {
        let res = try RegisterCaptainEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(
                email: "test@t.com",
                name: "test",
                newTeamName: "test team",
                requiresFloater: true
            )
        )
        .wait()
        
        let user = try User.query(on: app.db)
            .filter(\.$email == "test@t.com")
            .first().unwrap(or: Abort(.badRequest)).wait()
        let team = try Team.query(on: app.db)
            .filter(\.$name == "test team")
            .first().unwrap(or: Abort(.badRequest)).wait()
        let userTeam = try UserTeam.query(on: app.db)
            .filter(\.$team.$id == team.requireID())
            .first().unwrap(or: Abort(.badRequest)).wait()
        
        XCTAssertEqual(res, .ok)
        
        XCTAssertEqual(user.name, "test")
        XCTAssertEqual(user.email, "test@t.com")
        XCTAssertEqual(user.requiresRandomAssignment, false)
        XCTAssertEqual(user.isFloater, false)
        
        XCTAssertEqual(team.name, "test team")
        XCTAssertEqual(team.requiresFloater, true)
        XCTAssertEqual(team.$captain.id, try user.requireID())
        
        XCTAssertEqual(userTeam.$team.id, try team.requireID())
        XCTAssertEqual(userTeam.$user.id, try user.requireID())
    }
    
    func testRegisterAssignedTeamProgrammer() throws {
        let res = try RegisterAssignedTeamProgrammerEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(
                email: "test@t.com",
                name: "test",
                notes: "hello world"
            )
        )
        .wait()
        
        // Expect
        let user = try User.query(on: app.db)
            .filter(\.$email == "test@t.com")
            .first().unwrap(or: Abort(.badRequest)).wait()
        let teams = try Team.query(on: app.db).all().wait()
        let userTeams = try UserTeam.query(on: app.db).all().wait()
        
        XCTAssertEqual(res, .ok)
        XCTAssertEqual(user.name, "test")
        XCTAssertEqual(user.email, "test@t.com")
        XCTAssertEqual(user.notes, "hello world")
        XCTAssertEqual(user.requiresRandomAssignment, true)
        XCTAssertEqual(user.isFloater, false)
        
        XCTAssertEqual(teams.count, 0)
        XCTAssertEqual(userTeams.count, 0)
        
    }
    
    func testRegisterFloaterEndpoint() throws {
        let res = try RegisterFloaterEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(
                email: "test@t.com",
                name: "test"
            )
        )
        .wait()
        
        // Expect
        let user = try User.query(on: app.db)
            .filter(\.$email == "test@t.com")
            .first().unwrap(or: Abort(.badRequest)).wait()
        let teams = try Team.query(on: app.db).all().wait()
        let userTeams = try UserTeam.query(on: app.db).all().wait()
        
        XCTAssertEqual(res, .ok)
        XCTAssertEqual(user.name, "test")
        XCTAssertEqual(user.email, "test@t.com")
        XCTAssertEqual(user.notes, nil)
        XCTAssertEqual(user.requiresRandomAssignment, false)
        XCTAssertEqual(user.isFloater, true)
        
        XCTAssertEqual(teams.count, 0)
        XCTAssertEqual(userTeams.count, 0)
    }
    
    func testRegisterTeamMemberEndpoint() throws {
        // Given
        _ = try RegisterCaptainEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(
                email: "test@t.com",
                name: "test",
                newTeamName: "test team",
                requiresFloater: false
            )
        )
        .wait()
        
        let team = try Team.query(on: app.db)
            .filter(\.$name == "test team")
            .first().unwrap(or: Abort(.badRequest)).wait()
        
        // When
        
        let res = try RegisterTeamMemberEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(email: "member@m.com", name: "member", existingTeamId: try team.requireID())
        )
        .wait()
        
        // Expect
        let users = try User.query(on: app.db).all().wait()
        let teams = try Team.query(on: app.db).all().wait()
        let userTeams = try UserTeam.query(on: app.db).all().wait()
        
        XCTAssertEqual(res, .ok)
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(teams.count, 1)
        XCTAssertEqual(userTeams.count, 2)
        XCTAssertEqual(userTeams.first?.$team.id, try team.requireID())
        XCTAssertEqual(userTeams.last?.$team.id, try team.requireID())
    }
    
}
