import Fluent
import Vapor
import JWT
import APIRouting

struct ChangeTeamBody: Decodable {
    var teamId: UUID
}

struct ChangeTeamEndpoint: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .post
    static var path: String = "/me/team"
    
    static func run(
        context: AuthorizedRoutingContext,
        parameters: Void,
        query: Void,
        body: ChangeTeamBody
    ) throws -> EventLoopFuture<HTTPStatus> {
        context.db.transaction { (db) -> EventLoopFuture<Void> in
            User.query(on: db)
                .with(\.$teams)
                .filter(\.$id == context.auth.id)
                .first()
                .unwrap(or: Abort(.notFound))
                .flatMap { user -> EventLoopFuture<User> in
                    if let team = user.teams.first {
                        return user.$teams.detach(team, on: db)
                            .map { user }
                    }
                    return db.eventLoop.makeSucceededFuture(user)
                }
                .flatMap { user in
                    user.isFloater = false
                    user.requiresRandomAssignment = false
                    return db.eventLoop.flatten([
                        user.save(on: db),
                        Team.addMember(user: user, toTeam: body.teamId, on: db)
                    ])
                }
        }
        .map { .ok }
    }
}
