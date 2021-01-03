import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    
    app.directory.publicDirectory = "Web/dist"
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    if app.environment == .production {
        guard var config: PostgresConfiguration = PostgresConfiguration(
            url: try Environment.getByKeyThrowing(.dbUrl)
        ) else {
            fatalError("Can't configure postgres")
        }
        config.tlsConfiguration = .forClient(certificateVerification: .none)
        app.databases.use(
            .postgres(configuration: config)
            , as: .psql)
    } else {
        app.databases.use(.postgres(
            hostname: try Environment.getByKeyThrowing(.dbHost),
            username: try Environment.getByKeyThrowing(.dbUser),
            password: try Environment.getByKeyThrowing(.dbPassword),
            database: try Environment.getByKeyThrowing(.dbName)
        ), as: .psql)
    }
    
    app.migrations.add(CreateUserTableMigration())
    app.migrations.add(CreateTeamTableMigration())
    app.migrations.add(CreateUserTeamTableMigration())
    
    #if DEBUG
    try app.autoMigrate().wait()
    #endif
    
    try routes(app)
}
