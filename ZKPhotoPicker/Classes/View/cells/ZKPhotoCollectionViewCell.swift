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
    
    let imgvThumb = UIImageView()
    let lblPhotoTag = UILabel()
    let btnSelect = UIButton.init(type: .custom)
    var assetModel: ZKAssetModel? {
        didSet {
            self.btnSelect.setImage(self.assetModel?.picker.config.selectTagImageN, for: .normal)
            self.btnSelect.setImage(self.assetModel?.picker.config.selectTagImageS, for: .selected)
            self.imgvThumb.image = self.assetModel?.defaultImage
            self.assetModel?.loadThumbImage(result: {
                [weak self] img, err in
                self?.imgvThumb.image = img
            })
            self.assetModel?.addSelectListener(self)
            if let photoType = self.assetModel?.photoType {
                self.lblPhotoTag.text = photoType.desc
                self.lblPhotoTag.isHidden = photoType == .staticPhoto
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imgvThumb.frame = self.bounds
        self.contentView.addSubview(self.imgvThumb)
        self.btnSelect.frame = .init(x: 0, y: 0, width: 20, height: 20)
        self.contentView.addSubview(self.btnSelect)
        self.btnSelect.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)
        self.contentView.addSubview(self.lblPhotoTag)
        self.lblPhotoTag.textColor = .white
        self.lblPhotoTag.font = .systemFont(ofSize: 10)
        self.lblPhotoTag.textAlignment = .center
        self.lblPhotoTag.backgroundColor = UIColor.init(white: 1, alpha: 0.3)
        self.lblPhotoTag.layer.cornerRadius = 5
        self.lblPhotoTag.clipsToBounds = true
        self.lblPhotoTag.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func selectButtonTapped(_ btn: UIButton) {
        self.assetModel?.selectTap()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.btnSelect.frame.inset(by: .init(top: 0, left: -20, bottom: -20, right: 0)).contains(point) {
            return self.btnSelect
        }
        return super.hitTest(point, with: event)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        self.assetModel?.picker.config.viewBackGroundColor.setFill()
        ctx.fill(rect)
        ctx.restoreGState()
        
        if let model = self.assetModel, model.isSelected {
            self.imgvThumb.layer.borderColor = model.picker.config.selectTagColor.cgColor
            self.imgvThumb.layer.borderWidth = 4
            self.btnSelect.isSelected = true
        }
        else {
            self.imgvThumb.layer.borderWidth = 0
            self.btnSelect.isSelected = false
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let config = self.assetModel?.picker.config {
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
