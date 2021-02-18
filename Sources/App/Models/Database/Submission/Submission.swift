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
    
    @OptionalField(key: "repoUrl")
    var repoUrl: String?
    
    @OptionalField(key: "downloadUrl")
    var downloadUrl: String?
    
    @Children(for: \.$submission)
    var images: [SubmissionImage]
    
    init() {
       
    }
}

struct SubmissionViewModel: Codable, Content {
    var id: UUID
    var name: String
    var description: String
    var team: TeamDetailsViewModel
    var images: [SubmissionImageViewModel]?
}

extension SubmissionViewModel {
    
    init(_ submission: Submission) throws {
        
        let vm = try SubmissionViewModel(
            id: submission.requireID(),
            name: submission.name,
            description:submission.description,
            team: TeamDetailsViewModel(submission.team),
            images: submission.images
                .filter { !$0.isPending }
                .map { try SubmissionImageViewModel($0) }
        )
        
        self = vm
    }
    
}
