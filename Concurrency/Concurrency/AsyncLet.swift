//
//  AsyncLet.swift
//  Concurrency
//
//  Created by 김동락 on 2023/01/15.
//

import SwiftUI

struct AsyncLet: View {
    
    @State private var images: [UIImage] = []
    let columes = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/300")!
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columes) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Async Let Study")
            .onAppear {
                /*
                // 차례대로 기다리면서 실행함 -> 모든 비동기 처리를 동시에 하고 싶으면?
                Task {
                    do {
                        let image1 = try await fetchImage()
                        self.images.append(image1)
                        
                        let image2 = try await fetchImage()
                        self.images.append(image2)
                        
                        let image3 = try await fetchImage()
                        self.images.append(image3)
                        
                        let image4 = try await fetchImage()
                        self.images.append(image4)
                    } catch { }
                }
                 */
                Task {
                    do {
                        // async let 으로 함수를 정의하고, await로 묶기
                        async let fetchImage1 = fetchImage()
                        async let fetchImage2 = fetchImage()
                        async let fetchImage3 = fetchImage()
                        async let fetchImage4 = fetchImage()
                        
                        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
                        self.images.append(contentsOf: [image1, image2, image3, image4])
                    } catch { }
                }
            }
        }
    }
    
    func fetchImage() async throws -> UIImage {
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

struct AsyncLet_Previews: PreviewProvider {
    static var previews: some View {
        AsyncLet()
    }
}
