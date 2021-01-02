import Fluent
import Vapor
//import JWT
import FluentPostgresDriver
import APIRouting

struct RegisterRequestBody: Decodable {
    var email: String
    var name: String
}

struct RegisterEndpoint: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .post
    static var path: String = "/register"
    
    static func run(
        context: UnauthorizedRoutingContext,
        parameters: Void,
        query: Void,
        body: RegisterRequestBody
    ) throws -> EventLoopFuture<HTTPStatus> {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if !emailPred.evaluate(with: body.email) {
            throw Abort(.badRequest, reason: "Invalid Email")
        }
        
        let newUser = User()
        newUser.name = body.name
        newUser.email = body.email
        
        return newUser.create(on: context.db)
            .map { _ in .ok }
//            .flatMapThrowing { _ in
//                try AuthResponse(user: newUser, signer: context.jwt)
//            }
//            .flatMapErrorThrowing { (error) -> AuthResponse in
//                throw Abort(.badRequest)
//            }
    }
}