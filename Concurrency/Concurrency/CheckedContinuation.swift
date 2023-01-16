//
//  CheckedContinuation.swift
//  Concurrency
//
//  Created by 김동락 on 2023/01/16.
//

import SwiftUI

class CheckedContinuationNetworkManager {
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            throw error
        }
    }
    
    func getData2(url: URL) async throws -> Data {
        // 일반적인 함수를 async 함수로 바꿔서 await가 사용 가능하도록 함
        return try await withCheckedThrowingContinuation { continuation in
            // 비동기 처리 중에는 async로 구현된게 없고 completion handler로 되어있는게 있을 수 있음
            URLSession.shared.dataTask(with: url) { data, response, error in
                // wait -> continue 상태로 변경 가능함
                // continuation은 딱 한번만 실행되야함
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        }
        
    }
    
    // completion handler를 썼을 경우
    func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            completionHandler(UIImage(systemName: "heart.fill")!)
        }
    }
    
    // continuation을 썼을 경우 (async await)
    func getHeartImageFromDatabase() async -> UIImage {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                continuation.resume(returning: UIImage(systemName: "heart.fill")!)
            }
        }
    }
}


class CheckedContinuationViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    let networkManager = CheckedContinuationNetworkManager()
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/300") else {return}
        do {
            let data = try await networkManager.getData2(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run(body: {
                    self.image = image
                })
            }
        } catch {
            print(error)
        }
    }
    
    func getHeartImage() async {
        self.image = await networkManager.getHeartImageFromDatabase()
    }
}

struct CheckedContinuation: View {
    
    @StateObject private var viewModel = CheckedContinuationViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await viewModel.getHeartImage()
        }
    }
}

struct CheckedContinuation_Previews: PreviewProvider {
    static var previews: some View {
        CheckedContinuation()
    }
}
