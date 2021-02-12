import Foundation
import Vapor
import Fluent

final class Address: Model {
    
    static let schema = "address"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "userId")
    var user: User

    @Field(key: "street")
    var street: String
    
    @OptionalField(key: "street2")
    var street2: String?
    
    @Field(key: "city")
    var city: String
    
    @Field(key: "state")
    var state: String
    
    @Field(key: "postalCode")
    var postalCode: String
    
    @Field(key: "country")
    var country: String
    
    init() {
        
    }
}

struct AddressViewModel: Codable, Content, Equatable {
    var street: String
    var street2: String?
    var city: String
    var state: String
    var postalCode: String
    var country: String
}

extension AddressViewModel {
    init(_ address: Address) {
        street = address.street
        street2 = address.street2
        city = address.city
        state = address.state
        postalCode = address.postalCode
        country = address.country
    }
}
