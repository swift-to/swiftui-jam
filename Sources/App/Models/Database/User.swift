import Fluent
import Vapor

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
    
    @OptionalField(key: "notes")
    var notes: String?
    
    @Field(key: "isFloater")
    var isFloater: Bool
    
    @Field(key: "requiresRandomAssignment")
    var requiresRandomAssignment: Bool
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Siblings(through: UserTeam.self, from: \.$user, to: \.$team)
    var teams: [Team] // Should only ever have one relation at a time but vapor doesnt currently have a model definition that works like this
    
    @OptionalParent(key: "addressId")
    var address: Address?
    
    init() {
        isFloater = false
    }
    
    static func create(
        name: String,
        email: String,
        isFloater: Bool,
        requiresRandomAssignment: Bool,
        notes: String?,
        on db: Database
    ) throws -> EventLoopFuture<User> {
        
        if "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}".r?.matches(email) == false {
            throw Abort(.badRequest, reason: "Invalid Email")
        }
        
        return User.query(on: db)
            .filter(\.$email == email)
            .first()
            .flatMap { (existing) -> EventLoopFuture<User> in
                if existing != nil {
                    return db.eventLoop.makeFailedFuture(
                        Abort(.badRequest, reason: "Email already exists")
                    )
                }
                let newUser = User()
                newUser.name = name
                newUser.email = email
                newUser.isFloater = isFloater
                newUser.requiresRandomAssignment = requiresRandomAssignment
                newUser.notes = notes
                return newUser.create(on: db).map { _ in newUser }
            }
    }
}

enum RegistrationTypeViewModel: String, Codable, Equatable {
    case teamCaptain
    case teamMember
    case floatingDesigner
    case randomAssignedProgrammer
    case notParticipating
}

struct UserViewModel: Codable, Content, Equatable {
    var id: UUID
    var name: String
}

extension UserViewModel {
    init(_ user: User) throws {
        self.id = try user.requireID()
        self.name = user.name
    }
}

struct UserDetailsViewModel: Codable, Content, Equatable {
    var id: UUID
    var name: String
    var type: RegistrationTypeViewModel
    var team: TeamDetailsViewModel?
    var address: AddressViewModel?
}

extension UserDetailsViewModel {
    init(_ user: User, team: Team?, address: Address?) throws {
        self.id = try user.requireID()
        self.team = try team.map(TeamDetailsViewModel.init)
        
        self.name = user.name
        
        if let team = team {
            if team.$captain.id == self.id {
                self.type = .teamCaptain
            } else {
                self.type = .teamMember
            }
        }
        else if user.isFloater {
            self.type = .floatingDesigner
        } else if user.requiresRandomAssignment {
            self.type = .randomAssignedProgrammer
        } else {
            self.type = .notParticipating
        }
        
        self.address = address.map(AddressViewModel.init)
    }
}
