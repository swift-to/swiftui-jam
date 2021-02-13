import Vapor
import SotoSESV2

protocol SESManagingService {
    func sendEmail(to: String, subject: String, message: String) -> EventLoopFuture<Void>
    func prepareForDeallocation() throws
}

final class SESManager: SESManagingService {
    
    enum SESError: Error {
        case messageNotUTF8
    }
    
    private let client: AWSClient
    private let ses: SESV2
    
    init(
        accessKeyId: String,
        secretAccessKey: String
    ) {
        client = AWSClient(
            credentialProvider: .static(
                accessKeyId: accessKeyId,
                secretAccessKey: secretAccessKey
            ),
            httpClientProvider: .createNew
        )
        ses = SESV2(client: client)
    }
    
    func prepareForDeallocation() throws {
        try client.syncShutdown()
    }
    
    func sendEmail(to: String, subject: String, message: String) -> EventLoopFuture<Void> {
        return ses.sendEmail(
            SESV2.SendEmailRequest(
                content: .init(
                    simple: .init(
                        body: .init(text: .init(data: message)),
                        subject: .init(data: subject)
                    )
                ),
                destination: .init(toAddresses: [to]),
                fromEmailAddress: "hello@swiftuijam.com"
            )
        )
        .map { result in
            print(result)
            return ()
        }
    }
    
}
