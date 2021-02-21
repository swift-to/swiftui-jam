import Fluent
import Vapor
import JWT
import APIRouting

struct SubmissionImageUploadParams: Decodable, UUIDExtractable {
    var id: String
}

struct UploadSubmissionImageBody: Decodable {
    var info: FileUploadInfo
}

struct PendingImageUploadResponse: Codable, Content {
    var id: UUID
    var uploadUrl: URL
}

struct PrepareSubmissionImageUploadEndpoint: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .post
    static var path: String = "/submissions/:id/images/upload"
    
    static func run(
        context: AuthorizedRoutingContext,
        parameters: SubmissionImageUploadParams,
        query: Void,
        body: UploadSubmissionImageBody
    ) throws -> EventLoopFuture<PendingImageUploadResponse> {
        
        let bucket = try Environment.getByKeyThrowing(.awsS3Bucket)
        
        let submissionId = try parameters.getUUID()
        
        return Submission.find(
            submissionId,
            on: context.db
        )
        .unwrap(or: Abort(.notFound))
        .flatMap { _ -> EventLoopFuture<PendingImageUploadResponse> in
            
            let submissionImage = SubmissionImage()
            submissionImage.$submission.id = submissionId
            
            return context.s3.createSignedURLForPutOperation(
                fileUploadInfo: body.info,
                bucket: bucket
            )
            .flatMap { url -> EventLoopFuture<PendingImageUploadResponse> in
                do {
                    
                    submissionImage.url = try urlWithoutSigning(url).absoluteString
                    
                    return submissionImage.create(on: context.db)
                        .flatMapThrowing { _ in
                            let itemImageId = try submissionImage.requireID()
                            return PendingImageUploadResponse(
                                id: itemImageId,
                                uploadUrl: url
                            )
                        }
                    
                } catch {
                    return context.eventLoop.makeFailedFuture(error)
                }
            }
            
        }
    }
    
}
