import Fluent
import Vapor
import JWT
import APIRouting

struct PasswordLoginBody: Decodable {
    var email: String
    var password: String
}

struct PasswordLoginResponse: Codable, Content, Equatable {
    let token: String
}

struct PasswordLoginEndpoint: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .post
    static var path: String = "/login/password"
    
    static func run(
        context: AccessManagementContext,
        parameters: Void,
        query: Void,
        body: PasswordLoginBody
    ) throws -> EventLoopFuture<PasswordLoginResponse> {
        return User.query(on: context.db)
            .filter(\.$email == body.email)
            .first()
            .unwrap(orError: Abort(.unauthorized))
            .flatMap { user -> EventLoopFuture<PasswordLoginResponse> in
                guard let userPass = user.password, userPass == body.password else {
                    return context.eventLoop.makeFailedFuture(Abort(.unauthorized))
                }
                do {
                    let auth = try AuthPayload(id: user.requireID(), email: body.email)
                    let token = try context.jwt.sign(auth, kid: nil)
                    return context.eventLoop.makeSucceededFuture(PasswordLoginResponse(token: token))
                } catch {
                    return context.eventLoop.makeFailedFuture(Abort(.internalServerError))
                }
            }
    }
}
