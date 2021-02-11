import Fluent
import Vapor
import JWT
import APIRouting

struct GetMeEndpoint: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .get
    static var path: String = "/me"
    
    static func run(
        context: AuthorizedRoutingContext,
        parameters: Void,
        query: Void,
        body: Void
    ) throws -> EventLoopFuture<UserDetailsViewModel> {
        User.query(on: context.db)
            .with(\.$address)
            .filter(\.$id == context.auth.id)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                UserTeam.query(on: context.db)
                    .filter(\.$user.$id == context.auth.id)
                    .first()
                    .flatMap { uTeam -> EventLoopFuture<Team?> in
                        if let userTeam = uTeam {
                            return Team.query(on: context.db)
                                .with(\.$captain)
                                .with(\.$members)
                                .filter(\.$id == userTeam.$team.id)
                                .first()
                        } else {
                            return context.eventLoop.makeSucceededFuture(nil)
                        }
                    }
                    .map { (user, $0) }
            }
            .flatMapThrowing { try UserDetailsViewModel($0, team: $1, address: $0.address) }
    }
}
