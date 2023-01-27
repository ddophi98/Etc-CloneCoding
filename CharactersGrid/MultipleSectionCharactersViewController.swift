//
//  MultipleSectionCharactersViewController.swift
//  CharactersGrid
//
//  Created by 김동락 on 2023/01/27.
//

import UIKit
import SwiftUI

class MultipleSectionCharactersViewController: UIViewController {

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var sectionedStubs = Universe.ff7r.sectionedStubs {
        didSet {
            updateCollectionView(oldSectionItems: oldValue, newSectionItems: sectionedStubs)
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
    private func updateCollectionView(oldSectionItems: [SectionCharacters], newSectionItems: [SectionCharacters]) {
        var sectionsToInsert = IndexSet()
        var sectionsToRemove = IndexSet()
        
        var indexPathsToInsert = [IndexPath]()
        var indexPathsToDelete = [IndexPath]()
        
        let sectionDiff = newSectionItems.difference(from: oldSectionItems)
        
        sectionDiff.forEach { change in
            switch change {
            case let .remove(offset, _, _):
                sectionsToRemove.insert(offset)
            case let .insert(offset, _, _):
                sectionsToInsert.insert(offset)
            }
        }
        
        (0..<newSectionItems.count).forEach { index in
            let newsectionCharacter = newSectionItems[index]
            if let oldSectionIndex = oldSectionItems.firstIndex(of: newsectionCharacter) {
                let oldSectionCharacter = oldSectionItems[oldSectionIndex]
                let diff = newsectionCharacter.characters.difference(from: oldSectionCharacter.characters)
                
                diff.forEach { change in
                    switch change {
                    case let .remove(offset, _, _):
                        indexPathsToDelete.append(IndexPath(item: offset, section: oldSectionIndex))
                    case let .insert(offset, _, _):
                        indexPathsToInsert.append(IndexPath(item: offset, section: index))
                    }
                }
            }
        }
        
        collectionView.performBatchUpdates {
            self.collectionView.deleteSections(sectionsToRemove)
            self.collectionView.deleteItems(at: indexPathsToDelete)
            
            self.collectionView.insertSections(sectionsToInsert)
            self.collectionView.insertItems(at: indexPathsToInsert)
        } completion: { _ in
            let headerIndexPaths = self.collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader)
            headerIndexPaths.forEach { indexPath in
                let headerView = self.collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) as! HeaderView
                let section = self.sectionedStubs[indexPath.section]
                headerView.setup(text: "\(section.category) \(section.characters.count)".uppercased())
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
        sectionedStubs = sender.selectedUniverse.sectionedStubs
    }
    
    @objc func shuffleTapped() {
        sectionedStubs = sectionedStubs.shuffled().map{
            SectionCharacters(category: $0.category, characters: $0.characters.shuffled())
        }
    }
}

extension MultipleSectionCharactersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionedStubs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sectionedStubs[section].characters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CharacterCell
        let character = sectionedStubs[indexPath.section].characters[indexPath.item]
        cell.setup(character: character)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        let section = sectionedStubs[indexPath.section]
        headerView.setup(text: "\(section.category) \(section.characters.count)".uppercased())
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let headerView = HeaderView()
        let section = sectionedStubs[section]
        headerView.setup(text: "\(section.category) \(section.characters.count))".uppercased())
        return headerView.systemLayoutSizeFitting(.init(width: collectionView.bounds.width, height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
}


struct MultipleSectionCharactersViewControllerRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        UINavigationController(rootViewController: MultipleSectionCharactersViewController())
    }
}

struct MultipleSectionCharactersViewController_Previews: PreviewProvider {
    static var previews: some View {
        MultipleSectionCharactersViewControllerRepresentable()
            .edgesIgnoringSafeArea(.top)
            // 글자 크기를 조정함
            .environment(\.sizeCategory, ContentSizeCategory.extraExtraExtraLarge)
    }
}
