import Vapor
import SotoS3

struct S3FileUploadRequest: Codable {
    var bucket: String
    var fileName: String
    var bytesCount: Int
    var md5Hash: String
    var mimeType: String
}

struct S3FileModificationRequestDetails: Codable {
    var bucket: String
    var fileName: String
}

final class S3Manager {
    
    private let client: AWSClient
    private let s3: S3
    
    init(
        accessKeyId: String,
        secretAccessKey: String,
        region: Region
    ) {
        client = AWSClient(
            credentialProvider: .static(
                accessKeyId: accessKeyId,
                secretAccessKey: secretAccessKey
            ),
            httpClientProvider: .createNew
        )
        s3 = S3(client: client, region: region)
    }
    
    func prepareForDeallocation() throws {
        try client.syncShutdown()
    }
    
    func createSignedURLForPutOperation(fileUploadInfo: FileUploadInfo, bucket: String) -> EventLoopFuture<URL> {
        let fileName = UUID().uuidString + fileUploadInfo.mimeType.replacingOccurrences(of: "image/", with: ".")
        let uploadRequest = S3FileUploadRequest(
            bucket: bucket,
            fileName: fileName,
            bytesCount: fileUploadInfo.bytes,
            md5Hash: fileUploadInfo.md5Hash,
            mimeType: fileUploadInfo.mimeType)
        return createSignedURLForPutOperation(requestInfo: uploadRequest)
    }
    
    func createSignedURLForPutOperation(requestInfo: S3FileUploadRequest) -> EventLoopFuture<URL> {
        s3.signURL(
            url: URL(string: "https://\(requestInfo.bucket).s3.amazonaws.com/\(requestInfo.fileName)")!,
            httpMethod: .PUT,
            headers: HTTPHeaders([
                ("Content-MD5", requestInfo.md5Hash),
                ("Content-Type", requestInfo.mimeType),
                ("Content-Length", String(requestInfo.bytesCount))
            ]),
            expires: .hours(1)
        )
    }
    
    func makeObjectPublic(requestInfo: S3FileModificationRequestDetails) -> EventLoopFuture<Void> {
        s3.putObjectAcl(.init(acl: .publicRead, bucket: requestInfo.bucket, key: requestInfo.fileName))
            .flatMapErrorThrowing({ (error) -> S3.PutObjectAclOutput in
                throw error
            })
            .map { _ in () }
    }
    
    func deleteObject(requestInfo: S3FileModificationRequestDetails) -> EventLoopFuture<Void> {
        s3.deleteObject(.init(bucket: requestInfo.bucket, key: requestInfo.fileName))
            .flatMapErrorThrowing({ (error) -> S3.DeleteObjectOutput in
                throw error
            })
            .map { _ in () }
    }
    
}
