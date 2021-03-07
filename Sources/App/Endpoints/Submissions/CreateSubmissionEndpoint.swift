import Vapor
import Fluent
import APIRouting

struct CreateSubmissionBody: Decodable {
    var name: String
    var description: String
    var repoUrl: String?
    var downloadUrl: String?
    var blogUrl: String?
    var tags: String?
    var credits: String?
}

struct CreateSubmissionEndpoint: APIRoutingEndpoint {
    
    enum CreateSubmissionError: String, Error {
        case notATeamCaptain
        case submissionAlreadyExists
    }
    
    static var method: APIRoutingHTTPMethod = .post
    static var path: String = "/submissions"
    
    static func run(
        context: AuthorizedRoutingContext,
        parameters: Void,
        query: Void,
        body: CreateSubmissionBody
    ) throws -> EventLoopFuture<SubmissionViewModel> {
        User.query(on: context.db)
            .filter(\.$id == context.auth.id)
            .with(\.$teams)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { (user) in
                guard let team = user.teams.first,
                      let teamId = team.id,
                      team.$captain.id == user.id else {
                    return context.eventLoop.makeFailedFuture(CreateSubmissionError.notATeamCaptain)
                }
                
                return Submission.query(on: context.db)
                    .filter(\.$team.$id == teamId)
                    .first()
                    .flatMapThrowing { existingSubmission -> Void in
                        guard existingSubmission == nil else {
                            throw CreateSubmissionError.submissionAlreadyExists
                        }
                    }
                    .flatMap {
                        let submission = Submission()
                        submission.$team.id = teamId
                        submission.name = body.name
                        submission.description = body.description
                        submission.repoUrl = body.repoUrl
                        submission.downloadUrl = body.downloadUrl
                        submission.blogUrl = body.blogUrl
                        submission.tags = body.tags
                        submission.credits = body.credits
                        
                        return submission.create(on: context.db)
                            .flatMap { _ -> EventLoopFuture<Submission> in
                                guard let id = submission.id else {
                                    return context.eventLoop.makeFailedFuture(Abort(.internalServerError))
                                }
                                return Submission.deepFindById(id, on: context.db)
                            }
                            .flatMapThrowing { try SubmissionViewModel($0) }
                    }
                    
            }
        
    }
}
