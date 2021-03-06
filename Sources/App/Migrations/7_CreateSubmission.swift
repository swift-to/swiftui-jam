import Fluent
import PostgresKit

public struct CreateSubmissionTableMigration: Migration {
    
    public init() { }
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("submissions")
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
            .field("repoUrl", .string, .required)
        
            .create()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("submissions")
            .delete()
    }
}
