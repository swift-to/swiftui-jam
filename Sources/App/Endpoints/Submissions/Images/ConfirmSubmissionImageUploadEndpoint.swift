import Fluent
import Vapor
import JWT
import APIRouting

struct ConfirmSubmissionImageUploadParams: Decodable {
    var itemId: String
    var imageId: String
}

struct ConfirmSubmissionImageUploadEndpoint: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .put
    static var path: String = "/submissions/:itemId/images/:imageId/confirm"
    
    static func run(
        context: AuthorizedRoutingContext,
        parameters: ConfirmSubmissionImageUploadParams,
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
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { submissionImage -> EventLoopFuture<Void> in
                return makeImagePublic(
                    fullUrl: submissionImage.url,
                    context: context
                )
                .flatMap { _ in
                    submissionImage.isPending = false
                    return submissionImage.save(on: context.db)
                }
            }
            .map { _ in .ok }
    }

            
}
