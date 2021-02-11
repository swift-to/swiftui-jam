import Fluent
import Vapor
import JWT
import APIRouting

struct UpdateTeamParams: Decodable {
    var id: String
}

struct UpdateTeamBody: Decodable {
    var name: String
    var requiresFloater: Bool
}

struct UpdateTeamEndpoint: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .patch
    static var path: String = "/teams/:id"
    
    static func run(
        context: AuthorizedRoutingContext,
        parameters: UpdateTeamParams,
        query: Void,
        body: UpdateTeamBody
    ) throws -> EventLoopFuture<HTTPStatus> {
        context.db.transaction { db in
            UserTeam.query(on: db)
                .filter(\.$user.$id == context.auth.id)
                .with(\.$team)
                .first()
                .unwrap(or: Abort(.notFound))
                .flatMapThrowing { userTeam -> Team in
                    guard userTeam.team.$captain.id == context.auth.id else {
                        throw Abort(.badRequest, reason: "You must be the captain to update the team info")
                    }
                    return userTeam.team
                }
                .flatMap { team in
                    team.name = body.name
                    team.requiresFloater = body.requiresFloater
                    return team.save(on: db)
                }
        }
        .map { .ok }
    }
}
