import Fluent
import Vapor
import APIRouting

struct StatusEndpoint: APIRoutingEndpoint {
    
    struct OKResponse: Content, Equatable {
        var status: String = "ok"
    }
    
    static var method: APIRoutingHTTPMethod = .get
    static var path: String = "/"
    
    static func run(
        context: UnauthorizedRoutingContext,
        parameters: Void,
        query: Void,
        body: Void
    ) throws -> EventLoopFuture<OKResponse> {
        context.eventLoop.makeSucceededFuture(OKResponse())
    }
}
