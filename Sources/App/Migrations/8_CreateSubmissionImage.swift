import Fluent

public struct CreateSubmissionImageTableMigration: Migration {
    
    public init() { }
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("submissionImage")
            .id()
            .field(
                "submissionId",
                .uuid,
                .foreignKey("submissions", .key("id"),
                            onDelete: .noAction,
                            onUpdate: .noAction),
                .required
            )
            .field("url", .string, .required)
            .field("isPending", .bool, .required)
            .create()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("submissionImage")
            .delete()
    }
}
