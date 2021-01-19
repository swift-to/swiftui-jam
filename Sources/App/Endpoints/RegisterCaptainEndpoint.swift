import Fluent
import Vapor
//import JWT
import FluentPostgresDriver
import APIRouting
import Regex

struct RegisterCaptainRequestBody: Decodable {
    var email: String
    var name: String
    var newTeamName: String
    var requiresFloater: Bool
}

struct RegisterCaptainEndpoint: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .post
    static var path: String = "/register-captain"
    
    static func run(
        context: UnauthorizedRoutingContext,
        parameters: Void,
        query: Void,
        body: RegisterCaptainRequestBody
    ) throws -> EventLoopFuture<HTTPStatus> {
        
        return Team.query(on: context.db)
            .filter(\.$name == body.name)
            .first()
            .flatMap { (team) -> EventLoopFuture<Void> in
                do {
                    guard team == nil else {
                        throw Abort(.badRequest, reason: "Team already exists")
                    }
                    
                    return try User.create(
                        name: body.name,
                        email: body.email,
                        isFloater: false,
                        requiresRandomAssignment: false,
                        notes: nil,
                        on: context.db
                    )
                    .flatMap { newUser -> EventLoopFuture<Void> in
                        do {
                            // new team
                            let newTeam = Team()
                            newTeam.name = body.newTeamName
                            newTeam.requiresFloater = body.requiresFloater
                            newTeam.$captain.id = try newUser.requireID()
                            return newTeam.create(on: context.db)
                                .flatMap { _ in
                                    newTeam.$members.attach(newUser, on: context.db)
                                }
                        } catch {
                            return context.eventLoop.makeFailedFuture(error)
                        }
                    }
                } catch {
                    return context.eventLoop.makeFailedFuture(error)
                }
            }
            .map { _ in .ok }
    }
}
