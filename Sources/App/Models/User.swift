import Fluent
import Vapor

enum UserType: String, Codable {
    case soloProgrammer
    case teamProgrammer
    case teamDesigner
    case floatingDesigner
}

final class User: Model {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "email")
    var email: String
    
    @OptionalField(key: "bio")
    var bio: String?
}
