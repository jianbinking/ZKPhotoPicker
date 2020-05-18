//
//  ZKPhotoAssetManager.swift
//  ZKPhotoPicker
//
//  Created by Doby on 2020/5/11.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos

/// 照片被选择之后的坚挺，会weak持有，尽情添加
@objc protocol ZKPhotoAssetSelectedListener: NSObjectProtocol {
    func assetSelectedChange(isSelected: Bool)
}

class ZKPhotoAssetManager: NSObject {
    
    let asset: PHAsset
    let mediaType: ZKAssetMediaType
    let photoType: ZKAssetPhotoType
    private(set) var isSelected = false
    
    private let listeners = NSHashTable<ZKPhotoAssetSelectedListener>.init(options: .weakMemory)
    
    init(_ asset: PHAsset) {
        self.asset = asset
        
        self.mediaType = asset.zkMediaType
        self.photoType = asset.zkPhotoType
        
        super.init()
        if let picker = ZKPhotoPicker.current {
            self.isSelected = picker.isAssetSelected(asset)
        }
    }
    
    func addSelectListener(_ listener: ZKPhotoAssetSelectedListener) {
        self.listeners.add(listener)
    }
    
    func removeSelectListener(_ listener: ZKPhotoAssetSelectedListener) {
        self.listeners.remove(listener)
    }
    
    func selectTap() {
        if let picker = ZKPhotoPicker.current {
            if self.isSelected {
                if let canDeselect = picker.delegate?.photoPicker?(picker: picker, canDeselectAsset: self.asset), !canDeselect {
                    return
                }
                picker.didDeselect(asset: self.asset)
            }
            else {
                if let canSelect = picker.delegate?.photoPicker?(picker: picker, canSelectAsset: self.asset), !canSelect {
                    return
                }
                picker.didSelect(asset: self.asset)
            }
        }
        self.isSelected = !self.isSelected
        self.listeners.allObjects.forEach {
            listener in
            listener.assetSelectedChange(isSelected: self.isSelected)
        }
    }
    
    func requestThumbImage(_ result: @escaping (UIImage?, ZKFetchImageFail?) -> Void) {
        if let picker = ZKPhotoPicker.current {
            picker.cachingImageManager.getThumbImage(for: self.asset, result: result)
        }
    }

}
