//
//  ZKPhotoCachingImageManager.swift
//  ZKPhotoPicker
//
//  Created by Doby on 2020/5/12.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos

class ZKPhotoCachingImageManager: NSObject {
    
    private let cacheManager = PHCachingImageManager.init()
    
    override init() {
        super.init()
        self.cacheManager.allowsCachingHighQualityImages = true
    }
    
    deinit {
        self.cacheManager.stopCachingImagesForAllAssets()
    }
    
    func startCachingThumbImage(for assets:[PHAsset]) {
        self.cacheManager.startCachingImages(for: assets, targetSize: kZKPhotoThumbNailSize, contentMode: .aspectFill, options: PHImageRequestOptions.zkThumbOption)
    }
    
    func stopCachingThumbImage(for assets:[PHAsset]) {
        self.cacheManager.stopCachingImages(for: assets, targetSize: kZKPhotoThumbNailSize, contentMode: .aspectFill, options: PHImageRequestOptions.zkThumbOption)
    }
    
    func getThumbImage(for asset: PHAsset?, result:@escaping (UIImage?, ZKFetchImageFail?) -> Void) {
        self.getThumbImage(for: asset, result: {
            image, info, error in
            result(image, error)
        })
    }
    
    func getThumbImage(for asset: PHAsset?, result:@escaping (UIImage?, [AnyHashable: Any]?, ZKFetchImageFail?) -> Void) {
        guard let asset = asset else {
            result(nil, nil, .nilAsset)
            return
        }
        self.cacheManager.requestImage(for: asset, targetSize: kZKPhotoThumbNailSize, contentMode: .aspectFill, options: PHImageRequestOptions.zkThumbOption, resultHandler: {
            img, info in
            autoreleasepool {
                if let err = info?[PHImageErrorKey] as? Error {
                    result(nil, info, .systemError(err))
                }
                else if let canceled = info?[PHImageCancelledKey] as? Bool, canceled {
                    result(nil, info, .canceled)
                }
                else if let image = img {
                    result(image, info, nil)
                }
                else {
                    result(nil, info, .unknownErr)
                }
            }
        })
    }

}
