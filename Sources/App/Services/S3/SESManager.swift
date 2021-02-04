import Vapor
import SotoSESV2

final class SESManager {
    
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
    
    func sendEmail(to: String, message: String) -> EventLoopFuture<Void> {
        
        guard let messageData = message.data(using: .utf8) else {
            return ses.eventLoopGroup.next().makeFailedFuture(SESError.messageNotUTF8)
        }
        
        return ses.sendEmail(
            SESV2.SendEmailRequest(
                content: .init(raw: .init(data: messageData)),
                destination: .init(toAddresses: [to]),
                fromEmailAddress: "hello@swiftuijam.com"
            )
        )
        .map { result in
            print(result)
            return ()
        }
    }
    
//    func createSignedURLForPutOperation(fileUploadInfo: FileUploadInfo, bucket: String) -> EventLoopFuture<URL> {
//        let fileName = UUID().uuidString + fileUploadInfo.mimeType.replacingOccurrences(of: "image/", with: ".")
//        let uploadRequest = S3FileUploadRequest(
//            bucket: bucket,
//            fileName: fileName,
//            bytesCount: fileUploadInfo.bytes,
//            md5Hash: fileUploadInfo.md5Hash,
//            mimeType: fileUploadInfo.mimeType)
//        return createSignedURLForPutOperation(requestInfo: uploadRequest)
//    }
//
//    func createSignedURLForPutOperation(requestInfo: S3FileUploadRequest) -> EventLoopFuture<URL> {
//        s3.signURL(
//            url: URL(string: "https://\(requestInfo.bucket).s3.amazonaws.com/\(requestInfo.fileName)")!,
//            httpMethod: .PUT,
//            headers: HTTPHeaders([
//                ("Content-MD5", requestInfo.md5Hash),
//                ("Content-Type", requestInfo.mimeType),
//                ("Content-Length", String(requestInfo.bytesCount))
//            ]),
//            expires: .hours(1)
//        )
//    }
//
//    func makeObjectPublic(requestInfo: S3FilePublicizeRequest) -> EventLoopFuture<Void> {
//        s3.putObjectAcl(.init(acl: .publicRead, bucket: requestInfo.bucket, key: requestInfo.fileName))
//            .flatMapErrorThrowing({ (error) -> S3.PutObjectAclOutput in
//                throw error
//            })
//            .map { _ in ()
//        }
//    }
    
}
