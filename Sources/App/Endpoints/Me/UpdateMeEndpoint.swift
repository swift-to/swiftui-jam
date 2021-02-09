import Fluent
import Vapor
import JWT
import APIRouting

struct UpdateMeBody: Decodable {
    
    struct Address: Decodable {
        var street: String
        var street2: String?
        var city: String
        var postalCode: String
        var country: String
    }
    
    var name: String
    var address: Address?
}

struct UpdateMeEndpoint: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .patch
    static var path: String = "/me"
    
    static func run(
        context: AuthorizedRoutingContext,
        parameters: Void,
        query: Void,
        body: UpdateMeBody
    ) throws -> EventLoopFuture<HTTPStatus> {
        User.find(context.auth.id, on: context.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.name = body.name
                return user.save(on: context.db)
                    .map { user }
            }
//            .flatMap { user in
//                Address.query(on: context.db)
//                    .firs
//            }
            .map { .ok }
    }
}
