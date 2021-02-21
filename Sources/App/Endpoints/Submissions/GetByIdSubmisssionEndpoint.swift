import Foundation
import Vapor
import APIRouting
import Fluent

struct GetSubmissionByIdParams: Decodable, UUIDExtractable {
    var id: String
}

struct GetSubmissionByIdEndpoint: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .get
    static var path: String = "/submissions/:id"
    
    static func run(
        context: UnauthorizedRoutingContext,
        parameters: GetSubmissionByIdParams,
        query: Void,
        body: Void
    ) throws -> EventLoopFuture<SubmissionViewModel> {
        let submissionId = try parameters.getUUID()
        return Submission.deepFindById(submissionId, on: context.db)
            .flatMapThrowing { try SubmissionViewModel($0) }
    }
}
