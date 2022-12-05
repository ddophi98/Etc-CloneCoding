//
//  DetailViewModel.swift
//  Crypto
//
//  Created by 김동락 on 2022/12/05.
//

import Foundation
import Combine

class DetailViewModel: ObservableObject {
    private let coinDetailService: CoinDetailDataService
    private var cancellables = Set<AnyCancellable>()
    
    init(coin: CoinModel) {
        self.coinDetailService = CoinDetailDataService(coin: coin)
        self.addSubsribers()
    }
    
    private func addSubsribers() {
        coinDetailService.$coinDetails
            .sink { returnedCoinDetails in
                print("RECEIVED COIN DETAiL DATA")
                print(returnedCoinDetails)
            }
            .store(in: &cancellables)
    }
}
