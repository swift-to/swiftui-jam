import Foundation

struct FileUploadInfo: Decodable {
    var bytes: Int
    var md5Hash: String
    var mimeType: String
}
