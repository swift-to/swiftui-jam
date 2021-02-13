import Fluent
import Vapor
import JWT
import APIRouting

struct UpdateMeBody: Decodable {
    
    struct Address: Decodable {
        var street: String
        var street2: String?
        var city: String
        var state: String
        var postalCode: String
        var country: String
    }
    
    var name: String
    var address: Address?
}

struct UpdateMeEndpoint: APIRoutingEndpoint {
    
    static var method: APIRoutingHTTPMethod = .patch
    static var path: String = "/me"
    
    static func run(
        context: AuthorizedRoutingContext,
        parameters: Void,
        query: Void,
        body: UpdateMeBody
    ) throws -> EventLoopFuture<HTTPStatus> {
        User.query(on: context.db)
            .with(\.$address)
            .filter(\.$id == context.auth.id)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { user -> EventLoopFuture<User> in
                user.name = body.name
                return user.save(on: context.db)
                    .map { user }
            }
            .flatMap { user in
                if let addressUpdate = body.address {
                    let address: Address
                    if let oldAddress = user.address {
                        address = oldAddress
                        oldAddress.street = addressUpdate.street
                        oldAddress.street2 = addressUpdate.street2
                        oldAddress.city = addressUpdate.city
                        oldAddress.state = addressUpdate.state
                        oldAddress.postalCode = addressUpdate.postalCode
                        oldAddress.country = addressUpdate.country
                    } else {
                        let newAddress = Address()
                        address = newAddress
                        newAddress.street = addressUpdate.street
                        newAddress.street2 = addressUpdate.street2
                        newAddress.city = addressUpdate.city
                        newAddress.state = addressUpdate.state
                        newAddress.postalCode = addressUpdate.postalCode
                        newAddress.country = addressUpdate.country
                        do {
                            newAddress.$user.id = try user.requireID()
                        } catch {
                            return context.eventLoop.makeFailedFuture(error)
                        }
                    }
                    return address.save(on: context.db)
                        .flatMap {
                            do {
                                user.$address.id = try address.requireID()
                                return user.save(on: context.db)
                            } catch {
                                return context.eventLoop.makeFailedFuture(error)
                            }
                        }
                } else {
                    return context.eventLoop.makeSucceededFuture(())
                }
            }
            .map { .ok }
    }
}
