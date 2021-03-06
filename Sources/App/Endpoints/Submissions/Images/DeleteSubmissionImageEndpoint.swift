import Fluent
import Vapor
import JWT
import APIRouting

struct DeleteSubmissionImageParams: Decodable {
    var itemId: String
    var imageId: String
}

struct DeleteSubmissionImageEndpoint: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .delete
    static var path: String = "/submissions/:itemId/images/:imageId"
    
    static func run(
        context: AuthorizedRoutingContext,
        parameters: DeleteSubmissionImageParams,
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
            .flatMap { submissionImage -> EventLoopFuture<SubmissionImage> in
                if submissionImage.submission.$coverImage.id == submissionImage.id {
                    submissionImage.submission.$coverImage.id = nil
                    return submissionImage.submission
                        .save(on: context.db)
                        .map { submissionImage }
                }
                return context.eventLoop.makeSucceededFuture(submissionImage)
            }
            .flatMap { submissionImage -> EventLoopFuture<Void> in
                return deleteImage(
                    fullUrl: submissionImage.url,
                    context: context
                )
                .flatMap { _ in
                    return submissionImage.delete(on: context.db)
                }
            }
            .map { _ in .ok }
    }

            
}
