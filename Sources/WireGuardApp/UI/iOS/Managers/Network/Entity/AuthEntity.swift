// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation

class AuthEntity: DefaultEntity {

    var token: String?
    var name: String?

    enum CodingKeys: CodingKey {
        case token
        case name
    }

    required init(from decoder: any Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.token = try container.decodeIfPresent(String.self, forKey: .token)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
    }

}
