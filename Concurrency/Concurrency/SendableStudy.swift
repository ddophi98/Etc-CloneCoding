//
//  SendableStudy.swift
//  Concurrency
//
//  Created by 김동락 on 2023/01/20.
//

import SwiftUI

actor CurrentUserManager {
    func updateDatabase(userInfo: MyClassUserInfo) {
        
    }
}

// struct는 값 타입이기 때문에 sendale 쓰나 안쓰나 똑같음
struct MyUserInfo: Sendable {
    var name: String
}

// sendable은 concurrent한 코드에 안전하게 사용될 수 있게 해줌
// 안전하지 않으면 경고 띄워줌 (캄파일러가 알게 해주는 용도)
// 경고 띄우기 싫으면 @unchecked 써주면 되지만 안쓰는게 좋음
final class MyClassUserInfo: Sendable {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

class SendableViewModel: ObservableObject {
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        
        let info = MyClassUserInfo(name: "info")
        
        await manager.updateDatabase(userInfo: info)
    }
}

struct SendableStudy: View {
    
    @StateObject private var viewModel = SendableViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .task {
                
            }
    }
}

struct SendableStudy_Previews: PreviewProvider {
    static var previews: some View {
        SendableStudy()
    }
}
