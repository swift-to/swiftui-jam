@testable import App
import XCTVapor
import Fluent

final class EmailLoginTests: XCTestCase {
    
    static var allTests = [
        ("testEmailLogin", testEmailLogin),
        ("testEmailLogin_whenEmailDoesNotExist", testEmailLogin_whenEmailDoesNotExist)
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
        
        _ = try RegisterFloaterEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(
                email: "float@t.com",
                name: "floater"
            )
        )
        .wait()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        try app.autoRevert().wait()
        app.shutdown()
    }
    
    func testEmailLogin() throws {
        // Given
        let eventLoop = app.eventLoopGroup.next()
        let sesManager = MockSESManager(eventLoop: eventLoop)
        let context = AccessManagementContext(
            eventLoop: eventLoop,
            db: app.db,
            jwt: MockJWT(signingResult: "abc123"),
            ses: sesManager
        )

        // When
        let updateRes = try EmailLoginEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(email: "float@t.com")
        )
        .wait()
        
        // Expect
        XCTAssertEqual(updateRes, .ok)
        XCTAssertEqual(sesManager.lastEmail?.to, "float@t.com")
        XCTAssertEqual(sesManager.lastEmail?.subject, "SwiftUI Jam login access")
        XCTAssertEqual(sesManager.lastEmail?.message.contains("https://www.swiftuijam.com/?accessToken=abc123"), true)
    }
    
    func testEmailLogin_whenEmailDoesNotExist() throws {
        // Given
        let eventLoop = app.eventLoopGroup.next()
        let sesManager = MockSESManager(eventLoop: eventLoop)
        let context = AccessManagementContext(
            eventLoop: eventLoop,
            db: app.db,
            jwt: MockJWT(signingResult: "abc123"),
            ses: sesManager
        )

        // When
        let updateRes = try EmailLoginEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(email: "doesnotexist@t.com")
        )
        .wait()
        
        // Expect
        XCTAssertEqual(updateRes, .ok)
        XCTAssertEqual(sesManager.lastEmail, nil)
        
    }
   
}
