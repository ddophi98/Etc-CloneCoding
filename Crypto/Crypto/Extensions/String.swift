//
//  String.swift
//  Crypto
//
//  Created by 김동락 on 2022/12/27.
//

import Foundation

extension String {
    var removingHTMLOcuurences: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
