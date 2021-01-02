import Fluent
import Vapor

final class Team: Model {
    static let schema = "teams"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Siblings(through: UserTeam.self, from: \.$team, to: \.$user)
    var members: [User]
}
