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
                do {
                    guard team.members.count <= 5 else {
                        throw Abort(.badRequest, reason: "Team already has maximum number of members")
                    }
                    return try User.create(
                        name: body.name,
                        email: body.email,
                        isFloater: false,
                        requiresRandomAssignment: false,
                        notes: nil,
                        on: context.db
                    )
                    .flatMap { newUser in
                        team.$members.attach(newUser, on: context.db)
                    }
                }
                catch {
                    return context.eventLoop.makeFailedFuture(error)
                }
            }
            .map { _ in .ok }
    }
}
