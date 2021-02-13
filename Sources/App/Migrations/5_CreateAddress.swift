import Fluent
import PostgresKit

public struct CreateAddressTableMigration: Migration {
    
    public init() { }
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("address")
            .id()
            .field(
                "userId",
                .uuid,
                .foreignKey("users", .key("id"),
                            onDelete: .noAction,
                            onUpdate: .noAction),
                .required
            )
            .field("street", .string, .required)
            .field("street2", .string)
            .field("city", .string, .required)
            .field("state", .string, .required)
            .field("postalCode", .string, .required)
            .field("country", .string, .required)
            .create()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("address")
            .delete()
    }
}
