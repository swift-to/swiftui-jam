import Foundation
import Vapor

func makeImagePublic(
    fullUrl: String,
    context: AuthorizedRoutingContext
) -> EventLoopFuture<Void> {
    
    guard let fullUrlComponents = URLComponents(string: fullUrl),
          let bucket = fullUrlComponents.host?.split(separator: ".").first
    else {
        return context.eventLoop.makeFailedFuture(Abort(.internalServerError))
    }
    
    let fullFileName = fullUrlComponents.path.replacingOccurrences(of: "/", with: "")
    
    return context.s3
        .makeObjectPublic(
            requestInfo: .init(
                bucket: String(bucket),
                fileName: fullFileName
            )
        )
}

func deleteImage(
    fullUrl: String,
    context: AuthorizedRoutingContext
) -> EventLoopFuture<Void> {
    
    guard let fullUrlComponents = URLComponents(string: fullUrl),
          let bucket = fullUrlComponents.host?.split(separator: ".").first
    else {
        return context.eventLoop.makeFailedFuture(Abort(.internalServerError))
    }
    
    let fullFileName = fullUrlComponents.path.replacingOccurrences(of: "/", with: "")
    
    return context.s3
        .deleteObject(
            requestInfo: .init(
                bucket: String(bucket),
                fileName: fullFileName
            )
        )
}
