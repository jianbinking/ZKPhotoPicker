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
    
    var img: UIImage? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    let btnSelect = UIButton.init(type: .custom)
    var assetManager: ZKPhotoAssetManager? {
        didSet {
            self.assetManager?.addSelectListener(self)
            ZKPhotoPicker.current?.cachingImageManager.getThumbImage(for: self.assetManager?.asset, result: {
                img, err in
                self.img = img
                self.setNeedsDisplay()
            })
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.btnSelect.frame = .init(x: 0, y: 0, width: 20, height: 20)
        self.contentView.addSubview(self.btnSelect)
        self.btnSelect.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)
        self.btnSelect.setImage(ZKPhotoPicker.current?.config.selectTagImageN, for: .normal)
        self.btnSelect.setImage(ZKPhotoPicker.current?.config.selectTagImageS, for: .selected)
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
        
        img.draw(in: rect.aspectFillRect(for: img.size))
        
        if let picker = ZKPhotoPicker.current {
            if picker.isAssetSelected(self.assetManager!.asset) {
                picker.config.selectTagColor.setStroke()
                UIGraphicsGetCurrentContext()?.setLineWidth(8)
                UIGraphicsGetCurrentContext()?.stroke(rect)
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
        }
    }
    
    func assetSelectedChange(isSelected: Bool) {
        self.setNeedsDisplay()
    }
    
}
