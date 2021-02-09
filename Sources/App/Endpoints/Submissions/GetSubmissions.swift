import Foundation
import Vapor
import APIRouting

struct GetSubmissions: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .get
    static var path: String = "/submissions"
    
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
