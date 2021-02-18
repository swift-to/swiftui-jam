import Fluent
import Vapor

final class SubmissionImage: Model {
    
    static var schema: String = "submissionImages"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "url")
    var url: String
    
    @Parent(key: "submissionId")
    var submission: Submission
    
    @Field(key: "isPending")
    var isPending: Bool
    
    init() {
        isPending = true
    }
    
}

struct SubmissionImageViewModel: Codable, Content {

    var id: UUID
    var url: String

    init(
        id: UUID,
        url: String
    ) {
        self.id = id
        self.url = url
    }
    
}

extension SubmissionImageViewModel {
    init(_ submissionImage: SubmissionImage) throws {
        self = SubmissionImageViewModel(
            id: try submissionImage.requireID(),
            url: submissionImage.url
        )
    }
}
