import Foundation
import Vapor
import Fluent

public struct GenerateStickerSendoutReportCommand: Command {
    public struct Signature: CommandSignature {
        public init() {}
    }
    
    public enum Error: Swift.Error {
        case encodingError
    }
    
    public struct Row: Codable {
        var name: String
        var street: String
        var street2: String?
        var city: String
        var state: String
        var postalCode: String
        var country: String
        var needsAwardSticker: Bool
    }

    public var help: String {
        "Print a report of stickers to be sent out"
    }
    
    public init() {
        
    }
    
    public func run(using context: CommandContext, signature: Signature) throws {
        let output = try Address.query(on: context.application.db)
            .with(\.$user) {
                $0.with(\.$teams) {
                    $0.with(\.$submissions)
                }
            }
            .all()
            .flatMapThrowing { addresses -> String in
                let rows = addresses.map {
                    Row(
                        name: $0.user.name,
                        street: $0.street,
                        street2: $0.street2,
                        city: $0.city,
                        state: $0.state,
                        postalCode: $0.postalCode,
                        country: $0.country,
                        needsAwardSticker: $0.user.teams.contains(where: {
                            $0.submissions.contains(where: \.isAwardWinner)
                        })
                    )
                }
                guard let jsonString = try String(
                    data: JSONEncoder().encode(rows),
                    encoding: .utf8
                ) else {
                    throw Error.encodingError
                }
                return jsonString
            }
            .wait()
        context.console.print("----START----")
        context.console.print(output)
        context.console.print("----END----")
    }
}
