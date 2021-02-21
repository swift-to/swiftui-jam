import Fluent
import FluentPostgresDriver

public struct AddRandomAssignmentColumn: Migration {
    
    enum MigrationError: Error {
        case dbNotPostgres
    }
    
    public init() { }
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        let defaultValue = SQLColumnConstraintAlgorithm.default(false)
        return database
            .schema("users")
            .field("requiresRandomAssignment",
                   .bool,
                   .sql(defaultValue),
                   .required
            )
            .field("notes", .string)
            .update()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("users")
            .deleteField("requiresRandomAssignment")
            .deleteField("notes")
            .update()
    }
}
