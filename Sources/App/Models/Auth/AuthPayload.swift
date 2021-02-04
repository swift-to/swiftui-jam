import Foundation
import JWT

struct AuthPayload: JWTPayload {
    var id: UUID
    var email: String
    var issuedAt = Date()
    var expiresAt = ExpirationClaim(value: Date(timeIntervalSinceNow: 60 * 60 * 24)) // 24 hours

    func verify(using signer: JWTSigner) throws {
        try expiresAt.verifyNotExpired()
    }
}
