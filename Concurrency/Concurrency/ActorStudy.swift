//
//  ActorStudy.swift
//  Concurrency
//
//  Created by 김동락 on 2023/01/19.
//

import SwiftUI

class MyDataManager {
    static let instance = MyDataManager()
    var data: [String] = []
    private let lock = DispatchQueue(label: "com.MyApp.MyDataManager")
    
    private init() { }
    
    func getRandomData(completionHandler: @escaping (_ title: String?) -> ()) {
        // thread-safe 하게 만들어줌 (다른게 들어오면 큐에서 기다림)
        lock.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            
            completionHandler(self.data.randomElement())
        }
    }
}

// 자동으로 thread-safe 하게 만들어주면서 코드가 더 간단함
actor MyActorDataManager {
    static let instance = MyActorDataManager()
    var data: [String] = []
    nonisolated let myText = "TEXT"
    
    private init() { }
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return self.data.randomElement()
    }
    
    // nonisolated - actor 안에 있더라도 await할 필요없다고 알려줌
    nonisolated func getSavedData() -> String {
        return "NEW DATA"
    }
}


struct HomeView: View {
    
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea()
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            DispatchQueue.global(qos: .background).async {
                
                // 다른 쓰레드에서 똑같은 액터에 접근함
                Task {
                    if let data = await manager.getRandomData() {
                        await MainActor.run(body: {
                            self.text = data
                        })
                    }
                }
                
                // 다른 쓰레드에서 똑같은 클래스에 접근함
                /*
                manager.getRandomData { title in
                    if let data = title {
                        DispatchQueue.main.async {
                            self.text = data
                        }
                       
                    }
                }
                */
                
                /*
                if let data = manager.getRandomData() {
                    DispatchQueue.main.async {
                        self.text = data
                    }
                   
                }
                 */
            }
        }
    }
}

struct BrowseView: View {
    
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            DispatchQueue.global(qos: .default).async {
                
                // 다른 쓰레드에서 똑같은 액터에 접근함
                Task {
                    if let data = await manager.getRandomData() {
                        await MainActor.run(body: {
                            self.text = data
                        })
                    }
                }
                
                // 다른 쓰레드에서 똑같은 클래스에 접근함
                /*
                manager.getRandomData { title in
                    if let data = title {
                        DispatchQueue.main.async {
                            self.text = data
                        }
                       
                    }
                }
                */
                
                /*
                if let data = manager.getRandomData() {
                    DispatchQueue.main.async {
                        self.text = data
                    }
                }
                 */
            }
        }
    }
}

struct ActorStudy: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

struct ActorStudy_Previews: PreviewProvider {
    static var previews: some View {
        ActorStudy()
    }
}
