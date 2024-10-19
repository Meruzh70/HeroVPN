// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation

class Info: Decodable {
    var id: String?
    var textEn: String?
    var textRu: String?
    var name: String?
    var alias: String?
    var date: String?

    enum CodingKeys: CodingKey {
        case id,
             textEn,
             textRu,
             name,
             alias,
             date
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.textEn = try container.decodeIfPresent(String.self, forKey: .textEn)
        self.textRu = try container.decodeIfPresent(String.self, forKey: .textRu)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.alias = try container.decodeIfPresent(String.self, forKey: .alias)
        self.date = try container.decodeIfPresent(String.self, forKey: .date)
    }
}

class InfoEntity: DefaultEntity {

    var page: Info?

    enum CodingKeys: String, CodingKey {
        case page
    }

    required init(from decoder: any Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page = try container.decodeIfPresent(Info.self, forKey: .page)
    }
}
