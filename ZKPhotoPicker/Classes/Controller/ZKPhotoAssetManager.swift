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
}
