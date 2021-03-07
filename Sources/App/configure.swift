import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    app.middleware.use(CORSMiddleware(configuration: corsConfiguration))
    
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    
    // Add HMAC with SHA-256 signer.
    app.jwt.signers.use(
        .hs256(
            key: try Environment.getByKeyThrowing(.jwtSecret)
        )
    )
    
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
    
    try setUpAWSManagers(app)
    addMigrations(app)
    addCommands(app)
    
    #if DEBUG
//    try app.autoRevert().wait()
    #endif
    try app.autoMigrate().wait()
    
    try routes(app)
}

public func setUpAWSManagers(_ app: Application) throws {
    
    let accessKey = try Environment.getByKeyThrowing(.awsAccessKeyId)
    let secretKey = try Environment.getByKeyThrowing(.awsSecretAccessKey)
    
    app.s3.manager = S3Manager(
        accessKeyId: accessKey,
        secretAccessKey: secretKey,
        region: .useast1
    )
    
    app.ses.manager = SESManager(
        accessKeyId: accessKey,
        secretAccessKey: secretKey
    )
}

public func addMigrations(_ app: Application) {
    app.migrations.add(CreateUserTableMigration())
    app.migrations.add(CreateTeamTableMigration())
    app.migrations.add(CreateUserTeamTableMigration())
    app.migrations.add(AddRandomAssignmentColumn())
    
    // Address
    app.migrations.add(CreateAddressTableMigration())
    app.migrations.add(AddUserAddressColumn())

    //Submissions
    app.migrations.add(CreateSubmissionTableMigration())
    app.migrations.add(CreateSubmissionImageTableMigration())

    // User password/registration confirmation
    app.migrations.add(AddUserPasswordAndRegistrationConfirmationColumns())
    
    // Submission adjustments
    app.migrations.add(UpdateSubmissionColumnsMigration())
    app.migrations.add(AddSubmissionHiddenAndLatestUrlAndFeaturedImageColumnsMigration())
    
}

public func addCommands(_ app: Application) {
    app.commands.use(SendRegistrationConfirmationBulkCommand(), as: "send-registration-email-bulk", isDefault: false)
}
