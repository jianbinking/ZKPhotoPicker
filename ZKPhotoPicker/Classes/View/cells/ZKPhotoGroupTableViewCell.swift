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
    
    var collectionManager: ZKPhotoCollectionManager! {
        didSet {
            self.lblDesc.text = "\(self.collectionManager.desc)(\(self.collectionManager.itemCount))"
            ZKPhotoPicker.current?.cachingImageManager.getThumbImage(for: self.collectionManager.keyAsset, result: {
                img, err in
                self.thumbImage = img
                self.setNeedsDisplay()
            })
        }
    }
    
    private var thumbImage: UIImage?
    private let lblDesc: UILabel

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.lblDesc = UILabel()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = ZKPhotoPicker.current?.config.viewBackGroundColor
        self.contentView.addSubview(self.lblDesc)
        self.lblDesc.textColor = ZKPhotoPicker.current?.config.textColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let img = self.thumbImage else {
            return
        }
        let thumbRC = CGRect.init(x: 0, y: 0, width: rect.height, height: rect.height)
        img.draw(in: thumbRC.aspectFillRect(for: img.size))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imgSize = CGSize.init(width: self.bounds.height, height: self.bounds.height)
        self.lblDesc.frame = .init(x: imgSize.width + 20, y: 0, width: self.bounds.width - imgSize.width - 20, height: imgSize.height)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
