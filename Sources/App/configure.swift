import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    if app.environment == .development {
        app.databases.use(.postgres(
            hostname: try Environment.getByKeyThrowing(.dbHost),
            username: try Environment.getByKeyThrowing(.dbUser),
            password: try Environment.getByKeyThrowing(.dbPassword),
            database: try Environment.getByKeyThrowing(.dbName)
        ), as: .psql)
    } else {
        try app.databases.use(.postgres(
            url: try Environment.getByKeyThrowing(.dbUrl)
        ), as: .psql)
    }

    app.migrations.add(CreateUserTableMigration())
    app.migrations.add(CreateTeamTableMigration())
    app.migrations.add(CreateUserTeamTableMigration())
    
    #if DEBUG
    try app.autoMigrate().wait()
    #endif

    // register routes
    try routes(app)
}
