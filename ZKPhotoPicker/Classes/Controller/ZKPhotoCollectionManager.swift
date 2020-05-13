//
//  ZKPhotoCollectionManager.swift
//  ZKPhotoPicker
//
//  Created by Doby on 2020/5/9.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos

class ZKPhotoCollectionManager: NSObject {
    
    let collection: PHAssetCollection
    
    public private(set) var assetsManagers: [ZKPhotoAssetManager] = []
    
    init(collection : PHAssetCollection) {
        self.collection = collection
        super.init()
        if let currentPicker = ZKPhotoPicker.current {
            let res = PHAsset.fetchAssets(in: collection, options: nil)
            res.enumerateObjects { (asset, idx, isStop) in
                if let shouldHide = currentPicker.delegate?.photoPicker?(picker: currentPicker, assetShouldHide: asset, in: collection) {
                    if shouldHide {
                        return
                    }
                }
                if asset.zkMediaType != currentPicker.config.mediaType {
                    return
                }
                self.assetsManagers.append(.init(asset))
            }
        }
        
    }
    
    func startCachingThumbImage() {
        print("开始缓存\(collection.localizedTitle ?? "")")
        if let picker = ZKPhotoPicker.current {
            picker.cachingImageManager.startCachingThumbImage(for: self.assetsManagers.map{$0.asset})
        }
    }
    
    func stopCachingThumbImage() {
        print("停止缓存\(collection.localizedTitle ?? "")")
        if let picker = ZKPhotoPicker.current {
            picker.cachingImageManager.stopCachingThumbImage(for: self.assetsManagers.map{$0.asset})
        }
    }
    
    func requestKeyThumbImage(_ result: @escaping (UIImage?, ZKFetchImageFail?) -> Void) {
        if let picker = ZKPhotoPicker.current, let asset = self.keyAsset {
            picker.cachingImageManager.getThumbImage(for: asset, result: result)
        }
        else {
            result(nil, .nilAsset)
        }
    }
    

}

extension ZKPhotoCollectionManager {
    
    var itemCount: Int {
        return self.assetsManagers.count
    }
    var keyAsset: PHAsset? {
        let res = PHAsset.fetchKeyAssets(in: self.collection, options: nil)
        return res?.firstObject
    }
    
    var desc: String {
        return self.collection.assetCollectionSubtype == .smartAlbumUserLibrary ? "全部照片" : self.collection.localizedTitle ?? ""
    }
}
