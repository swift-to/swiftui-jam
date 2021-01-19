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
