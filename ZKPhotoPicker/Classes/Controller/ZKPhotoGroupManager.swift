//
//  ZKPhotoGroupManager.swift
//  ZKPhotoPicker
//
//  Created by Doby on 2020/5/8.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos

class ZKPhotoGroupManager: NSObject {
    
    var collections: [ZKPhotoCollectionManager] = []
    
    override init() {
        super.init()
        if let currentPicker = ZKPhotoPicker.current {
            let allPhotoCollectionResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
            allPhotoCollectionResult.enumerateObjects { (collection, idx, isStop) in
                self.collections.append(.init(collection: collection))
            }
            
            let nomalCollectionResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            nomalCollectionResult.enumerateObjects { (collection, idx, isStop) in
                if let shouldHide = currentPicker.delegate?.photoPicker?(picker: currentPicker, groupCollectionShouldHide: collection), shouldHide {
                    return
                }
                let mn = ZKPhotoCollectionManager.init(collection: collection)
                if mn.itemCount > 0 {
                    self.collections.append(mn)
                }
                
            }
        }
    }
    
    /// 开始缓存collection的keyThumb图片，不用取消，dealloc的时候取消全部缓存
    func startCachingCollectionKeyThumbImages() {
        if let picker = ZKPhotoPicker.current {
            picker.cachingImageManager.startCachingThumbImage(for: self.collections.map{$0.keyAsset}.compactMap{$0})
        }
    }
    
}
