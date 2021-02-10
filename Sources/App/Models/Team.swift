import Fluent
import Vapor

final class Team: Model {
    static let schema = "teams"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Parent(key: "captainId")
    var captain: User
    
    @Siblings(through: UserTeam.self, from: \.$team, to: \.$user)
    var members: [User]
    
    @Field(key: "requiresFloater")
    var requiresFloater: Bool
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
}

struct TeamViewModel: Codable, Content, Equatable {
    var id: UUID
    var name: String
//    var captain: User?
//    var members: [User]?
}

extension TeamViewModel {
    init(_ team: Team) throws {
        self.id = try team.requireID()
        self.name = team.name
    }
}
