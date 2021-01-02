import Fluent
import PostgresKit

public struct CreateTeamTableMigration: Migration {
    
    public init() { }
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("teams")
            .id()
            .field("name", .string, .required)
            .unique(on: "name")
            .create()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("teams")
            .delete()
    }
}
