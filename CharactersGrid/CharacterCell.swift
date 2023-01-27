//
//  CharacterCell.swift
//  CharactersGrid
//
//  Created by 김동락 on 2023/01/25.
//

import UIKit
import SwiftUI

class CharacterCell: UICollectionViewCell {
    
    let imageView = RoundedImageView()
    let textLabel = UILabel()
    let vStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Xib/storyboard is not supported")
    }
    
    // self-sizing과 관련있는 코드
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        let padding: CGFloat = 8
        let noOfItems = traitCollection.horizontalSizeClass == .compact ? 4 : 8
        let itemWidth = floor((UIScreen.main.bounds.width - (padding*2)) / CGFloat(noOfItems))
        return super.systemLayoutSizeFitting(.init(width: itemWidth, height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
    
    private func setupLayout() {
        imageView.contentMode = .scaleAspectFit
        
        textLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        textLabel.adjustsFontForContentSizeCategory = true
        textLabel.textAlignment = .center
        
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.spacing = 8
        
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(vStack)
        vStack.addArrangedSubview(imageView)
        vStack.addArrangedSubview(textLabel)
        
        // NSLayoutConstraint 오류 고치기 위함
        let imageHeightConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        imageHeightConstraint.priority = .init(999)
        
        NSLayoutConstraint.activate([
            
            /*
            // isActive = true로 써도 되고
            // NSLayoutConstraint.activate 안에 넣어도 됨
            vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
             */
            
            vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            vStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageHeightConstraint
        ])
    }
    
    func setup(character: Character) {
        textLabel.text = character.name
        imageView.image = UIImage(named: character.imageName)
    }
}

// 모서리가 둥근 이미지뷰 클래스 생성
class RoundedImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        clipsToBounds = true
        layer.cornerRadius = bounds.width / 2
    }
}


// UIKit 코드를 SwiftUI처럼 쓸 수 있도록 하는 프로토콜
struct CharacterCellViewRepresentable: UIViewRepresentable {
    
    let character: Character
    
    func updateUIView(_ uiView: CharacterCell, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> CharacterCell {
        let cell = CharacterCell()
        cell.setup(character: character)
        return cell
    }
}

struct CharacterCell_Previews: PreviewProvider {
    static var previews: some View {
        
        // 여러 프리뷰 화면 띄우기 가능
        Group {
            CharacterCellViewRepresentable(character: Universe.ff7r.stubs[0])
                .frame(width: 120, height: 150)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]) {
                    ForEach(Universe.ff7r.stubs) {
                        CharacterCellViewRepresentable(character: $0)
                            .frame(width: 120, height: 150)
                    }
                }
            }
        }
        
    }
}
