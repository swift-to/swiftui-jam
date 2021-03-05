import Fluent
import Vapor

final class Submission: Model {
    static let schema = "submissions"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "teamId")
    var team: Team

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String
    
    @Field(key: "isHidden")
    var isHidden: Bool
    
    @OptionalField(key: "repoUrl")
    var repoUrl: String?
    
    @OptionalField(key: "latestRepoUrl")
    var latestRepoUrl: String?
    
    @OptionalField(key: "downloadUrl")
    var downloadUrl: String?
    
    @OptionalField(key: "blogUrl")
    var blogUrl: String?
    
    @OptionalField(key: "tags")
    var tags: String?
    
    @OptionalField(key: "credits")
    var credits: String?
    
    @Children(for: \.$submission)
    var images: [SubmissionImage]
    
    init() {
       isHidden = false
    }
    
    static func deepFindById(_ id: UUID, on db: Database) -> EventLoopFuture<Submission> {
        Submission.query(on: db)
            .filter(\.$id == id)
            .with(\.$team) {
                $0.with(\.$captain)
                $0.with(\.$members)
            }
            .with(\.$images)
            .first()
            .unwrap(or: Abort(.notFound))
    }
}

struct SubmissionViewModel: Equatable, Codable, Content {
    var id: UUID
    var name: String
    var description: String
    var repoUrl: String?
    var latestRepoUrl: String?
    var downloadUrl: String?
    var blogUrl: String?
    var tags: String?
    var credits: String?
    
    var team: TeamDetailsViewModel
    var images: [SubmissionImageViewModel]
}

extension SubmissionViewModel {
    
    init(_ submission: Submission) throws {
        
        let vm = try SubmissionViewModel(
            id: submission.requireID(),
            name: submission.name,
            description: submission.description,
            repoUrl: submission.repoUrl,
            latestRepoUrl: submission.latestRepoUrl,
            downloadUrl: submission.downloadUrl,
            blogUrl: submission.blogUrl,
            tags: submission.tags,
            credits: submission.credits,
            team: TeamDetailsViewModel(submission.team),
            images: submission.images
                .filter { !$0.isPending }
                .map { try SubmissionImageViewModel($0) }
        )
        
        self = vm
    }
    
}
