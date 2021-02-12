import Foundation
import Vapor
import Fluent

public struct SendRegistrationConfirmationBulkCommand: Command {
    public struct Signature: CommandSignature {
        public init() {}
    }

    public var help: String {
        "Send registration confirmation emails to the first 10 participants who have not received confirmation yet"
    }
    
    public init() {
        
    }
    
    public func run(using context: CommandContext, signature: Signature) throws {
        context.console.print("Sending emails to first 10 unconfirmed users")
        _ = try User.query(on: context.application.db)
            .filter(\.$isRegistrationEmailSent == false)
            .limit(10)
            .all()
            .flatMap { (users) -> EventLoopFuture<[Void]> in
                do {
                    let emailTasks = try users.map { user -> EventLoopFuture<Void> in
                        context.console.print(user.email)
                        let auth = try AuthPayload(id: user.requireID(), email: user.email)
                        let token = try context.application.jwt.signers.sign(auth, kid: nil)
                        
                        return context.application.ses.manager.sendEmail(
                            to: user.email,
                            subject: "Registration Confirmation",
                            message: """
                            This message is to confirm your registration for SwiftUI Jam.
                            You can now log in to the website to check your registration details.
                            You can also add a mailing address if you live in Canada or the USA in order to be sent a laptop sticker after the jam.

                            Follow the link below to review your information. Access will expire after 24 hours but you can always request a new login link from the website.

                            https://www.swiftuijam.com/?accessToken=\(token)
                            """)
                            .flatMap {
                                user.isRegistrationEmailSent = true
                                return user.save(on: context.application.db)
                            }
                    }
                    return context.application.eventLoopGroup.next()
                        .flatten(emailTasks)
                } catch {
                    context.console.print(error.localizedDescription)
                    return context.application.eventLoopGroup.next().makeFailedFuture(error)
                }
            }
            .wait()
    }
}
