import Fluent
import FluentPostgresDriver

public struct AddUserPasswordAndRegistrationConfirmationColumns: Migration {
    
    public init() { }
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        let boolFalseDefault = SQLColumnConstraintAlgorithm.default(false)
        return database
            .schema("users")
            .field("password", .string)
            .field("isRegistrationEmailSent", .bool, .sql(boolFalseDefault), .required)
            .update()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("users")
            .deleteField("password")
            .deleteField("isRegistrationEmailSent")
            .update()
    }
}
