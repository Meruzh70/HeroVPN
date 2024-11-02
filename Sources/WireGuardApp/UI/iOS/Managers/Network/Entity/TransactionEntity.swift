// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation

class TransactionEntity: DefaultEntity {

    var state: String?

    enum CodingKeys: String, CodingKey {
        case state
    }

    required init(from decoder: any Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.state = try container.decodeIfPresent(String.self, forKey: .state)
    }
}
