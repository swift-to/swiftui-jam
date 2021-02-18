import Foundation
import Vapor

protocol UUIDExtractable {
    var id: String { get }
}

extension UUIDExtractable {
    func getUUID() throws -> UUID {
        guard let uuid = UUID(uuidString: id) else {
            throw Abort(.badRequest, reason: "invalid UUID")
        }
        return uuid
    }
}

