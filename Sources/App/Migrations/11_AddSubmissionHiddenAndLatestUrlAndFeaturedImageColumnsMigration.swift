import Fluent
import FluentPostgresDriver

public struct AddSubmissionHiddenAndLatestUrlAndFeaturedImageColumnsMigration: Migration {
    
    public init() { }
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        let boolFalseDefault = SQLColumnConstraintAlgorithm.default(false)
        return database
            .schema("submissions")
            .field("isHidden", .bool, .required, .sql(boolFalseDefault))
            .field("latestRepoUrl", .string)
            .field("coverImageId",
                   .uuid,
                   .foreignKey(
                    "submissionImages",
                    .key("id"),
                    onDelete: .noAction,
                    onUpdate: .noAction)
            )
            .update()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("submissions")
            .deleteField("isHidden")
            .deleteField("latestRepoUrl")
            .deleteField("coverImageId")
            .update()
    }
}
