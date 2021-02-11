@testable import App
import XCTVapor

final class AppTests: XCTestCase {

    static var allTests = [
        ("testStatusEndpoint", testStatusEndpoint),
        ("testGetTeamsEndpoint", testGetTeamsEndpoint)
    ]
    
    var app: Application = {
        let app = Application(.testing)
        try! configure(app)
        return app
    }()

    override func setUpWithError() throws {
        try super.setUpWithError()
        try app.autoMigrate().wait()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        try app.autoRevert().wait()
        app.shutdown()
    }

    func testStatusEndpoint() throws {
        let context = UnauthorizedRoutingContext(
            eventLoop: app.eventLoopGroup.next(),
            db: app.db
        )
        
        let res = try StatusEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: ()
        ).wait()
    
        XCTAssertEqual(res, StatusEndpoint.OKResponse(status: "ok"))
    }
    
    func testGetTeamsEndpoint() throws {
        let context = UnauthorizedRoutingContext(
            eventLoop: app.eventLoopGroup.next(),
            db: app.db
        )
        
        let user = try User.createFixture(name: "tester", database: app.db)
        let team = Team()
        team.name = "Test Team"
        team.requiresFloater = false
        team.$captain.id = try user.requireID()
        try team.save(on: app.db).wait()
        try team.$members.attach([user], on: app.db).wait()
        
        let res = try GetTeamsEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: ()
        ).wait()
        
        XCTAssertEqual(res, [
            TeamViewModel(
                id: try team.requireID(),
                name: team.name
            )
        ])
    }
    
}
