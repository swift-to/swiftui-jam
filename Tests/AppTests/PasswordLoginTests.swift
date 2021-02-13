//@testable import App
//import XCTVapor
//import Fluent
//
//final class PasswordLoginTests: XCTestCase {
//
//    static var allTests = [
//        ("testPasswordLogin_whenNoPasswordIsSet", testPasswordLogin_whenNoPasswordIsSet),
//        ("testPasswordLogin_whenPasswordIsSet", testPasswordLogin_whenPasswordIsSet)
//    ]
//
//    var app: Application = {
//        let app = Application(.testing)
//        try! configure(app)
//        return app
//    }()
//    var context: UnauthorizedRoutingContext!
//
//    override func setUpWithError() throws {
//        try super.setUpWithError()
//        try app.autoMigrate().wait()
//
//        context = UnauthorizedRoutingContext(
//            eventLoop: app.eventLoopGroup.next(),
//            db: app.db
//        )
//
//        _ = try RegisterFloaterEndpoint.run(
//            context: context,
//            parameters: (),
//            query: (),
//            body: .init(
//                email: "float@t.com",
//                name: "floater"
//            )
//        )
//        .wait()
//    }
//
//    override func tearDownWithError() throws {
//        try super.tearDownWithError()
//        try app.autoRevert().wait()
//        app.shutdown()
//    }
//
//    func testPasswordLogin_whenNoPasswordIsSet() throws {
//        // Given
//        let eventLoop = app.eventLoopGroup.next()
//        let sesManager = MockSESManager(eventLoop: eventLoop)
//        let context = AccessManagementContext(
//            eventLoop: eventLoop,
//            db: app.db,
//            jwt: MockJWT(signingResult: "abc123"),
//            ses: sesManager
//        )
//
//        // When/ Expect
//        XCTAssertThrowsError(try PasswordLoginEndpoint.run(
//            context: context,
//            parameters: (),
//            query: (),
//            body: .init(email: "float@t.com", password: "mypassword")
//        )
//        .wait()) { error in
//            XCTAssertEqual((error as? Abort)?.status, .unauthorized)
//        }
//    }
//
//    func testPasswordLogin_whenPasswordIsSet() throws {
//        // Given
//        let updatingUser = try User.query(on: app.db)
//            .filter(\.$email == "float@t.com")
//            .first().unwrap(or: Abort(.notFound))
//            .wait()
//
//        let context = AuthorizedRoutingContext(
//            eventLoop: app.eventLoopGroup.next(),
//            db: app.db,
//            auth: try updatingUser.generateAuthPayload(),
//            s3: app.s3.manager)
//
//        _ = try UpdatePasswordEndpoint.run(context: context, parameters: (), query: (), body: .init(password: "mypassword"))
//            .wait()
//
//        // When
//        let eventLoop = app.eventLoopGroup.next()
//        let sesManager = MockSESManager(eventLoop: eventLoop)
//        let accessContext = AccessManagementContext(
//            eventLoop: eventLoop,
//            db: app.db,
//            jwt: MockJWT(signingResult: "abc123"),
//            ses: sesManager
//        )
//
//        // When/ Expect
//        let res = try PasswordLoginEndpoint.run(
//            context: accessContext,
//            parameters: (),
//            query: (),
//            body: .init(email: "float@t.com", password: "mypassword")
//        )
//        .wait()
//
//        XCTAssertEqual(res, .init(token: "abc123"))
//
//    }
//
//}
