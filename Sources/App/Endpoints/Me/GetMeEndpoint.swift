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
    ) throws -> EventLoopFuture<UserViewModel> {
        User.find(context.auth.id, on: context.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                UserTeam.query(on: context.db)
                    .filter(\.$user.$id == context.auth.id)
                    .with(\.$team)
                    .first()
                    .map { (user, $0?.team) }
            }
            .flatMapThrowing { try UserViewModel($0, team: $1) }
    }
}
