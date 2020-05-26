//
//  ViewController.swift
//  ZKPhotoPickerDemo
//
//  Created by Doby on 2020/5/12.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    var selectedAssets: [PHAsset] = []
    var imgvs: [Int:UIImageView] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = UIButton.init(type: .system)
        btn.setTitle("test", for: .normal)
        btn.frame = .init(x: 100, y: 100, width: 100, height: 100)
        btn.addTarget(self, action: #selector(test), for: .touchUpInside)
        self.view.addSubview(btn)
        
    }
    
    @objc func test() {
        let cfg = ZKPhotoPickerConfig.init()
        cfg.mediaType = [.video, .photo]
        ZKPhotoPicker.showPickerView(in: self, delegate: self, config: cfg, selectedAssets: self.selectedAssets) { (status) in
            
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var xoff: CGFloat = 250
        var yoff: CGFloat = 100
        self.imgvs.keys.sorted(by: {$0<$1}).forEach {
            key in
            let v = self.imgvs[key]!
            v.frame = .init(origin: .init(x: xoff, y: yoff), size: v.frame.size)
            xoff += 110
            if xoff + 110 > self.view.frame.width {
                xoff = 10
                yoff += 110
            }
        }
    }

}

extension ViewController: ZKPhotoPickerDelegate {
    
    func photoPicker(picker: ZKPhotoPicker, didFinishPick selectedAssets: [PHAsset]) {
        self.selectedAssets = selectedAssets
        self.imgvs.values.forEach {
            $0.image = nil
        }
        self.selectedAssets.enumerated().forEach {
            idx, asset in
            var imgv: UIImageView!
            if let v = self.imgvs[idx] {
                imgv = v
            }
            else {
                imgv = UIImageView.init(frame: .init(x: 0, y: 0, width: 100, height: 100))
                self.view.addSubview(imgv)
                self.imgvs[idx] = imgv
            }
            asset.zkFetchImage(targetSize: .init(width: 100, height: 100), contentMode: .aspectFit, completeHandle: {
                img, err in
                imgv.image = img
            })
        }
        self.view.setNeedsLayout()
    }
    
    func photoPicker(picker: ZKPhotoPicker, isDefaultCollection collection: PHAssetCollection) -> Bool {
        if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
            return true
        }
        return false
    }
    
}

