import Foundation
import Vapor
import Fluent
import JWT
@testable import App

extension User {
    /// Creates a new user in the database
    static func createFixture(
        name: String,
        email: String? = nil,
        database: Database
    ) throws -> User {
        let user = User()
        user.name = name
        user.email = email ?? "\(name)@test.com"
        
        try user.create(on: database).wait()
        return user
    }
}

//extension AuthResponse {
//
//    static func createFixture(
//        user: User
//    ) throws -> AuthResponse {
//        let signers = JWTSigners()
//        signers.use(.hs256(key: try Environment.getByKeyThrowing(.jwtSecret)))
//
//        let userId = try user.requireID()
//        let tokenPayload = AuthPayload(id: userId, email: user.email)
//        let refreshPayload = RefreshPayload(id: userId, email: user.email)
//
//        return AuthResponse(
//            token: try signers.sign(tokenPayload),
//            tokenExpiry: tokenPayload.expiresAt.value,
//            refreshToken: try signers.sign(refreshPayload),
//            refreshTokenExpiry: refreshPayload.expiresAt.value
//        )
//    }
//}

