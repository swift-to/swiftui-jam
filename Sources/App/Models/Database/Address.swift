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
    
    @Field(key: "postalCode")
    var postalCode: String
    
    @Field(key: "country")
    var country: String
    
    init() {
        
    }
}

struct AddressViewModel: Decodable {
    var street: String
    var street2: String?
    var city: String
    var postalCode: String
    var country: String
}
