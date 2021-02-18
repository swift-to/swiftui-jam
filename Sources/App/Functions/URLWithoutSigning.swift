import Foundation
import Vapor

func urlWithoutSigning(_ url: URL) throws -> URL {
    guard var urlComponents = URLComponents(string: url.absoluteString) else {
        throw Abort(.internalServerError)
    }
    
    urlComponents.query = nil
    
    guard let urlWithoutSigning = urlComponents.url else {
        throw Abort(.internalServerError)
    }
    
    return urlWithoutSigning
}
