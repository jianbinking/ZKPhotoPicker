//
//  ZKPhotoAssetManager.swift
//  ZKPhotoPicker
//
//  Created by Doby on 2020/5/11.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos
class ZKPhotoAssetManager: NSObject {
    
    let assetModel: ZKAssetModel
    var picker: ZKPhotoPicker {
        return self.assetModel.picker
    }
    
    init(model: ZKAssetModel) {
        self.assetModel = model
        super.init()
        
    }
    
    func loadImage(result: @escaping (UIImage?, ZKFetchImageFail?) -> Void) {
        self.assetModel.asset.zkFetchImage(targetSize: PHImageManagerMaximumSize, contentMode: .default, deliveryMode: .highQualityFormat, completeHandle: result)
    }
    func loadLivePhoto(result: @escaping (PHLivePhoto?, ZKFetchImageFail?) -> Void) {
        
        let opt = PHLivePhotoRequestOptions()
        opt.version = .current
        opt.deliveryMode = .highQualityFormat
        opt.isNetworkAccessAllowed = true
        opt.progressHandler = nil
        
        PHImageManager.default().requestLivePhoto(for: self.assetModel.asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: opt, resultHandler: {
            livePhoto, info in
            if let err = info?[PHImageErrorKey] as? Error {
                result(nil, .systemError(err))
            }
            else if let canceled = info?[PHImageCancelledKey] as? Bool, canceled {
                result(nil, .canceled)
            }
            else if let livePhoto = livePhoto {
                result(livePhoto, nil)
            }
            else {
                result(nil, .unknownErr)
            }
        })
    }
    
    func loadPlayerItem(result: @escaping (AVPlayerItem?, ZKFetchImageFail?) -> Void) {
        let opt = PHVideoRequestOptions.init()
        opt.isNetworkAccessAllowed = true
        opt.version = .current
        opt.deliveryMode = .highQualityFormat
        opt.progressHandler = nil
        PHImageManager.default().requestPlayerItem(forVideo: self.assetModel.asset, options: opt, resultHandler: {
            item, info in
            if let err = info?[PHImageErrorKey] as? Error {
                result(nil, .systemError(err))
            }
            else if let canceled = info?[PHImageCancelledKey] as? Bool, canceled {
                result(nil, .canceled)
            }
            else if let item = item {
                result(item, nil)
            }
            else {
                result(nil, .unknownErr)
            }
        })
    }
}
