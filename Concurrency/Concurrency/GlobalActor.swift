//
//  globalActor.swift
//  Concurrency
//
//  Created by 김동락 on 2023/01/19.
//

import SwiftUI

// struct든 class든 상관없음
// 싱글톤으로만 정의해주면됨
@globalActor struct MyFirstGlobalActor {
    static var shared = MyNewDataManager()
}

actor MyNewDataManager {
    func getDataFromDatabase() -> [String] {
        return ["One", "Two", "Three", "Four", "Five"]
    }
}

// 클래스 앞에도 globalActor 붙일 수 있음
class GlobalActorViewModel: ObservableObject {

    // 이 변수를 쓸 때 MainActor 안써주면 에러남
    @MainActor @Published var dataArray: [String] = []
    let manager = MyFirstGlobalActor.shared
    
    // 해당 함수가 정의한 actor에서 작동하도록 해줌
    // @MainActor -> 이것도 이미 만들어져있는 globalActor임
    @MyFirstGlobalActor
    func getData() {
        Task {
            let data = await manager.getDataFromDatabase()
            await MainActor.run(body: {
                self.dataArray = data
            })
        }
    }
}

struct GlobalActor: View {
    
    @StateObject private var viewModel = GlobalActorViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.getData()
        }
    }
}

struct GlobalActor_Previews: PreviewProvider {
    static var previews: some View {
        GlobalActor()
    }
}
