// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation

class DefaultEntity: Decodable {
    var result: Bool?
    var success: Bool?
    var message: String?
    var error: String?

    var isSuccess: Bool {
        return success == true
    }

    enum CodingKeys: CodingKey {
        case result
        case success
        case message
        case error
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.result = try container.decodeIfPresent(Bool.self, forKey: .result)
        self.success = try container.decodeIfPresent(Bool.self, forKey: .success)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.error = try container.decodeIfPresent(String.self, forKey: .error)
    }
}
