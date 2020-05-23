//
//  ZKPhotoCollectionFlowLayout.swift
//  ZKPhotoPicker
//
//  Created by Doby on 2020/5/9.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos

private let ZKPhotoCollectionItemWidth: CGFloat = 80
class ZKPhotoCollectionFlowLayout: UICollectionViewFlowLayout {
    
    var itemCount: Int = 0
    
    weak var delegate: ZKPhotoPickerDelegate?
    unowned let collectionModel: ZKAssetCollectionModel
    
    init(collectionModel: ZKAssetCollectionModel) {
        self.delegate = collectionModel.picker.delegate
        self.collectionModel = collectionModel
        super.init()
        self.minimumInteritemSpacing = 10
        self.minimumLineSpacing = 10
        self.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        self.itemSize = .init(width: ZKPhotoCollectionItemWidth, height: ZKPhotoCollectionItemWidth)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        
        if let collectionView = self.collectionView,
            let delegate = self.delegate {
            if let space = delegate.mininumColumnSpace?(in: collectionModel.collection) {
                self.minimumInteritemSpacing = space
            }
            if let space = delegate.mininumLineSpacing?(in: collectionModel.collection) {
                self.minimumLineSpacing = space
            }
            if let insets = delegate.sectionInset?(in: collectionModel.collection) {
                self.sectionInset = insets
            }
            var itemWidth: Int = Int(ZKPhotoCollectionItemWidth)
            let sectionInsets = self.sectionInset
            let columnSpacing = self.minimumInteritemSpacing
            let columnCount = Int((collectionView.bounds.width - sectionInsets.left - sectionInsets.right + columnSpacing) / (CGFloat(itemWidth) + columnSpacing))
            itemWidth = Int((collectionView.bounds.width - sectionInsets.left - sectionInsets.right + columnSpacing) / CGFloat(columnCount) - columnSpacing)
            self.itemSize = .init(width: itemWidth, height: itemWidth)
            
            let rowCount = Int(ceil(Double(self.itemCount) / Double(columnCount)))
            let contentHeight = self.sectionInset.top + CGFloat(rowCount) * (self.itemSize.height + self.minimumLineSpacing) - self.minimumLineSpacing + self.sectionInset.bottom
            var offset = contentHeight - collectionView.bounds.height
            offset = max(offset, 0)
            collectionView.contentOffset = .init(x: 0, y: offset)
            
        }
        
        
    }
    
}
