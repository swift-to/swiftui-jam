import Fluent
import FluentPostgresDriver

public struct AddUserAddressColumn: Migration {
    
    public init() { }
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("users")
            .field(
                "addressId",
                .uuid,
                .foreignKey("address", .key("userId"),
                            onDelete: .noAction,
                            onUpdate: .noAction)
            )
            .update()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("users")
            .deleteField("addressId")
            .update()
    }
}
