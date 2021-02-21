import Fluent
import FluentPostgresDriver

public struct UpdateSubmissionColumnsMigration: Migration {
    
    public init() { }
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("submissions")
            
            .field("downloadUrl", .string)
            .field("tags", .string)
            .field("blogUrl", .string)
            .field("credits", .string)
            
            .deleteField("repoUrl") // original column had required constraint which is wrong
            .update()
            .flatMap {
                database
                    .schema("submissions")
                    .field("repoUrl", .string) // recreate without constraint
                    .update()
            }
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("submissions")
            .deleteField("downloadUrl")
            .deleteField("tags")
            .deleteField("blogUrl")
            .deleteField("credits")
            .update()
    }
}
