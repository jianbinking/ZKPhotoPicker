//
//  ZKConsts.swift
//  ZKPhotoPicker
//
//  Created by Doby on 2020/5/8.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos

let kZKPhotoThumbNailSize = CGSize.init(width: 200, height: 200)

@objc public enum ZKAssetMediaType: Int, OptionSet {
    
    case photo, video, unknown
    
    public init(rawValue:Int) {
        if rawValue == 0 {
            self = .photo
        }
        else if rawValue == 1 {
            self = .video
        }
        else {
            self = .unknown
        }
    }
    
    var desc: String {
        if self.contains(.photo) {
            return "照片"
        }
        else if self.contains(.video) {
            return "视频"
        }
        else {
            return "未知"
        }
    }
}

@objc public enum ZKAssetPhotoType: Int {
    case staticPhoto, gif, livePhoto
    public init(rawValue:Int) {
        if rawValue == 1 {
            self = .gif
        }
        else if rawValue == 2 {
            self = .livePhoto
        }
        self = .staticPhoto
    }
    var desc: String {
        switch self {
        case .gif:
            return "gif"
        case .livePhoto:
            return "live"
        default:
            return ""
        }
    }
}

public enum ZKFetchImageFail: Error {
    case systemError(Error), canceled, unknownErr, nilAsset
    var localizedDescription: String {
        switch self {
        case let .systemError(err):
            return err.localizedDescription
        case .canceled:
            return "已取消"
        case .unknownErr:
            return "未知错误，就是没取到照片"
        case .nilAsset:
            return "asset为空"
        }
    }
}

@objc public enum ZKSelectTagPosition: Int {
    case topLeft, topRight, bottomLeft, bottomRight
}

