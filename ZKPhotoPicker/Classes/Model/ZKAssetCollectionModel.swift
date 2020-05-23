//
//  ZKAssetCollectionModel.swift
//  ZKPhotoPickerDemo
//
//  Created by CallMeDoby on 2020/5/23.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos

class ZKAssetCollectionModel: NSObject {
    
    let collection: PHAssetCollection
    let keyAsset: PHAsset?
    let assetCount: Int
    let title: String
    var defaultImage: UIImage {
        return self.picker.defaultImage
    }
    unowned let picker: ZKPhotoPicker
    
    
    init(collection: PHAssetCollection, picker: ZKPhotoPicker) {
        self.collection = collection
        self.picker = picker
        let res = PHAsset.fetchKeyAssets(in: collection, options: nil)
        self.keyAsset = res?.firstObject
        let assetsRes = PHAsset.fetchAssets(in: collection, options: nil)
        var count = 0
        assetsRes.enumerateObjects({
            asset, idx, isStop in
            if let shouldHide = picker.delegate?.photoPicker?(picker: picker, assetShouldHide: asset, in: collection) {
                if shouldHide {
                    return
                }
            }
            if asset.zkMediaType != picker.config.mediaType {
                return
            }
            count += 1
        })
        self.assetCount = count
        self.title = self.collection.assetCollectionSubtype == .smartAlbumUserLibrary ? "全部照片" : self.collection.localizedTitle ?? ""
    }
    
    func loadThumbImage(result: @escaping (UIImage?, ZKFetchImageFail?) -> Void) {
        self.picker.cachingImageManager.getThumbImage(for: self.keyAsset, result: result)
    }
    
}
