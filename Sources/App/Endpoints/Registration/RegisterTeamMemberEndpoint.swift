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
        
        return context.db.transaction { db in
            return Team.query(on: db)
                .with(\.$members)
                .filter(\.$id == body.existingTeamId)
                .first()
                .unwrap(or: Abort(.notFound, reason: "Team not found"))
                .flatMap { team -> EventLoopFuture<Void> in
                    do {
                        return try User.create(
                            name: body.name,
                            email: body.email,
                            isFloater: false,
                            requiresRandomAssignment: false,
                            notes: nil,
                            on: db
                        )
                        .flatMap { user in
                            return Team.addMember(user: user, toTeam: body.existingTeamId, on: db)
                        }
                    }
                    catch {
                        return context.eventLoop.makeFailedFuture(error)
                    }
                }
                .map { .ok }
        }
        
        
    }
}
