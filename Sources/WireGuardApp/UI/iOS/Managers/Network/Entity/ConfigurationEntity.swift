// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import SwiftyJSON

class Configuration {
    var defaultContainer: String
    var description: String
    var dns1: String
    var dns2: String

    var h1: String
    var h2: String
    var h3: String
    var h4: String
    var jc: String
    var jMax: String
    var jMin: String
    var s1: String
    var s2: String
    var clientIp: String
    var clientPrivateKey: String
    var clientPublicKey: String
    var address: String
    var port: String
    var allowedIps: String
    var endPoint: String
    var pskKey: String
    var serverPubKey: String
    var keepALive: String

    init() {
        self.defaultContainer = ""
        self.description = ""
        self.dns1 = ""
        self.dns2 = ""

        self.h1 = ""
        self.h2 = ""
        self.h3 = ""
        self.h4 = ""
        self.jc = ""
        self.jMax = ""
        self.jMin = ""
        self.s1 = ""
        self.s2 = ""
        self.clientIp = ""
        self.clientPrivateKey = ""
        self.clientPublicKey = ""
        self.address = ""
        self.port = ""
        self.allowedIps = ""
        self.endPoint = ""
        self.pskKey = ""
        self.serverPubKey = ""
        self.keepALive = ""
    }

    init(fromJson: JSON? = nil) {
        self.defaultContainer = "amnezia-awg"
        self.description = "VPNHERO-I - alex-agildin@mail.ru"
        self.dns1 = "1.1.1.1"
        self.dns2 = "1.0.0.1"

        self.h1 = "919577948"
        self.h2 = "1898989476"
        self.h3 = "815569457"
        self.h4 = "409674097"
        self.jc = "3"
        self.jMax = "1000"
        self.jMin = "50"
        self.s1 = "29"
        self.s2 = "73"
        self.clientIp = "10.8.0.9"
        self.clientPrivateKey = "UO63lSoHN972v/O/aJDmYRPqcBGZhLXQTvj/P1FAtHk="
        self.clientPublicKey = "Fbcco4unCg7nXLDLUqo2AiTc1RSzhMTpIxTfOmfRwGo="
        self.address = "10.8.0.9/32"
        self.port = "45820"
        self.allowedIps = "0.0.0.0/0"
        self.endPoint = "195.250.79.91:45820"
        self.pskKey = "n4mxnVbnk18+kwW1VA4PJwbShIPjCZIWCJ+qBo5nGQ8="
        self.serverPubKey = "uy6ezhihko9/XyI2Ir7xP8UNxWBImWuWqWBTVAcQISw="
        self.keepALive = "25"
    }

}



//{
//    "config": "vpn://AAAHBXiclZRtb5swEMe_inXau6UJEAgBCWlp0hXSLqEhbbrVU-SA03gBkwJ5aKt-9-lM23Qv9qKyhO5-9p3_d5z8DHEuKyYkL0pw756PLrjAMsmfBDth-3toAH7dZ_B1cMHRHcu2HbMLDfANcEHvOrhMu4OkDS50dcvqOKZlIzDBBVNzOrapOQiGMbjQRiNjBwzXNE15QoILFtoR3mM4aOEFNp5OWVnN41wuxT248EzB1ym49CiHQoOCbyh4lFTTtqLvsmpoKvguTcFhrGC7djJ2qNNpmvZKhFTEqv2o1mA4tVdfbtfRcSq4rOZi85qi2W1qTefj1qYQu_maP6oD1-NOO41yf-TYxq41brHhIPs5CR_i0_Nfq8vbq-nuTyvUv_cqf-39k2S7eM_xfRHHubmV_Xtb3l4OLq8fcqMnprE-iZ5WP6ab4DBdjrPlZH-ev-ZQ_VSxd4GseLFkMf9NqewlScHLknjkTXirbVAqB6OIeORLOAl-9CY_54NR1CBforP-eDR49SmVYSF2rOIX_JF45FN1UTmMiUfaaGRCEo9YmrLZQUnR0It04hHDQcsgHrHxtI_sOApU-rj1YQyo9NvEI8cRoNI3iUeOv59KSuVdyHmBDQi3i1TEdQnbxw5_WonVOndat4-BERT2Iexejw6z0yCbbWcPs9PpTS--CqK9p8rn5YoVPKmjpZkd5M1CrvXu1_V-pt_0zHC4X0SrIPzT_xXM-sOvD6e5Jc-vuhjdS9N8z5MgxOZrTbVaWoO4bguLP5PJJheywuocq2lYWtN2mo7umlbXwAMhL0pRVlxWF5xvWCp2HNtlYX34y1d5WY1Yxuup_JhCbW_yoqJQZ0O3XL9P16cKwVwlL3a8-GdCP9VKeIGGEvSmB6qCyRLJfFPkVQ4ubJMNvLz8bkDCl2ybVv3_vmEJL-NCbCqR4ztzE478s8n4JCAnhKX8cMLuRZoI-S1jIm0WWwyQJb5DelOtGqj3Tv0UBG-9RPixk_DyF4KYknw",
//    "decoded": {
//        "containers": [
//            {
//                "container": "amnezia-awg",
//                "awg": {
//                    "H1": "919577948",
//                    "H2": "1898989476",
//                    "H3": "815569457",
//                    "H4": "409674097",
//                    "Jc": "3",
//                    "Jmax": "1000",
//                    "Jmin": "50",
//                    "S1": "29",
//                    "S2": "73",
//                    "last_config": "{\"H1\":\"919577948\",\"H2\":\"1898989476\",\"H3\":\"815569457\",\"H4\":\"409674097\",\"Jc\":\"3\",\"Jmax\":\"1000\",\"Jmin\":\"50\",\"S1\":\"29\",\"S2\":\"73\",\"client_ip\":\"10.8.0.9\",\"client_priv_key\":\"UO63lSoHN972v/O/aJDmYRPqcBGZhLXQTvj/P1FAtHk=\",\"client_pub_key\":\"Fbcco4unCg7nXLDLUqo2AiTc1RSzhMTpIxTfOmfRwGo=\",\"config\":\"[Interface]\\nAddress = 10.8.0.9/32\\nDNS = $PRIMARY_DNS, $SECONDARY_DNS\\nPrivateKey = UO63lSoHN972v/O/aJDmYRPqcBGZhLXQTvj/P1FAtHk=\\nJc = 3\\nJmin = 50\\nJmax = 1000\\nS1 = 29\\nS2 = 73\\nH1 = 919577948\\nH2 = 1898989476\\nH3 = 815569457\\nH4 = 409674097\\n\\n[Peer]\\nPublicKey = uy6ezhihko9/XyI2Ir7xP8UNxWBImWuWqWBTVAcQISw=\\nPresharedKey = n4mxnVbnk18+kwW1VA4PJwbShIPjCZIWCJ+qBo5nGQ8=\\nAllowedIPs = 0.0.0.0/0, ::/0\\nEndpoint = 195.250.79.91:45820\\nPersistentKeepalive = 25\\n\",\"hostName\":\"195.250.79.91\",\"port\":45820,\"psk_key\":\"n4mxnVbnk18+kwW1VA4PJwbShIPjCZIWCJ+qBo5nGQ8=\",\"server_pub_key\":\"uy6ezhihko9/XyI2Ir7xP8UNxWBImWuWqWBTVAcQISw=\"}",
//                    "port": 45820,
//                    "transport_proto": "udp"
//                }
//            }
//        ],
//        "defaultContainer": "amnezia-awg",
//        "description": "VPNHERO-I - alex-agildin@mail.ru",
//        "dns1": "1.1.1.1",
//        "dns2": "1.0.0.1",
//        "hostName": "195.250.79.91"
//    }
//}
