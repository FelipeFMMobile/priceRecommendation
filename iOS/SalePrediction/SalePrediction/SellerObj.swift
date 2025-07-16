//
//  SellerObj.swift
//  SalePrediction
//
//  Created by Felipe Menezes on 15/07/25.
//

import Foundation

struct SellerObj: Codable, Equatable, Hashable {
    
    var uuid: UUID = UUID()
    var seller_id: String
    var seller_city: String
    var payment_type: String
    var hour: Int
    var dow: Int
    var price: Double

    enum CodingKeys: String, CodingKey {
        case seller_id
        case seller_city
        case payment_type
        case hour
        case dow
        case price
    }

    static func mainUser() -> SellerObj {
        SellerObj(seller_id: "001cca7ae9ae17fb1caed9dfb1094831",
                  seller_city: "cariacica", payment_type: "credit_card", hour: 11, dow: 3, price: 0)
    }

    static func otherUser() -> SellerObj {
        SellerObj(seller_id: "001cca7ae9ae17fb1caed9dfb1094831",
                  seller_city: "franca", payment_type: "boleto", hour: 11, dow: 3, price: 0)
    }
}
