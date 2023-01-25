//
//  HeaderView.swift
//  CharactersGrid
//
//  Created by 김동락 on 2023/01/25.
//

import UIKit
import SwiftUI

class HeaderView: UICollectionReusableView {
        private let textLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("/Xib/storyboard is not supported")
    }
    
    private func setupLayout() {
        textLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        textLabel.adjustsFontForContentSizeCategory = true
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        
        ])
    }
    
    func setup(text: String) {
        textLabel.text = text
    }
}

struct HeaderViewRepresentable: UIViewRepresentable {
    
    let text: String
    
    func updateUIView(_ uiView: UIViewType, context: Context) {

    }
    
    func makeUIView(context: Context) -> some UIView {
        let headerView = HeaderView()
        headerView.setup(text: text)
        return headerView
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderViewRepresentable(text: "Heroes")
    }
}
