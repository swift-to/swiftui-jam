import Fluent
import FluentPostgresDriver

public struct AddSubmissionAwardColumnMigration: Migration {
    
    public init() { }
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        let boolFalseDefault = SQLColumnConstraintAlgorithm.default(false)
        return database
            .schema("submissions")
            .field("isAwardWinner", .bool, .required, .sql(boolFalseDefault))
            .update()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("submissions")
            .deleteField("isAwardWinner")
            .update()
    }
}
