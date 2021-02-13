import Fluent
import Vapor
//import JWT
import APIRouting

struct GetTeamsEndpoint: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .get
    static var path: String = "/teams"
    
    static func run(
        context: UnauthorizedRoutingContext,
        parameters: Void,
        query: Void,
        body: Void
    ) throws -> EventLoopFuture<[TeamViewModel]> {
        Team.query(on: context.db)
            .all()
            .flatMapThrowing { try $0.map(TeamViewModel.init) }
    }
}
