//
//  SingleSectionCharactersViewController.swift
//  CharactersGrid
//
//  Created by 김동락 on 2023/01/26.
//

import UIKit
import SwiftUI

class SingleSectionCharactersViewController: UIViewController {

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var characters = Universe.ff7r.stubs {
        didSet {
            // 데이터 바뀌면 알아서 reload 되게 하기
            // collectionView.reloadData()
            updateCollectionView(oldItems: oldValue, newItems: characters)
        }
    }
    let segmentedControl = UISegmentedControl(
        items: Universe.allCases.map{ $0.title }
    )
    
    // 기기 내에서 글자 크기 바꿀때 셀 사이즈 다시 맞춰줌
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupSegmentedControl()
        setupCollectionView()
        setupLayout()
    }
    
    // 업데이트할 때 애니메이션 나타나게 하기
    private func updateCollectionView(oldItems: [Character], newItems: [Character]) {
        collectionView.performBatchUpdates {
            let diff = newItems.difference(from: oldItems)
            diff.forEach { change in
                switch change {
                case let .remove(offset, _, _):
                    self.collectionView.deleteItems(at: [IndexPath(item: offset, section: 0)])
                case let .insert(offset, _, _):
                    self.collectionView.insertItems(at: [IndexPath(item: offset, section: 0)])
                }
            }
        } completion: { _ in
            let headerIndexPaths = self.collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader)
            headerIndexPaths.forEach { indexPath in
                let headerView = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) as! HeaderView
                headerView.setup(text: "Characters \(self.characters.count)")
            }
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    private func setupCollectionView() {
        collectionView.frame = view.bounds
        collectionView.backgroundColor = .systemBackground
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(CharacterCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        
        view.addSubview(collectionView)
    }
    
    private func setupLayout() {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {return}
        flowLayout.sectionInset = .init(top: 0, left: 8, bottom: 0, right: 8)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        // flowLayout.itemSize = .init(width: 120, height: 150)
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        // flowLayout.headerReferenceSize = .init(width: 0, height: 40)
    }

    private func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        navigationItem.titleView = segmentedControl
    }
    
    private func setupNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "shuffle"), style: .plain, target: self, action: #selector(shuffleTapped))
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        characters = sender.selectedUniverse.stubs
    }
    
    @objc func shuffleTapped() {
        characters.shuffle()
    }
}

extension SingleSectionCharactersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        characters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CharacterCell
        let character = characters[indexPath.item]
        cell.setup(character: character)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        headerView.setup(text: "Characters \(characters.count)")
        return headerView
    }
    
    /*
    // 이렇게 정의할 수도 있고 위에 setupLayout 함수처럼 정의할 수도 있음
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        <#code#>
    }
     */
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerView = HeaderView()
        headerView.setup(text: "Characters \(characters.count)")
        return headerView.systemLayoutSizeFitting(.init(width: collectionView.bounds.width, height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
}


struct SingleSectionCharactersViewControllerRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        UINavigationController(rootViewController: SingleSectionCharactersViewController())
    }
}

struct SingleSectionCharactersViewController_Previews: PreviewProvider {
    static var previews: some View {
        SingleSectionCharactersViewControllerRepresentable()
            .edgesIgnoringSafeArea(.top)
            // 글자 크기를 조정함
            .environment(\.sizeCategory, ContentSizeCategory.extraExtraExtraLarge)
    }
}
