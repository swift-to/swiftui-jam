import Fluent

public struct CreateUserTeamTableMigration: Migration {
    
    public init() { }
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("user+team")
            .id()
            
            .field(
                "teamId",
                .uuid,
                .foreignKey("teams", .key("id"),
                            onDelete: .noAction,
                            onUpdate: .noAction)
            )
            .field(
                "userId",
                .uuid,
                .foreignKey("users", .key("id"),
                            onDelete: .noAction,
                            onUpdate: .noAction)
            )
            .field("createdAt", .datetime)
            .unique(on: "teamId", "userId")
            .create()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("user+team")
            .delete()
    }
}
