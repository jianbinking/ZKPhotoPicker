//
//  ZKPhotoPickerConfig.swift
//  ZKPhotoPicker
//
//  Created by Doby on 2020/5/11.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit

public class ZKPhotoPickerConfig: NSObject {
    
    @objc var mediaType: ZKAssetMediaType = .photo
    
    @objc var textColor: UIColor = .black
    @objc var viewBackGroundColor: UIColor = .white
    @objc var viewBackGroundReverseColor: UIColor = .black
    @objc var selectTagColor: UIColor = .blue
    @objc var selectTagPosition: ZKSelectTagPosition = .topRight
    @objc var mediaTypeTagPosition: ZKSelectTagPosition = .bottomLeft
    /// 大图查看时，是否可用确定，确定后选择当前并退出
    @objc var enableLargeConfirmAsSelect = true
    @objc var customBundlePath: String? = nil
    
    lazy var selectTagImageN: UIImage = self.createCheckImage(isSelected: false)
    lazy var selectTagImageS: UIImage = self.createCheckImage(isSelected: true)
    
    lazy var videoTagImage: UIImage = self.loadBundleImage(for: "image_videotag")
    
    public override init() {
        super.init()
        if #available(iOS 13.0, *) {
            self.textColor = .label
            self.viewBackGroundColor = .systemBackground
            self.viewBackGroundReverseColor = .label
            selectTagColor = .systemBlue
        }
    }
    
    func loadBundleImage(for name: String) -> UIImage {
        if let customBundlePath = self.customBundlePath, let bundle = Bundle.init(path: customBundlePath), let imgPath = bundle.path(forResource: name, ofType: "png"), let img = UIImage.init(contentsOfFile: imgPath) {
            return img
        }
        else {
            let customBundlePath = Bundle.init(for: ZKPhotoPicker.self).path(forResource: "ZKPhotoPicker", ofType: "bundle")!
            let bundle = Bundle.init(path: customBundlePath)!
            let imgPath = bundle.path(forResource: name, ofType: "png")!
            return UIImage.init(contentsOfFile: imgPath)!
        }
    }

}

extension ZKPhotoPickerConfig {
    
    fileprivate func createCheckImage(isSelected: Bool) -> UIImage {
        
        autoreleasepool {
            let width: CGFloat = 20
            let checkLineWidth: CGFloat = 2
            
            var borderColor: UIColor = .black
            var bgColor: UIColor = UIColor.init(white: 0, alpha: 0.4)
            var checkColor: UIColor = .white
            if (isSelected) {
                borderColor = self.viewBackGroundReverseColor
                bgColor = self.selectTagColor
                checkColor = self.viewBackGroundColor
            }
            
            let size = CGSize.init(width: width, height: width)
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            let ctx = UIGraphicsGetCurrentContext()!
            
            
            //背景色+边框
            let path = UIBezierPath.init(roundedRect: .init(origin: .zero, size: size), cornerRadius: width / 2)
            
            ctx.saveGState()
            bgColor.setFill()
            ctx.addPath(path.cgPath)
            ctx.fillPath()
            borderColor.setStroke()
            ctx.setLineWidth(2)
            ctx.strokePath()
            ctx.restoreGState()
            
            //对号
            let check = UIBezierPath.init()
            check.move(to: .init(x: width * 0.25, y: width * 0.5))
            check.addLine(to: .init(x: width * 0.4, y: width * 0.7))
            check.addLine(to: .init(x: width * 0.8, y: width * 0.3))
            
            ctx.saveGState()
            ctx.addPath(check.cgPath)
            ctx.setLineWidth(checkLineWidth)
            ctx.setLineCap(.round)
            ctx.setLineJoin(.round)
            checkColor.setStroke()
            ctx.strokePath()
            
            
            let img = UIGraphicsGetImageFromCurrentImageContext()
            
            return img ?? .init()
        }
    }
    
}
