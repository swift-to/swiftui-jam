import Foundation
import Vapor
import JWT
@testable import App

final class MockJWT: JWTContext {
    
    enum MockJWTError: Error {
        case notImplemented
    }
    
    var signingResult: String
    
    init(signingResult: String) {
        self.signingResult = signingResult
    }
    
    func verify<Payload>(as payload: Payload.Type) throws -> Payload where Payload : JWTPayload {
        throw MockJWTError.notImplemented
    }
    
    func verify<Payload>(_ message: String, as payload: Payload.Type) throws -> Payload where Payload : JWTPayload {
        throw MockJWTError.notImplemented
    }
    
    func verify<Message, Payload>(_ message: Message, as payload: Payload.Type) throws -> Payload where Message : DataProtocol, Payload : JWTPayload {
        throw MockJWTError.notImplemented
    }
    
    func sign<Payload>(_ jwt: Payload, kid: JWKIdentifier?) throws -> String where Payload : JWTPayload {
        return signingResult
    }
    
}
