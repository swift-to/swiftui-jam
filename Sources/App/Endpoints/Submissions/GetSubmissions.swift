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
    ) throws -> EventLoopFuture<[TeamDetailsViewModel]> {
        Team.query(on: context.db)
            .with(\.$captain)
            .with(\.$members)
            .all()
            .flatMapThrowing { try $0.map(TeamDetailsViewModel.init) }
    }
}
