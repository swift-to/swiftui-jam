import Foundation
import Vapor

struct HTML {
  let value: String
}

extension HTML: ResponseEncodable {
  public func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
    var headers = HTTPHeaders()
    headers.add(name: .contentType, value: "text/html")
    return request.eventLoop.makeSucceededFuture(.init(
      status: .ok, headers: headers, body: .init(string: value)
    ))
  }
}

struct JSONString {
    let value: String
}

extension JSONString: ResponseEncodable {
  public func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
    var headers = HTTPHeaders()
    headers.add(name: .contentType, value: "application/json")
    return request.eventLoop.makeSucceededFuture(.init(
      status: .ok, headers: headers, body: .init(string: value)
    ))
  }
}
