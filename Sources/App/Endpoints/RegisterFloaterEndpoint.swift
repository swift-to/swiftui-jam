import Fluent
import Vapor
//import JWT
import FluentPostgresDriver
import APIRouting

struct RegisterFloaterRequestBody: Decodable {
    var email: String
    var name: String
}

struct RegisterFloaterEndpoint: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .post
    static var path: String = "/register-floater"
    
    static func run(
        context: UnauthorizedRoutingContext,
        parameters: Void,
        query: Void,
        body: RegisterFloaterRequestBody
    ) throws -> EventLoopFuture<HTTPStatus> {
        
        return try User.create(
            name: body.name,
            email: body.email,
            isFloater: true,
            on: context.db
        )
        .map { _ in .ok }
    }
}
