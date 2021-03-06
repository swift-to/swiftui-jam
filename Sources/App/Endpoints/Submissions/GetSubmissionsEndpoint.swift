import Foundation
import Vapor
import APIRouting
import Fluent

struct GetSubmissionsEndpoint: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .get
    static var path: String = "/submissions"
    
    static func run(
        context: UnauthorizedRoutingContext,
        parameters: Void,
        query: Void,
        body: Void
    ) throws -> EventLoopFuture<[SubmissionViewModel]> {
        Submission.query(on: context.db)
            .with(\.$team) {
                $0.with(\.$captain)
                $0.with(\.$members)
            }
            .with(\.$images)
            .filter(\.$isHidden == false)
            .group(.or) {
                $0.filter(\.$blogUrl != nil)
                $0.filter(\.$downloadUrl != nil)
                $0.filter(\.$repoUrl != nil)
                $0.filter(\.$latestRepoUrl != nil)
            }
            .sort(\.$name, .ascending)
            .all()
            .flatMapThrowing { try $0.map(SubmissionViewModel.init) }
    }
}
