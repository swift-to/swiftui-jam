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
    
    @Field(key: "repoUrl")
    var repoUrl: String
    
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
}

extension SubmissionViewModel {
    init(_ submission: Submission, team: Team) throws {
        self.id = try submission.requireID()
        self.team = try TeamDetailsViewModel(team)
        
        self.name = submission.name
        self.description = submission.description
    }
}
