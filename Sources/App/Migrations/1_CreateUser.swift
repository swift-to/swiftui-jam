import Fluent
import PostgresKit

public struct CreateUserTableMigration: Migration {
    
    public init() { }
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("users")
            .id()
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("bio", .string)
            .field("isFloater", .bool, .required)
            .field("createdAt", .datetime)
            .unique(on: "email")
            .create()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("users")
            .delete()
    }
}
