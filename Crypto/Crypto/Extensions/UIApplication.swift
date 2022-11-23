//
//  UIApplication.swift
//  Crypto
//
//  Created by 김동락 on 2022/11/23.
//

import Foundation
import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
