//
//  CryptoApp.swift
//  Crypto
//
//  Created by 김동락 on 2022/11/20.
//

import SwiftUI

@main
struct CryptoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .navigationBarHidden(true)
            }
        }
    }
}
