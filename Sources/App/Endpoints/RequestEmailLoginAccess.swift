import Fluent
import Vapor
import JWT
import APIRouting

struct EmailLoginAccessRequestBody: Decodable {
    var email: String
}

struct RequestEmailLoginAccessEndpoint: APIRoutingEndpoint {

    static var method: APIRoutingHTTPMethod = .post
    static var path: String = "/request-email-login"
    
    static func run(
        context: AccessManagementContext,
        parameters: Void,
        query: Void,
        body: EmailLoginAccessRequestBody
    ) throws -> EventLoopFuture<HTTPStatus> {
        return User.query(on: context.db)
            .filter(\.$email == body.email)
            .first()
            .unwrap(orError: Abort(.notFound))
            .flatMap { user -> EventLoopFuture<Void> in
                
                do {
                    let auth = try AuthPayload(id: user.requireID(), email: body.email)
                    let token = try context.jwt.sign(auth, kid: nil)
                    return context.ses.sendEmail(
                        to: body.email,
                        message: """
                        Use this the link below to login.

                        You will have accesss for 24 hours. If you need to login again, just request access again for another email.

                        https://www.swiftuijam.com/?accessToken=\(token)
                        """
                    )
                } catch {
                    return context.eventLoop.makeFailedFuture(Abort(.internalServerError))
                }
            }
            
            .map { _ in .ok }
    }
}
