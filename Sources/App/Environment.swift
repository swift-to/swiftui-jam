import Vapor

enum EnvironmentKey: String {
    case awsAccessKeyId = "AWS_ACCESS_KEY_ID"
    case awsSecretAccessKey = "AWS_SECRET_ACCESS_KEY"
    case awsS3Bucket = "AWS_S3_BUCKET"
    
    case dbHost = "DATABASE_HOST"
    case dbUser = "DATABASE_USERNAME"
    case dbPassword = "DATABASE_PASSWORD"
    case dbName = "DATABASE_NAME"
    
    case dbUrl = "DATABASE_URL"
    
    case jwtSecret = "JWT_SECRET"
}

extension Environment {
    
    static func getByKey(_ key: EnvironmentKey) -> String? { get(key.rawValue) }
    
    static func getByKeyThrowing(_ key: EnvironmentKey) throws -> String {
        guard let value = get(key.rawValue) else {
            print("Failed to access environment variable '\(key.rawValue)'")
            throw Abort(.internalServerError)
        }
        return value
    }
}
