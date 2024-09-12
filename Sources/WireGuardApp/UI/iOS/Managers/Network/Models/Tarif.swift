// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation

class Tarif: Codable {
    let id: String
    let nameEn: String
    let nameRu: String
    let price: Float
    let priceDiscount: Float?
    let uniqId: String

    enum CodingKeys: CodingKey {
        case id
        case name_en
        case name_ru
        case price
        case price_discount
        case uniq_id
    }

    init() {
        self.id = ""
        self.nameEn = ""
        self.nameRu = ""
        self.price = 0
        self.priceDiscount = 0
        self.uniqId = ""
    }

    init(id: String, nameEn: String, nameRu: String, price: Float, priceDiscount: Float?, uniqId: String) {
        self.id = id
        self.nameEn = nameEn
        self.nameRu = nameRu
        self.price = price
        self.priceDiscount = priceDiscount
        self.uniqId = uniqId
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.nameEn = try container.decode(String.self, forKey: .name_en)
        self.nameRu = try container.decode(String.self, forKey: .name_ru)
        self.price = try container.decode(Float.self, forKey: .price)
        self.priceDiscount = try container.decodeIfPresent(Float.self, forKey: .price_discount)
        self.uniqId = try container.decode(String.self, forKey: .uniq_id)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(nameEn, forKey: .name_en)
        try container.encode(nameRu, forKey: .name_ru)
        try container.encode(price, forKey: .price)
        try container.encodeIfPresent(priceDiscount, forKey: .price_discount)
        try container.encode(uniqId, forKey: .uniq_id)
    }
}
