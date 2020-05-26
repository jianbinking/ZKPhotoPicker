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
    
    let collectionModel: ZKAssetCollectionModel
    var picker: ZKPhotoPicker? {
        return self.collectionModel.picker
    }
    var assetModels: [ZKAssetModel] = []
    
    init(model : ZKAssetCollectionModel) {
        self.collectionModel = model
        super.init()
        self.startCachingThumbImage()
    }
    
    deinit {
        print("ZKPhotoCollectionManager\(collectionModel.title)释放")
        self.stopCachingThumbImage()
    }
    
    private func startCachingThumbImage() {
        print("开始缓存\(collectionModel.title)")
        picker?.cachingImageManager.startCachingThumbImage(for: self.assetModels.map{$0.asset})
    }
    
    private func stopCachingThumbImage() {
        print("停止缓存\(collectionModel.title)")
        picker?.cachingImageManager.stopCachingThumbImage(for: self.assetModels.map{$0.asset})
    }
    
    func requestAssets(completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            let res = PHAsset.fetchAssets(in: self.collectionModel.collection, options: nil)
            res.enumerateObjects({
                asset, idx, isStop in
                if let picker = self.picker {
                    if let shouldHide = picker.delegate?.photoPicker?(picker: picker, assetShouldHide: asset, in: self.collectionModel.collection) {
                        if shouldHide {
                            return
                        }
                    }
                    if !picker.config.mediaType.contains(asset.zkMediaType) {
                        return
                    }
                    self.assetModels.append(.init(asset: asset, picker: picker))
                }
                
            })
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func requestKeyThumbImage(_ result: @escaping (UIImage?, ZKFetchImageFail?) -> Void) {
        if let asset = self.keyAsset {
            picker?.cachingImageManager.getThumbImage(for: asset, result: result)
        }
        else {
            result(nil, .nilAsset)
        }
    }
    

}

extension ZKPhotoCollectionManager {
    
    var assetCount: Int {
        return self.collectionModel.assetCount
    }
    var keyAsset: PHAsset? {
        return self.collectionModel.keyAsset
    }
    
    var title: String {
        return self.collectionModel.title
    }
}
