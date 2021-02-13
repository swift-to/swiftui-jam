import Foundation
import Vapor
@testable import App

class MockSESManager: SESManagingService {
    
    struct Email: Equatable {
        var to: String
        var subject: String
        var message: String
    }
    
    var eventLoop: EventLoop
    var lastEmail: Email?
    
    init(eventLoop: EventLoop) {
        self.eventLoop = eventLoop
    }
    
    func sendEmail(to: String, subject: String, message: String) -> EventLoopFuture<Void> {
        lastEmail = Email(to: to, subject: subject, message: message)
        return eventLoop.makeSucceededFuture(())
    }
    
    func prepareForDeallocation() throws {
        
    }
    
}
