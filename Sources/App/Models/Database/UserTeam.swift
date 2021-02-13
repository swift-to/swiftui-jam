import Fluent
import Vapor

final class UserTeam: Model {
    static let schema = "user+team"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "userId")
    var user: User

    @Parent(key: "teamId")
    var team: Team
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?

    init() { }

    init(id: UUID? = nil, user: User, team: Team) throws {
        self.id = id
        self.$user.id = try user.requireID()
        self.$team.id = try team.requireID()
    }
}
