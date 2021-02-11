import Foundation

@testable import App
import XCTVapor
import Fluent

final class UpdatePasswordTests: XCTestCase {
    
    static var allTests = [
        ("testUpdatePassword", testUpdatePassword)
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
        
        _ = try RegisterFloaterEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(
                email: "otherperson@t.com",
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
    
    func testUpdatePassword() throws {
        // Given
        let updatingUser = try User.query(on: app.db)
            .filter(\.$email == "float@t.com")
            .first().unwrap(or: Abort(.notFound)).wait()

        // When
        let context = AuthorizedRoutingContext(
            eventLoop: app.eventLoopGroup.next(),
            db: app.db,
            auth: try updatingUser.generateAuthPayload(),
            s3: app.s3.manager)
        
        let res = try UpdatePasswordEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(password: "yomama")
        ).wait()

        // Expect
        let updatedUser =  try User.query(on: app.db)
            .filter(\.$email == "float@t.com")
            .first().unwrap(or: Abort(.notFound)).wait()
        let otherUser = try User.query(on: app.db)
            .filter(\.$email == "otherperson@t.com")
            .first().unwrap(or: Abort(.notFound)).wait()
        
        XCTAssertEqual(res, .ok)
        XCTAssertEqual(updatedUser.password, "yomama")
        XCTAssertEqual(otherUser.password, nil)
    }
    
}
