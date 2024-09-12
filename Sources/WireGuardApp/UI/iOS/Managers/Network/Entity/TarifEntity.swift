// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation

class TarifEntity: Decodable {
    var result: [Tarif]

    enum CodingKeys: CodingKey {
        case result
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.result = try container.decode([Tarif].self, forKey: .result)
    }
}
