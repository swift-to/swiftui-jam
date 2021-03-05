import Vapor
import Fluent
import APIRouting

struct UpdateSubmissionParams: Decodable, UUIDExtractable {
    var id: String
}

struct UpdateSubmissionBody: Decodable {
    var name: String?
    var description: String?
    var repoUrl: String?
    var latestRepoUrl: String?
    var downloadUrl: String?
    var blogUrl: String?
    var tags: String?
    var credits: String?
}

struct UpdateSubmissionEndpoint: APIRoutingEndpoint {
    
    enum UpdateSubmissionError: String, Error {
        case notATeamCaptain
        case teamDoesNotOwnThisSubmission
    }
    
    static var method: APIRoutingHTTPMethod = .patch
    static var path: String = "/submissions/:id"
    
    static func run(
        context: AuthorizedRoutingContext,
        parameters: UpdateSubmissionParams,
        query: Void,
        body: UpdateSubmissionBody
    ) throws -> EventLoopFuture<HTTPStatus> {
        
        try Submission.find(parameters.getUUID(), on: context.db)
            .unwrap(or: Abort(.notFound))
            .flatMap({ (submission) in
                User.query(on: context.db)
                    .filter(\.$id == context.auth.id)
                    .with(\.$teams)
                    .first()
                    .unwrap(or: Abort(.notFound))
                    .flatMap { (user) -> EventLoopFuture<Void> in
                        guard let team = user.teams.first,
                            let teamId = team.id,
                            team.$captain.id == user.id else {
                            return context.eventLoop.makeFailedFuture(UpdateSubmissionError.notATeamCaptain)
                        }
                        
                        guard submission.$team.id == teamId else {
                            return context.eventLoop.makeFailedFuture(UpdateSubmissionError.teamDoesNotOwnThisSubmission)
                        }
                        
                        submission.name = body.name ?? submission.name
                        submission.description = body.description ?? submission.description
                        submission.repoUrl = body.repoUrl ?? submission.repoUrl
                        submission.latestRepoUrl = body.latestRepoUrl ?? submission.latestRepoUrl
                        submission.downloadUrl = body.downloadUrl ?? submission.downloadUrl
                        submission.blogUrl = body.blogUrl ?? submission.blogUrl
                        submission.tags = body.tags ?? submission.tags
                        submission.credits = body.credits ?? submission.credits
                        
                        return submission.save(on: context.db)
                    }
            })
            .map { _ in .ok }
    }
}
