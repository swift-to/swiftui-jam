import Fluent
import Vapor
import SwaggerDocumentationGenerator
import APIRouting
import JWT

func routes(_ app: Application) throws {

    app.group("api") {
        StatusEndpoint.register(in: $0)
        
        RegisterTeamMemberEndpoint.register(in: $0)
        RegisterCaptainEndpoint.register(in: $0)
        RegisterFloaterEndpoint.register(in: $0)
        RegisterAssignedTeamProgrammer.register(in: $0)
        
        GetTeamsEndpoint.register(in: $0)
        
        RequestEmailLoginAccessEndpoint.register(in: $0)
    }
    
    app.get("docs", "json") { (request) -> JSONString in
        return JSONString(value: try generateAPIDocs())
    }
    
    app.get("docs") { (request) -> HTML in
        let html = HTML(value:
           """
           <!DOCTYPE html>
           <html>
             <head>
               <title>ReDoc</title>
               <!-- needed for adaptive design -->
               <meta charset="utf-8"/>
               <meta name="viewport" content="width=device-width, initial-scale=1">
               <link href="https://fonts.googleapis.com/css?family=Montserrat:300,400,700|Roboto:300,400,700" rel="stylesheet">
               <!--
               ReDoc doesn't change outer page styles
               -->
               <style>
                 body {
                   margin: 0;
                   padding: 0;
                 }
               </style>
             </head>
             <body>
               <redoc spec-url='/docs/json'></redoc>
               <script src="https://cdn.jsdelivr.net/npm/redoc@next/bundles/redoc.standalone.js"> </script>
             </body>
           </html>
           """)
        return html
    }
}

struct UnauthorizedRoutingContext: APIRoutingContext {
    var eventLoop: EventLoop
    var db: FluentKit.Database
    
    static func createFrom(request: Request) throws -> UnauthorizedRoutingContext {
        return .init(
            eventLoop: request.eventLoop,
            db: request.db
        )
    }
}

struct AccessManagementContext: APIRoutingContext {
    
    var eventLoop: EventLoop
    var db: FluentKit.Database
    var jwt: JWTContext
    var ses: SESManager
    
    static func createFrom(request: Request) throws -> AccessManagementContext {
        return .init(
            eventLoop: request.eventLoop,
            db: request.db,
            jwt: request.jwt,
            ses: request.ses.manager
        )
    }
}

protocol JWTContext {
    func verify<Payload>(as payload: Payload.Type) throws -> Payload
        where Payload: JWTPayload


    func verify<Payload>(_ message: String, as payload: Payload.Type) throws -> Payload
        where Payload: JWTPayload


    func verify<Message, Payload>(_ message: Message, as payload: Payload.Type) throws -> Payload
        where Message: DataProtocol, Payload: JWTPayload

    func sign<Payload>(_ jwt: Payload, kid: JWKIdentifier?) throws -> String
        where Payload: JWTPayload
}

extension Request.JWT: JWTContext {}

public func generateAPIDocs() throws -> String {
    let filePath = #file
    let sourcesPath = URL(fileURLWithPath: filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
    let jsonString = try DocumentationGenerator.generateOpenAPIJSONString(
        readDirectoryUrls: [
            sourcesPath.appendingPathComponent("App")
        ], config: .init(
            securitySchemes: [
                "BearerAuth": [
                    "type": "http",
                    "scheme": "bearer"
                ]
            ],
            authForContext: { (contextName) -> String? in
                ["AuthorizedRoutingContext"]
                    .contains(where: { $0 == contextName}) ? "BearerAuth" : nil
            }))
    return jsonString
}
