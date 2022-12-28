//
//  SettingViews.swift
//  Crypto
//
//  Created by 김동락 on 2022/12/28.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    let defualtURL = URL(string: "https://www.google.com")!
    let youtubeURL = URL(string: "https://www.youtube.com")!
    let naverURL = URL(string: "https://www.naver.com")!
    
    
    var body: some View {
        NavigationView {
            List {
                swiftfulThinkingSection
                coinGekoSection
                applicationSection
            }
            .font(.headline)
            .accentColor(.blue)
            .listStyle(GroupedListStyle())
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    XMarkButton(presentationMode: _presentationMode)
                }
            }
        }
    }
}

struct SettingViews_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

extension SettingsView {
    private var swiftfulThinkingSection: some View {
        Section(header: Text("Swiftful Thinking")) {
            VStack(alignment: .leading) {
                Image("logo")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Text("This app was made by following a @SwiftfulThinking course on Youtube. It uses MVVM Architecture, Combine, and CoreData!")
            }
            .padding(.vertical)
            Link("Subscribe on Youtube 😀", destination: youtubeURL)
        }
    }
    
    private var coinGekoSection: some View {
        Section(header: Text("CoinGecko")) {
            VStack(alignment: .leading) {
                Image("coingecko")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Text("The cryptocurrency data that is used in this app comes from a free API from CoinGelo! Prices may be slightly delayed.")
            }
            .padding(.vertical)
            Link("Visit CoinGecko 😀", destination: youtubeURL)
        }
    }
    
    private var applicationSection: some View {
        Section(header: Text("Application")) {
            Link("Terms of Service", destination: defualtURL)
            Link("Privacy Policy", destination: defualtURL)
            Link("Company Website", destination: defualtURL)
            Link("Learn More", destination: defualtURL)
        }
    }
}
