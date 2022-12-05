//
//  DetailView.swift
//  Crypto
//
//  Created by 김동락 on 2022/12/04.
//

import SwiftUI

struct DetailLoadingView: View {
    @Binding var coin: CoinModel?
    
    var body: some View {
        ZStack {
            if let coin = coin {
                DetailView(coin: coin)
            }
        }
        
    }
}

struct DetailView: View {
    
    @StateObject var vm: DetailViewModel
    
    init(coin: CoinModel) {
        _vm = StateObject(wrappedValue: DetailViewModel(coin: coin))
        print("initializing detail view for \(coin.name)")
    }
    
    var body: some View {
        Text("Hello")
    }
    
    
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(coin: dev.coin)
    }
}
