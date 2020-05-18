//
//  ZKPhotoCollectionViewCell.swift
//  ZKPhotoPicker
//
//  Created by Doby on 2020/5/9.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos

class ZKPhotoCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate, ZKPhotoAssetSelectedListener {
    
    var img: UIImage? = UIImage.zkDefaultImage {
        didSet {
            self.setNeedsDisplay()
        }
    }
    let lblPhotoTag = UILabel()
    let btnSelect = UIButton.init(type: .custom)
    var assetManager: ZKPhotoAssetManager? {
        didSet {
            if let mn = self.assetManager {
                self.lblPhotoTag.text = mn.photoType.desc
                self.lblPhotoTag.isHidden = !(mn.mediaType == .photo && mn.photoType != .staticPhoto)
                mn.addSelectListener(self)
                ZKPhotoPicker.current?.cachingImageManager.getThumbImage(for: mn.asset, result: {
                    img, err in
                    self.img = img
                    self.setNeedsDisplay()
                })
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.btnSelect.frame = .init(x: 0, y: 0, width: 20, height: 20)
        self.contentView.addSubview(self.btnSelect)
        self.btnSelect.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)
        self.btnSelect.setImage(ZKPhotoPicker.current?.config.selectTagImageN, for: .normal)
        self.btnSelect.setImage(ZKPhotoPicker.current?.config.selectTagImageS, for: .selected)
        self.contentView.addSubview(self.lblPhotoTag)
        self.lblPhotoTag.textColor = .white
        self.lblPhotoTag.font = .systemFont(ofSize: 10)
        self.lblPhotoTag.textAlignment = .center
        self.lblPhotoTag.backgroundColor = UIColor.init(white: 1, alpha: 0.3)
        self.lblPhotoTag.layer.cornerRadius = 5
        self.lblPhotoTag.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func selectButtonTapped(_ btn: UIButton) {
        self.assetManager?.selectTap()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.btnSelect.frame.inset(by: .init(top: 0, left: -20, bottom: -20, right: 0)).contains(point) {
            return self.btnSelect
        }
        return super.hitTest(point, with: event)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let img = self.img else {
            return
        }
        
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        ZKPhotoPicker.current?.config.viewBackGroundColor.setFill()
        ctx.fill(rect)
        ctx.restoreGState()
        
        
        img.draw(in: rect.aspectFillRect(for: img.size))
        
        if let picker = ZKPhotoPicker.current {
            if picker.isAssetSelected(self.assetManager!.asset) {
                picker.config.selectTagColor.setStroke()
                ctx.setLineWidth(8)
                ctx.stroke(rect)
                self.btnSelect.isSelected = true
            }
            else {
                self.btnSelect.isSelected = false
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let config = ZKPhotoPicker.current?.config {
            var rc = self.btnSelect.bounds
            switch config.selectTagPosition {
            case .topLeft:
                rc.origin.x = 0
            case .topRight:
                rc.origin.x = self.bounds.width - rc.width
            case .bottomLeft:
                rc.origin.y = self.bounds.height - rc.height
            case .bottomRight:
                rc.origin.x = self.bounds.width - rc.width
                rc.origin.y = self.bounds.height - rc.height
            }
            self.btnSelect.frame = rc
            
            self.lblPhotoTag.sizeToFit()
            var tagrc = self.lblPhotoTag.bounds.insetBy(dx: -5, dy: 0)
            tagrc.origin.x = 0
            switch config.mediaTypeTagPosition {
            case .topLeft:
                tagrc.origin.x = 0
            case .topRight:
                tagrc.origin.x = self.bounds.width - tagrc.width
            case .bottomLeft:
                tagrc.origin.y = self.bounds.height - tagrc.height
            case .bottomRight:
                tagrc.origin.x = self.bounds.width - tagrc.width
                tagrc.origin.y = self.bounds.height - tagrc.height
            }
            self.lblPhotoTag.frame = tagrc
            
        }
    }
    
    func assetSelectedChange(isSelected: Bool) {
        self.setNeedsDisplay()
    }
    
}
