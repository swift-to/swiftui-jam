import Fluent
import Vapor
import JWT
import APIRouting

struct SetCoverSubmissionImageParams: Decodable {
    var itemId: String
    var imageId: String
}

struct SetCoverSubmissionImageEndpoint: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .put
    static var path: String = "/submissions/:itemId/images/:imageId/set-cover"
    
    static func run(
        context: AuthorizedRoutingContext,
        parameters: SetCoverSubmissionImageParams,
        query: Void,
        body: Void
    ) throws -> EventLoopFuture<HTTPStatus> {
        
        guard let itemId = UUID(uuidString: parameters.itemId),
              let imageId = UUID(uuidString: parameters.imageId) else {
            throw Abort(.badRequest)
        }
        
        return SubmissionImage.query(on: context.db)
            .group(.and) { $0
                .filter(\.$id == imageId)
                .filter(\.$submission.$id == itemId)
            }
            .with(\.$submission)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { submissionImage -> EventLoopFuture<Void> in
                submissionImage.submission.$coverImage.id = submissionImage.id
                return submissionImage.submission.save(on: context.db)
            }
            .map { _ in .ok }
    }

            
}
