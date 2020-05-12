//
//  ZKPhotoPickerDelegate.swift
//  ZKPhotoPicker
//
//  Created by Doby on 2020/5/8.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos
@objc public protocol ZKPhotoPickerDelegate {
    
    
    //MARK: - group appearence
    @objc optional func photoPicker(picker: ZKPhotoPicker, groupCollectionShouldHide group:PHAssetCollection) -> Bool
    
    //MARK: - collection appearence
    @objc optional func photoPicker(picker: ZKPhotoPicker, assetShouldHide asset: PHAsset, in collection: PHAssetCollection) -> Bool
    //MARK: - select asset
    @objc optional func photoPicker(picker: ZKPhotoPicker, canSelectAsset asset: PHAsset) -> Bool
    @objc optional func photoPicker(picker: ZKPhotoPicker, didSelectAsset asset: PHAsset)
    @objc optional func photoPicker(picker: ZKPhotoPicker, canDeselectAsset asset: PHAsset) -> Bool
    @objc optional func photoPicker(picker: ZKPhotoPicker, didDeselectAsset asset: PHAsset)
    
    @objc optional func photoPicker(picker: ZKPhotoPicker, didFinishPick selectedAssets: [PHAsset])
    @objc optional func photoPickerDidCancelPick(picker: ZKPhotoPicker)
    
    //MARK: - collection layout
    @objc optional func collectionItemSize(in collection: PHAssetCollection) -> CGSize
    @objc optional func sectionInset(in collection: PHAssetCollection) -> UIEdgeInsets
    @objc optional func mininumLineSpacing(in collection: PHAssetCollection) -> CGFloat
    @objc optional func mininumColumnSpace(in collection: PHAssetCollection) -> CGFloat
    
    
    
}
