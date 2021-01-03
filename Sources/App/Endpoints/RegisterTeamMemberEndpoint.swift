import Fluent
import Vapor
//import JWT
import FluentPostgresDriver
import APIRouting
import Regex

struct RegisterTeamMemberRequestBody: Decodable {
    var email: String
    var name: String
    var existingTeamId: UUID
}

struct RegisterTeamMemberEndpoint: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .post
    static var path: String = "/register-team-member"
    
    static func run(
        context: UnauthorizedRoutingContext,
        parameters: Void,
        query: Void,
        body: RegisterTeamMemberRequestBody
    ) throws -> EventLoopFuture<HTTPStatus> {
        
        if "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}".r?.matches(body.email) == false {
            throw Abort(.badRequest, reason: "Invalid Email")
        }
        
        return Team.query(on: context.db)
            .with(\.$members)
            .filter(\.$id == body.existingTeamId)
            .first()
            .unwrap(or: Abort(.notFound, reason: "Team not found"))
            .flatMap { team -> EventLoopFuture<Void> in
                guard team.members.count < 3 else {
                    return context.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Team already has maximum number of members"))
                }

                let newUser = User()
                newUser.name = body.name
                newUser.email = body.email
                return newUser.create(on: context.db)
                    .flatMap { _ in
                        team.$members.attach(newUser, on: context.db)
                    }
            }
            .map { _ in .ok }
    }
}
