import Fluent
import Vapor
import JWT
import APIRouting

struct UpdatePasswordBody: Decodable {
    var password: String
}

struct UpdatePasswordEndpoint: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .post
    static var path: String = "/me/password"
    
    static func run(
        context: AuthorizedRoutingContext,
        parameters: Void,
        query: Void,
        body: UpdatePasswordBody
    ) throws -> EventLoopFuture<HTTPStatus> {
        User.query(on: context.db)
            .with(\.$address)
            .filter(\.$id == context.auth.id)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.password = body.password
                return user.save(on: context.db)
            }
            .map { .ok }
    }
}
