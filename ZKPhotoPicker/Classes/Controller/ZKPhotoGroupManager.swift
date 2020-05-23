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
    
    var collectionModels: [ZKAssetCollectionModel] = []
    unowned let picker: ZKPhotoPicker
    
    init(picker: ZKPhotoPicker) {
        self.picker = picker
        super.init()
        
    }
    
    func requestCollections(completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            let allPhotoCollectionResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
            allPhotoCollectionResult.enumerateObjects { (collection, idx, isStop) in
                self.collectionModels.append(.init(collection: collection, picker: self.picker))
            }
            
            let nomalCollectionResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            nomalCollectionResult.enumerateObjects { (collection, idx, isStop) in
                if let shouldHide = self.picker.delegate?.photoPicker?(picker: self.picker, groupCollectionShouldHide: collection), shouldHide {
                    return
                }
                let model = ZKAssetCollectionModel.init(collection: collection, picker: self.picker)
                if model.assetCount > 0 {
                    self.collectionModels.append(model)
                }
            }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}
