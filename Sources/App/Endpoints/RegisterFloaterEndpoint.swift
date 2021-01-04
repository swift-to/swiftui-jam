import Fluent
import Vapor
//import JWT
import FluentPostgresDriver
import APIRouting
import Regex

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
        
        if "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}".r?.matches(body.email) == false {
            throw Abort(.badRequest, reason: "Invalid Email")
        }
        
        let newUser = User()
        newUser.name = body.name
        newUser.email = body.email
        newUser.isFloater = true
        return newUser.create(on: context.db)
            .map { _ in .ok }
    }
}
