//
//  AsyncPublishStudy.swift
//  Concurrency
//
//  Created by 김동락 on 2023/01/20.
//

import SwiftUI
import Combine

class AsyncPublishDataManager {
    @Published var myData: [String] = []
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Watermelon")
    }
}

class AsyncPublishStudyViewModel: ObservableObject {
    @MainActor @Published var dataArray: [String] = []
    let manager = AsyncPublishDataManager()
    var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        
        // Combine 안쓰고 Published 값 받아서 처리하는 방법 (AsyncPublisher)
        Task {
            // 기존 for문이 아니라, 비동기 처리가 다 끝나길 기다리는 for문임
            for await value in manager.$myData.values {
                // 비동기 처리 다 끝나면 이 구문 실행됨
                await MainActor.run(body: {
                    self.dataArray = value
                })
            }
        }
        
        /*
        // 기존에 Published 값 받아서 처리하는 방법 (Combine)
        manager.$myData
            .receive(on: DispatchQueue.main)
            .sink { dataArray in
                self.dataArray = dataArray
            }
            .store(in: &cancellables)
        */
    }
    
    func start() async {
        await manager.addData()
    }
}


struct AsyncPublishStudy: View {
    
    @StateObject private var viewModel = AsyncPublishStudyViewModel()
    
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
            await viewModel.start()
        }
    }
}

struct AsyncPublishStudy_Previews: PreviewProvider {
    static var previews: some View {
        AsyncPublishStudy()
    }
}
