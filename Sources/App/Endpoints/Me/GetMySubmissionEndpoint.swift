import Fluent
import Vapor
import JWT
import APIRouting

struct GetMySubmissionEndpoint: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .get
    static var path: String = "/me/submission"
    
    static func run(
        context: AuthorizedRoutingContext,
        parameters: Void,
        query: Void,
        body: Void
    ) throws -> EventLoopFuture<SubmissionViewModel> {
        User.query(on: context.db)
            .with(\.$teams)
            .filter(\.$id == context.auth.id)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                
                guard let teamId = user.teams.first?.id else {
                    return context.eventLoop.makeFailedFuture(Abort(.notFound))
                }
                
                return Submission.query(on: context.db)
                    .filter(\.$team.$id == teamId)
                    .first()
                    .unwrap(or: Abort(.notFound))
                    .flatMap { submission in
                        guard let submissionId = submission.id else {
                            return context.eventLoop.makeFailedFuture(Abort(.internalServerError))
                        }
                        return Submission.deepFindById(submissionId, on: context.db)
                    }
            }
            .flatMapThrowing { try SubmissionViewModel($0) }
    }
}
