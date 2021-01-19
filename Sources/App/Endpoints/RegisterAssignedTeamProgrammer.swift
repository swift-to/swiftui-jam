import Fluent
import Vapor
//import JWT
import FluentPostgresDriver
import APIRouting

struct RegisterAssignedTeamProgrammerRequestBody: Decodable {
    var email: String
    var name: String
    var notes: String?
}

struct RegisterAssignedTeamProgrammer: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .post
    static var path: String = "/register-assigned-programmer"
    
    static func run(
        context: UnauthorizedRoutingContext,
        parameters: Void,
        query: Void,
        body: RegisterAssignedTeamProgrammerRequestBody
    ) throws -> EventLoopFuture<HTTPStatus> {
        
        return try User.create(
            name: body.name,
            email: body.email,
            isFloater: false,
            requiresRandomAssignment: true,
            notes: body.notes,
            on: context.db
        )
        .map { _ in .ok }
    }
}
