//
//  ZKExtension.swift
//  ZKPhotoPicker
//
//  Created by Doby on 2020/5/9.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos


extension CGSize {
    static func * (l: CGSize, r: CGFloat) -> CGSize {
        return .init(width: l.width * r, height: l.height * r)
    }
}

extension CGPoint {
    static func + (l: CGPoint, r: CGPoint) -> CGPoint {
        return .init(x: l.x + r.x, y: l.y + r.y)
    }
}

extension CGRect {
    
    var midX: CGFloat {
        set {
            self.origin.x = newValue - self.width / 2
        }
        get {
            self.origin.x + self.width / 2
        }
    }
    var midY: CGFloat {
        set {
            self.origin.y = newValue - self.height / 2
        }
        get {
            self.origin.y + self.height / 2
        }
    }
    
    func aspectFillRect(for size: CGSize) -> CGRect {
        
        let scale = Swift.min(size.width / self.width, size.height / self.height)
        
        let xoff = (self.width - size.width / scale) / 2
        let yoff = (self.height - size.height / scale) / 2
        
        return self.insetBy(dx: xoff, dy: yoff)
    }
    
    func aspectFitRect(for size: CGSize) -> CGRect {
        
        let scale = Swift.max(size.width / self.width, size.height / self.height)
        
        let xoff = (self.width - size.width / scale) / 2
        let yoff = (self.height - size.height / scale) / 2
        
        return self.insetBy(dx: xoff, dy: yoff)
    }
    
}

public extension PHAsset {
    var zkMediaType: ZKAssetMediaType {
        switch self.mediaType {
        case .image:
            return .photo
        case .video:
            return .video
        default:
            return .unknown
        }
    }
    
    /// OC获取图片（异步，因为oc不支持Error对象，所以套一层NSError）
    /// - Parameters:
    ///   - targetSize: 目标大小
    ///   - contentMode: contentMode
    ///   - deliveryMode: 加载模式，默认多次加载
    ///   - completeHandle: 成功回调（图片，是否是缩略图，错误）
    @objc func zkOCFetchImage(targetSize: CGSize,
                        contentMode: PHImageContentMode,
                        deliveryMode: PHImageRequestOptionsDeliveryMode = .opportunistic,
                        completeHandle:@escaping (UIImage?, NSError?) -> Void) {
        self.zkFetchImage(targetSize: targetSize,
                          contentMode: contentMode,
                          deliveryMode: deliveryMode,
                          completeHandle: {
                            img, err in
                            completeHandle(img, err as NSError?)
        })
    }
    
    /// swift获取图片（异步）
    /// - Parameters:
    ///   - targetSize: 目标大小
    ///   - contentMode: contentMode
    ///   - deliveryMode: 加载模式，默认多次加载
    ///   - completeHandle: 成功回调（图片，是否是缩略图，错误）   
    func zkFetchImage(targetSize: CGSize,
                      contentMode: PHImageContentMode,
                      deliveryMode: PHImageRequestOptionsDeliveryMode = .opportunistic,
                      completeHandle:@escaping (UIImage?, ZKFetchImageFail?) -> Void) {
        
        let opt = PHImageRequestOptions()
        opt.version = .current
        opt.deliveryMode = deliveryMode
        opt.resizeMode = .exact
        opt.isNetworkAccessAllowed = false
        opt.isSynchronous = false
        opt.progressHandler = nil
        
        
        PHImageManager.default().requestImage(for: self, targetSize: targetSize, contentMode: contentMode, options: opt) { (image, info) in
            if let err = info?[PHImageErrorKey] as? Error {
                completeHandle(nil, .systemError(err))
            }
            else if let canceled = info?[PHImageCancelledKey] as? Bool, canceled {
                completeHandle(nil, .canceled)
            }
            else if let image = image {
                completeHandle(image, nil)
            }
            else {
                completeHandle(nil, .unknownErr)
            }
        }
    }
}

extension PHImageRequestOptions {
    /// 获取缩略图opt，（异步，一次）
    static var zkThumbOption: PHImageRequestOptions {
        let opt = PHImageRequestOptions()
        opt.version = .current
        opt.deliveryMode = .highQualityFormat
        opt.resizeMode = .exact
        opt.isNetworkAccessAllowed = false
        opt.isSynchronous = false
        opt.progressHandler = nil
        return opt
    }
    /// 获取大图opt（异步，多次)
    static var zkLargeImageOption: PHImageRequestOptions {
        let opt = PHImageRequestOptions()
        opt.version = .current
        opt.deliveryMode = .opportunistic
        opt.resizeMode = .exact
        opt.isNetworkAccessAllowed = false
        opt.isSynchronous = false
        opt.progressHandler = nil
        return opt
    }
}

extension UIImage {
    static var zkDefaultImage: UIImage? {

        var bundle: Bundle?
        if let customBundlePath = ZKPhotoPicker.current?.config.customBundlePath {
            bundle = Bundle.init(path: customBundlePath)
        }
        else {
            let mainBundle = Bundle.init(for: ZKPhotoPicker.self)
            if let path = mainBundle.path(forResource: "ZKPhotoPicker", ofType: "bundle") {
                bundle = Bundle.init(path: path)
            }
        }
        if let imgPath = bundle?.path(forResource: "image_placeholder", ofType: "png") {
            return UIImage.init(contentsOfFile: imgPath)
        }
        return nil
    }
}
