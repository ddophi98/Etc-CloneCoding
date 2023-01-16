//
//  TaskGroupStudy.swift
//  Concurrency
//
//  Created by 김동락 on 2023/01/16.
//

import SwiftUI

class TaskGroupStudyDataManager {
    
    func fetchImageWithAsyncLet() async throws -> [UIImage] {
        async let fetchImage1 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage2 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage3 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage4 = fetchImage(urlString: "https://picsum.photos/300")
        
        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
        return [image1, image2, image3, image4]
    }
    
    func fetchImageWithTaskGroup() async throws -> [UIImage] {
        let urlStrings = [
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300",
            "https://picsum.photos/300"
        ]
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images: [UIImage] = []
            // 약간의 성능향상을 위해 미리 메모리 공간 확보하기
            images.reserveCapacity(urlStrings.count)
            
            for urlString in urlStrings {
                group.addTask {
                    /*
                    // 실패하면 나머지 비동기 처리도 끊김
                    try await self.fetchImage(urlString: urlString)
                     */
                    
                    // 실패해도 그 비동기 처리만 nil 반환함
                    try? await self.fetchImage(urlString: urlString)
                }
            }
            
            // 일반적인 for문은 아님
            // 모든 task가 끝날때까지 기다림
            for try await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            
            
            return images
        }
    }
    
    private func fetchImage(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
}

class TaskGroupStudyViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    let manager = TaskGroupStudyDataManager()
    
    func getImages() async {
        if let images = try? await manager.fetchImageWithTaskGroup() {
            self.images.append(contentsOf: images)
        }
    }
}


struct TaskGroupStudy: View {
    
    @StateObject private var viewModel = TaskGroupStudyViewModel()
    let columes = [GridItem(.flexible()), GridItem(.flexible())]
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columes) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Task Group")
            .task {
                await viewModel.getImages()
            }
        }
    }
}

struct TaskGroupStudy_Previews: PreviewProvider {
    static var previews: some View {
        TaskGroupStudy()
    }
}
