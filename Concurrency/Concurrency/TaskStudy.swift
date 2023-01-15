//
//  TaskStudy.swift
//  Concurrency
//
//  Created by 김동락 on 2023/01/15.
//

import SwiftUI

class TaskStudyViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        
        /*
        for x in array {
            // 엄청 오래 걸리는 일
            // task를 cancel 해도 이 코드는 계속 돌아갈 수도 있음
            // 아래 코드를 명시적으로 써줘야함
            // try Task.checkCacellation()
        }
         */
        
        do {
            guard let url = URL(string: "https://picsum.photos/200") else {return}
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run(body: {
                self.image = UIImage(data: data)
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/200") else {return}
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run(body: {
                self.image2 = UIImage(data: data)
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TaskStudyHomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("CLICK ME! 😀") {
                    TaskStudy()
                }
            }
        }
    }
}


struct TaskStudy: View {
    
    @StateObject private var viewModel = TaskStudyViewModel()
    @State private var fetchImageTask: Task<(), Never>? = nil
    
    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            // 이런 방식으로도 task 정의 가능, view가 사라지면 자동으로 cancel도 해줌
            await viewModel.fetchImage()
        }
        .onDisappear {
            /*
            fetchImageTask?.cancel() // task 취소하기
             */
        }
        .onAppear {
            /*
            fetchImageTask = Task {
                await viewModel.fetchImage()
            }
            */
            
            /*
            // await랑 관계 없이 각 Task는 즉시 실행됨
            Task {
                await viewModel.fetchImage()
            }
            Task {
                await viewModel.fetchImage2()
            }
             */
            
            /*
            // 우선순위를 정해줄 수 있음
            Task(priority: .high) {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await Task.yield() // 다른 태스크를 기다림
                print("high: \(Task.currentPriority)")
            }
            Task(priority: .userInitiated) {
                print("userInitiated: \(Task.currentPriority)")
            }
            Task(priority: .medium) {
                print("medium: \(Task.currentPriority)")
            }
            Task(priority: .low) {
                print("low: \(Task.currentPriority)")
            }
            Task(priority: .utility) {
                print("utility: \(Task.currentPriority)")
            }
            Task(priority: .background) {
                print("background: \(Task.currentPriority)")
            }
             */
            
            /*
            Task(priority: .userInitiated) {
                print("userInitiated: \(Task.currentPriority)")
                Task.detached { // 부모로부터 분리시키지만 가능하면 쓰지 말아야 하는 문법
                    print("userInitiated: \(Task.currentPriority)")
                }
            }
             */
        }
    }
}

struct TaskStudy_Previews: PreviewProvider {
    static var previews: some View {
        TaskStudy()
    }
}
