import Foundation
import Vapor
import Fluent
import JWT
@testable import App

extension User {
    
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
    
    func generateAuthPayload() throws -> AuthPayload {
        AuthPayload(id: try requireID(), email: email)
    }
    
    func generateAuthToken() throws -> String {
        let signers = JWTSigners()
        signers.use(.hs256(key: try Environment.getByKeyThrowing(.jwtSecret)))
        return try signers.sign(generateAuthPayload())
    }
}

