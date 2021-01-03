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
        
        if "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}".r?.matches(body.email) == false {
            throw Abort(.badRequest, reason: "Invalid Email")
        }
        
        return Team.query(on: context.db)
            .filter(\.$name == body.name)
            .first()
            .flatMapThrowing { (team) -> EventLoopFuture<Void> in
                guard team == nil else {
                    throw Abort(.badRequest, reason: "Team already exists")
                }
                
                let newUser = User()
                newUser.name = body.name
                newUser.email = body.email
                return newUser.create(on: context.db)
                    .flatMap { _ -> EventLoopFuture<Void> in
                        do {
                            // new team
                            let newTeam = Team()
                            newTeam.name = body.newTeamName
                            newTeam.requiresFloater = body.requiresFloater
                            newTeam.$captain.id = try newUser.requireID()
                            return newTeam.create(on: context.db)
                        } catch {
                            return context.eventLoop.makeFailedFuture(error)
                        }
                    }
            }
            .map { _ in .ok }
    }
}
