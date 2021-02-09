import Foundation
import Vapor
import APIRouting
import JWT
import FluentKit

struct UnauthorizedRoutingContext: APIRoutingContext {
    var eventLoop: EventLoop
    var db: FluentKit.Database
    
    static func createFrom(request: Request) throws -> UnauthorizedRoutingContext {
        return .init(
            eventLoop: request.eventLoop,
            db: request.db
        )
    }
}

struct AccessManagementContext: APIRoutingContext {
    
    var eventLoop: EventLoop
    var db: FluentKit.Database
    var jwt: JWTContext
    var ses: SESManager
    
    static func createFrom(request: Request) throws -> AccessManagementContext {
        return .init(
            eventLoop: request.eventLoop,
            db: request.db,
            jwt: request.jwt,
            ses: request.ses.manager
        )
    }
}

protocol JWTContext {
    func verify<Payload>(as payload: Payload.Type) throws -> Payload
        where Payload: JWTPayload


    func verify<Payload>(_ message: String, as payload: Payload.Type) throws -> Payload
        where Payload: JWTPayload


    func verify<Message, Payload>(_ message: Message, as payload: Payload.Type) throws -> Payload
        where Message: DataProtocol, Payload: JWTPayload

    func sign<Payload>(_ jwt: Payload, kid: JWKIdentifier?) throws -> String
        where Payload: JWTPayload
}

extension Request.JWT: JWTContext {}

struct AuthorizedRoutingContext: APIRoutingContext {
    var eventLoop: EventLoop
    var db: FluentKit.Database
    var auth: AuthPayload
    var s3: S3Manager
    
    static func createFrom(request: Request) throws -> AuthorizedRoutingContext {
        let authPayload = try request.jwt.verify(as: AuthPayload.self)
        return .init(
            eventLoop: request.eventLoop,
            db: request.db,
            auth: authPayload,
            s3: request.s3.manager
        )
    }
}
