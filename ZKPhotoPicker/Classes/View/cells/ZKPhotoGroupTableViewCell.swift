//
//  ZKPhotoGroupTableViewCell.swift
//  ZKPhotoPicker
//
//  Created by CallMeDoby on 2020/5/8.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos

class ZKPhotoGroupTableViewCell: UITableViewCell {
    
    private let imgvThumb: UIImageView
    private let lblDesc: UILabel

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.imgvThumb = UIImageView()
        self.lblDesc = UILabel()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.addSubview(self.imgvThumb)
        self.contentView.addSubview(self.lblDesc)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadCollectionModel(_ model: ZKAssetCollectionModel) {
        self.backgroundColor = model.picker?.config.viewBackGroundColor
        self.lblDesc.textColor = model.picker?.config.textColor
        self.lblDesc.text = "\(model.title)(\(model.assetCount))"
        self.imgvThumb.image = model.defaultImage
        model.loadThumbImage(result: {
            img, err in
            self.imgvThumb.image = img
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imgvThumb.frame = .init(x: 0, y: 0, width: self.bounds.height, height: self.bounds.height)
        self.lblDesc.frame = .init(x: self.imgvThumb.frame.maxX + 20, y: 0, width: self.bounds.width - self.imgvThumb.frame.width - 20, height: self.bounds.height)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
