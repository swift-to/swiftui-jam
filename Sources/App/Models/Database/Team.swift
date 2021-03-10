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
    
    @Children(for: \.$team)
    var submissions: [Submission]
    
    @Field(key: "requiresFloater")
    var requiresFloater: Bool
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
}

extension Team {
    
    static func addMember(
        user: User,
        toTeam teamId: UUID,
        on database: FluentKit.Database
    ) -> EventLoopFuture<Void> {
        return Team.query(on: database)
            .with(\.$members)
            .filter(\.$id == teamId)
            .first()
            .unwrap(or: Abort(.notFound, reason: "Team not found"))
            .flatMap { team -> EventLoopFuture<Void> in
                do {
                    guard team.members.count <= 5 else {
                        throw Abort(.badRequest, reason: "Team already has maximum number of members")
                    }
                    return team.$members.attach(user, method: .ifNotExists, on: database)
                }
                catch {
                    return database.eventLoop.makeFailedFuture(error)
                }
            }
    }
    
}

struct TeamViewModel: Codable, Content, Equatable {
    var id: UUID
    var name: String
}

extension TeamViewModel {
    init(_ team: Team) throws {
        self.id = try team.requireID()
        self.name = team.name
    }
}

struct TeamDetailsViewModel: Codable, Content, Equatable {
    var id: UUID
    var name: String
    var captain: UserViewModel
    var members: [UserViewModel]
}

extension TeamDetailsViewModel {
    init(_ team: Team) throws {
        self.id = try team.requireID()
        self.name = team.name
        self.captain = try UserViewModel(team.captain)
        self.members = try team.members.map(UserViewModel.init)
    }
}
