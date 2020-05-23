//
//  ZKAssetModel.swift
//  ZKPhotoPickerDemo
//
//  Created by CallMeDoby on 2020/5/23.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos

/// 照片被选择之后的坚挺，会weak持有，尽情添加
@objc protocol ZKPhotoAssetSelectedListener: NSObjectProtocol {
    func assetSelectedChange(isSelected: Bool)
}


class ZKAssetModel: NSObject {
    
    let asset: PHAsset
    unowned let picker: ZKPhotoPicker
    let mediaType: ZKAssetMediaType
    var photoType: ZKAssetPhotoType
    var defaultImage: UIImage {
        return self.picker.defaultImage
    }
    var isSelected: Bool
    
    private let listeners = NSHashTable<ZKPhotoAssetSelectedListener>.init(options: .weakMemory)
    
    init(asset: PHAsset, picker: ZKPhotoPicker) {
        self.asset = asset
        self.picker = picker
        if asset.mediaType == .video {
            self.mediaType = .video
            self.photoType = .staticPhoto
        }
        else {
            self.mediaType = .photo
            if asset.mediaSubtypes == .photoLive {
                self.photoType = .livePhoto
            }
            else if let fileName = asset.value(forKey: "filename") as? String, fileName.uppercased().hasSuffix("GIF") {
                self.photoType = .gif
            }
            else {
                self.photoType = .staticPhoto
            }
        }
        self.isSelected = picker.isAssetSelected(asset)
    }
    
    func loadThumbImage(result: @escaping (UIImage?, ZKFetchImageFail?) -> Void) {
        self.picker.cachingImageManager.getThumbImage(for: self.asset, result: result)
    }
    
    
    func addSelectListener(_ listener: ZKPhotoAssetSelectedListener) {
        self.listeners.add(listener)
    }
    
    func removeSelectListener(_ listener: ZKPhotoAssetSelectedListener) {
        self.listeners.remove(listener)
    }
    
    func selectTap() {
        if self.isSelected {
            if let canDeselect = self.picker.delegate?.photoPicker?(picker: picker, canDeselectAsset: self.asset), !canDeselect {
                return
            }
            picker.didDeselect(asset: self.asset)
        }
        else {
            if let canSelect = self.picker.delegate?.photoPicker?(picker: picker, canSelectAsset: self.asset), !canSelect {
                return
            }
            picker.didSelect(asset: self.asset)
        }
        self.isSelected = !self.isSelected
        self.listeners.allObjects.forEach {
            listener in
            listener.assetSelectedChange(isSelected: self.isSelected)
        }
    }

}
