//
//  AsyncAwait.swift
//  Concurrency
//
//  Created by 김동락 on 2023/01/13.
//

import SwiftUI

class AsyncAwaitViewModel: ObservableObject {
    @Published var dataArray: [String] = []
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.dataArray.append("Title1 : \(Thread.current)")
        }
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now()+2) {
            let title = "Title2 : \(Thread.current)"
            DispatchQueue.main.async {
                self.dataArray.append(title)
                
                let title3 = "Title3 : \(Thread.current)"
                self.dataArray.append(title3)
            }
        }
    }
    
    func addAuthor1() async {
        let author1 = "Author1 : \(Thread.current)" // ? 쓰레드에서 동작 (랜덤)
        self.dataArray.append(author1)
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let author2 = "Author2 : \(Thread.current)" // ? 쓰레드에서 동작 (랜덤)
        await MainActor.run(body: {
            self.dataArray.append(author2)
            
            let author3 = "Author3 : \(Thread.current)" // 메인 쓰레드에서 동작 (무조건)
            self.dataArray.append(author3)
        })
        
        await addSomething()
    }
    
    func addSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let somethig1 = "Somethig1 : \(Thread.current)" // ? 쓰레드에서 동작 (랜덤)
        await MainActor.run(body: {
            self.dataArray.append(somethig1)
            
            let somethig2 = "Somethig2 : \(Thread.current)" // 메인 쓰레드에서 동작 (무조건)
            self.dataArray.append(somethig2)
        })
    }
}

struct AsyncAwait: View {
    @StateObject private var viewModel = AsyncAwaitViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear{
//            viewModel.addTitle1()
//            viewModel.addTitle2()
            Task {
                await viewModel.addAuthor1()
                
                let finalText = "FINAL TEXT : \(Thread.current)"
                viewModel.dataArray.append(finalText)
            }
        }
    }
}

struct AsyncAwait_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwait()
    }
}
