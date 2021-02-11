@testable import App
import XCTVapor

final class MeTests: XCTestCase {
    
    static var allTests = [
        ("testMeEndpointTeamMembership", testMeEndpointTeamMembership),
        ("testMeEndpointFloatingDesigner", testMeEndpointFloatingDesigner),
        ("testMeEndpointAssignedProgrammer", testMeEndpointAssignedProgrammer)
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
    
    func testMeEndpointTeamMembership() throws {
        // Given
        _ = try RegisterCaptainEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(
                email: "test@t.com",
                name: "captain",
                newTeamName: "test team",
                requiresFloater: false
            )
        )
        .wait()
        
        let team = try Team.query(on: app.db).first().unwrap(or: Abort(.badRequest)).wait()
        
        _ = try RegisterTeamMemberEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(email: "member@m.com", name: "member", existingTeamId: try team.requireID())
        )
        .wait()
        
        let users = try User.query(on: app.db).all().wait()
        guard users.count == 2,
              let captain = users.first,
              let teamMember = users.last else {
            throw Abort(.internalServerError)
        }
        
        // When
        let captainAuth = AuthorizedRoutingContext(
            eventLoop: app.eventLoopGroup.next(),
            db: app.db,
            auth: try captain.generateAuthPayload(),
            s3: app.s3.manager)
        
        let captainRes = try GetMeEndpoint.run(
            context: captainAuth,
            parameters: (),
            query: (),
            body: ()
        ).wait()
        
        let memberAuth = AuthorizedRoutingContext(
            eventLoop: app.eventLoopGroup.next(),
            db: app.db,
            auth: try teamMember.generateAuthPayload(),
            s3: app.s3.manager)
        
        let memberRes = try GetMeEndpoint.run(
            context: memberAuth,
            parameters: (),
            query: (),
            body: ()
        ).wait()
        
        // Expect
        XCTAssertEqual(
            captainRes,
            UserDetailsViewModel(
                id: try captain.requireID(),
                name: "captain",
                type: .teamCaptain,
                team: .init(
                    id: try team.requireID(),
                    name: "test team",
                    captain: .init(
                        id: try captain.requireID(),
                        name: "captain"
                    ),
                    members: [
                        .init(
                            id: try captain.requireID(),
                            name: "captain"
                        ),
                        .init(
                            id: try teamMember.requireID(),
                            name: "member"
                        ),
                    ]
                ),
                address: nil
            )
        )
        
        XCTAssertEqual(
            memberRes,
            UserDetailsViewModel(
                id: try teamMember.requireID(),
                name: "member",
                type: .teamMember,
                team: .init(
                    id: try team.requireID(),
                    name: "test team",
                    captain: .init(
                        id: try captain.requireID(),
                        name: "captain"
                    ),
                    members: [
                        .init(
                            id: try captain.requireID(),
                            name: "captain"
                        ),
                        .init(
                            id: try teamMember.requireID(),
                            name: "member"
                        )
                    ]
                ),
                address: nil
            )
        )
    }
    
    func testMeEndpointFloatingDesigner() throws {
        // Given
        _ = try RegisterFloaterEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(
                email: "test@t.com",
                name: "design"
            )
        )
        .wait()
        
        let user = try User.query(on: app.db).first().unwrap(or: Abort(.notFound)).wait()
        let auth = AuthorizedRoutingContext(
            eventLoop: app.eventLoopGroup.next(),
            db: app.db,
            auth: try user.generateAuthPayload(),
            s3: app.s3.manager)
        
        // When
        let res = try GetMeEndpoint.run(
            context: auth,
            parameters: (),
            query: (),
            body: ()
        ).wait()
        
        // Expect
        XCTAssertEqual(
            res,
            UserDetailsViewModel(
                id: try user.requireID(),
                name: "design",
                type: .floatingDesigner,
                team: nil,
                address: nil
            )
        )
        
    }
    
    func testMeEndpointAssignedProgrammer() throws {
        // Given
        _ = try RegisterAssignedTeamProgrammer.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(
                email: "test@t.com",
                name: "assignme"
            )
        )
        .wait()
        
        let user = try User.query(on: app.db).first().unwrap(or: Abort(.notFound)).wait()
        let auth = AuthorizedRoutingContext(
            eventLoop: app.eventLoopGroup.next(),
            db: app.db,
            auth: try user.generateAuthPayload(),
            s3: app.s3.manager)
        
        // When
        let res = try GetMeEndpoint.run(
            context: auth,
            parameters: (),
            query: (),
            body: ()
        ).wait()
        
        // Expect
        XCTAssertEqual(
            res,
            UserDetailsViewModel(
                id: try user.requireID(),
                name: "assignme",
                type: .randomAssignedProgrammer,
                team: nil,
                address: nil
            )
        )
    }
    
}
