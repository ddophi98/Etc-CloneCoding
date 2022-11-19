//
//  TodoListApp.swift
//  TodoList
//
//  Created by 김동락 on 2022/11/19.
//

import SwiftUI

@main
struct TodoListApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ListView()
            }
        }
    }
}
