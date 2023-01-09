//
//  DoCatchTryThrows.swift
//  Concurrency
//
//  Created by 김동락 on 2023/01/09.
//

import SwiftUI

class DoCatchTryThrowsDataManager {
    
    let isActive: Bool = false
    
    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("NEW TEXT!", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }
    
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("NEW TEXT!")
        } else {
            return .failure(URLError(.badURL))
        }
    }
    
    func getTitle3() throws -> String {
        if isActive {
            return "NEW TEXT!"
        } else {
            throw URLError(.badURL)
        }
    }
    
    func getTitle4() throws -> String {
        if isActive {
            return "FINAL TEXT!"
        } else {
            throw URLError(.badURL)
        }
    }
}

class DoCatchTryThrowsViewModel: ObservableObject {
    @Published var text: String = "Starting text."
    let manager = DoCatchTryThrowsDataManager()
    
    func fetchTitle() {
//        let returnedValue = manager.getTitle()
//        if let newTitle = returnedValue.title {
//            self.text = newTitle
//        } else if let error = returnedValue.error {
//            self.text = error.localizedDescription
//        }
        
//        let result = manager.getTitle2()
//        switch result {
//        case .success(let newTitle):
//            self.text = newTitle
//        case .failure(let error):
//            self.text = error.localizedDescription
//        }
        
//        let newTitle = try? manager.getTitle3()
//        if let newTitle = newTitle {
//            self.text = newTitle
//        }
        
        do {
            let newTitle = try? manager.getTitle3() // 에러가 날 경우 nil 값, catch로 안빠짐
            if let newTitle = newTitle {
                self.text = newTitle
            }
            
            let finalTitle = try manager.getTitle4() // 에러가 날 경우 catch로 빠짐
            self.text = finalTitle
        } catch {
            self.text = error.localizedDescription // catch let error 해줘도 되고 빼도 됨
        }
    }
}

struct DoCatchTryThrows: View {
    @StateObject private var viewModels = DoCatchTryThrowsViewModel()
    
    var body: some View {
        Text(viewModels.text)
            .frame(width: 300, height: 300)
            .background(.blue)
            .onTapGesture {
                viewModels.fetchTitle()
            }
    }
}

struct DoCatchTryThrows_Previews: PreviewProvider {
    static var previews: some View {
        DoCatchTryThrows()
    }
}
