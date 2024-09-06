// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation

struct AuthEntity {
    var result: Bool
    var success: Bool
    var token: String?
    var name: String?

}

/*
{
    "result": true,
    "success": true,
    "token": "358lqjfghfrp9qqmo8gv",
    "name": "alex",
    "servers": [
        {
            "id": "66ce9b1a10a3ba8ea9882ffa",
            "name": "VPNHERO-I",
            "ip": "195.250.79.91"
        },
        {
            "id": "66ce9de910a3ba8ea9883237",
            "name": "VPNHERO-II",
            "ip": "195.250.79.92"
        }
    ]
}
*/
