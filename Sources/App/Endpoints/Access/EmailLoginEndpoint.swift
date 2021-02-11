import Fluent
import Vapor
import JWT
import APIRouting

struct EmailLoginBody: Decodable {
    var email: String
}

struct EmailLoginEndpoint: APIRoutingEndpoint {

    static var method: APIRoutingHTTPMethod = .post
    static var path: String = "/login/email"
    
    static func run(
        context: AccessManagementContext,
        parameters: Void,
        query: Void,
        body: EmailLoginBody
    ) throws -> EventLoopFuture<HTTPStatus> {
        return User.query(on: context.db)
            .filter(\.$email == body.email)
            .first()
            .flatMap { user -> EventLoopFuture<Void> in
                guard let user = user else {
                    // succeed regardless. We never give away if the email address exists
                    return context.eventLoop.makeSucceededFuture(())
                }
                
                do {
                    let auth = try AuthPayload(id: user.requireID(), email: body.email)
                    let token = try context.jwt.sign(auth, kid: nil)
                    return context.ses.sendEmail(
                        to: body.email,
                        subject: "SwiftUI Jam login access",
                        message: """
                        Use this link below to login.

                        You will have access for 24 hours. If you need to login again, just request access for another email.

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
