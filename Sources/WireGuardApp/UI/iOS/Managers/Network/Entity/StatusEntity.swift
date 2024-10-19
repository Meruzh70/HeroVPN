// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation

class StatusEntity: DefaultEntity {

    var uniqId: String?
    var secLeft: Int?
    var expiredAt: String?
    var activeAt: String?
    var free: Bool?

    enum CodingKeys: String, CodingKey {
        case uniqId = "uniq_id",
             secLeft,
             expiredAt,
             activeAt,
             free
    }

    required init(from decoder: any Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uniqId = try container.decodeIfPresent(String.self, forKey: .uniqId)
        self.secLeft = try container.decodeIfPresent(Int.self, forKey: .secLeft)
        self.expiredAt = try container.decodeIfPresent(String.self, forKey: .expiredAt)
        self.activeAt = try container.decodeIfPresent(String.self, forKey: .activeAt)
        self.free = try container.decodeIfPresent(Bool.self, forKey: .free)
    }
}
