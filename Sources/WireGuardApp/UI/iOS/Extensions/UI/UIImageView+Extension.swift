// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

extension UIImageView {
    func setFromGif(resourceName: String) {
        guard let path = Bundle.main.path(forResource: resourceName, ofType: "gif") else {
            print("Gif does not exist at that path")
            self.image = nil
            return
        }
        let url = URL(fileURLWithPath: path)
        guard let gifData = try? Data(contentsOf: url), let source =  CGImageSourceCreateWithData(gifData as CFData, nil) else {

            return
        }
        var images = [UIImage]()
        let imageCount = CGImageSourceGetCount(source)
        for i in 0 ..< imageCount {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: image))
            }
        }
        self.animationImages = images
    }
}
