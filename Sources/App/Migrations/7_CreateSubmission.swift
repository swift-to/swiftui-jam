import Fluent
import PostgresKit

public struct CreateSubmissionTableMigration: Migration {
    
    public init() { }
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("submission")
            .id()
            .field(
                "teamId",
                .uuid,
                .foreignKey("teams", .key("id"),
                            onDelete: .noAction,
                            onUpdate: .noAction),
                .required
            )
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("github", .string, .required)
        
            .create()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("users")
            .delete()
    }
}
