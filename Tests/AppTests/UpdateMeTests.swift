@testable import App
import XCTVapor
import Fluent

final class UpdateMeTests: XCTestCase {
    
    static var allTests = [
        ("testUpdateMe_addAddress", testUpdateMe_addAddress),
        ("testUpdateMe_updateAddress", testUpdateMe_updateAddress)
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
    
    func testUpdateMe_addAddress() throws {
        // Given
        let user = try User.query(on: app.db).first().unwrap(or: Abort(.notFound)).wait()

        // When
        let context = AuthorizedRoutingContext(
            eventLoop: app.eventLoopGroup.next(),
            db: app.db,
            auth: try user.generateAuthPayload(),
            s3: app.s3.manager)
        
        let updateRes = try UpdateMeEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(
                name: "Joe Biden",
                address: .init(
                    street: "s1",
                    street2: "s2",
                    city: "to",
                    postalCode: "123456",
                    country: "CA"
                )
            )
        )
        .wait()
        
        XCTAssertEqual(updateRes, .ok)
        
        // Expect
        let userRes = try GetMeEndpoint.run(context: context, parameters: (), query: (), body: ()).wait()
        XCTAssertEqual(
            userRes,
            .init(
                id: try user.requireID(),
                name: "Joe Biden",
                type: .floatingDesigner,
                team: nil,
                address: .init(
                    street: "s1",
                    street2: "s2",
                    city: "to",
                    postalCode: "123456",
                    country: "CA"
                )
            )
        )
    }
    
    func testUpdateMe_updateAddress() throws {
        // Given
        let user = try User.query(on: app.db).first().unwrap(or: Abort(.notFound)).wait()

        // When
        let context = AuthorizedRoutingContext(
            eventLoop: app.eventLoopGroup.next(),
            db: app.db,
            auth: try user.generateAuthPayload(),
            s3: app.s3.manager)
        
        let addRes = try UpdateMeEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(
                name: "Joe Biden",
                address: .init(
                    street: "s1",
                    street2: "s2",
                    city: "to",
                    postalCode: "123456",
                    country: "CA"
                )
            )
        )
        .wait()
        
        XCTAssertEqual(addRes, .ok)
        
        let updateRes = try UpdateMeEndpoint.run(
            context: context,
            parameters: (),
            query: (),
            body: .init(
                name: "Barrack Obama",
                address: .init(
                    street: "s3",
                    street2: "s4",
                    city: "wa",
                    postalCode: "asd",
                    country: "US"
                )
            )
        )
        .wait()
        
        XCTAssertEqual(updateRes, .ok)
        
        // Expect
        let userRes = try GetMeEndpoint.run(context: context, parameters: (), query: (), body: ()).wait()
        XCTAssertEqual(
            userRes,
            .init(
                id: try user.requireID(),
                name: "Barrack Obama",
                type: .floatingDesigner,
                team: nil,
                address: .init(
                    street: "s3",
                    street2: "s4",
                    city: "wa",
                    postalCode: "asd",
                    country: "US"
                )
            )
        )
        
        let addresses = try Address.query(on: app.db).all().wait()
        XCTAssertEqual(addresses.count, 1)
    }
    
}
