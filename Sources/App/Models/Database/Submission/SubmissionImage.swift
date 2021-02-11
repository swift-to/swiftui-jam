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
