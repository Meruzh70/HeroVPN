// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation

class RegEntity: DefaultEntity {

    var sended: Bool?
    var exist: Bool?

    enum CodingKeys: CodingKey {
        case sended
        case exist
    }

    required init(from decoder: any Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sended = try container.decodeIfPresent(Bool.self, forKey: .sended)
        self.exist = try container.decodeIfPresent(Bool.self, forKey: .exist)
    }

}
