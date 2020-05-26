//
//  ZKPhotoShowContentViewController.swift
//  ZKPhotoPicker
//
//  Created by Doby on 2020/5/9.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import FLAnimatedImage
import AVFoundation

class ZKPhotoShowContentViewController: ZKBaseViewController {
    
    let index: Int
    let assetManager: ZKPhotoAssetManager
    unowned var pageVC: ZKPhotoShowPageViewController
    
    fileprivate var scrollView: UIScrollView!
    var previewImage: UIImage?
    var contentElementSize: CGSize?
    var contentView: UIView {
        fatalError("子类必须实现")
    }
    private(set) var layer: CALayer?
    
    fileprivate var loadPreviewImageHandle: ((UIImage?) -> Void)?
    
    var imageViewFrame: CGRect {
        return self.view.convert(self.contentView.frame, from: self.scrollView)
    }
    
    static func contentVCWith(index: Int, assetManager: ZKPhotoAssetManager, pageVC: ZKPhotoShowPageViewController) -> ZKPhotoShowContentViewController {
        
        var contentVC: ZKPhotoShowContentViewController!
        
        switch assetManager.assetModel.mediaType {
        case .video:
            contentVC = ZKPhotoShowVideoContentViewController.init(index: index, assetManager: assetManager, pageVC: pageVC)
        default:
            switch assetManager.assetModel.photoType {
            case .livePhoto:
                contentVC = ZKPhotoShowLivePhotoContentViewController.init(index: index, assetManager: assetManager, pageVC: pageVC)
            default:
                contentVC = ZKPhotoShowImageContentViewController.init(index: index, assetManager: assetManager, pageVC: pageVC)
            }
        }
        return contentVC
    }
    
    fileprivate init(index: Int, assetManager: ZKPhotoAssetManager, pageVC: ZKPhotoShowPageViewController) {
        self.index = index
        self.assetManager = assetManager
        self.pageVC = pageVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear

        self.scrollView = UIScrollView.init(frame: self.view.bounds)
        self.scrollView.contentInsetAdjustmentBehavior = .never
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.maximumZoomScale = 2
        self.scrollView.minimumZoomScale = 1
        self.scrollView.delegate = self
        self.view.addSubview(self.scrollView)
        
        self.scrollView.addSubview(self.contentView)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(singleTap))
        self.view.addGestureRecognizer(tap)
        let double = UITapGestureRecognizer.init(target: self, action: #selector(doubleTap))
        double.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(double)
        tap.require(toFail: double)

        let opt = PHImageRequestOptions()
        opt.isSynchronous = true
        opt.deliveryMode = .highQualityFormat
        opt.resizeMode = .fast
        
        self.loadPreviewImage()
    }
    
    fileprivate func loadPreviewImage() {
        self.assetManager.loadImage(result: {
            img, err in
            if let image = img {
                self.contentElementSize = image.size
                self.previewImage = image
                self.resizeContentView()
            }
            self.loadPreviewImageHandle?(img)
            self.loadPreviewImageHandle = nil
        })
    }
    
    func loadPreviewImage2Push(complete: @escaping (UIImage?) -> Void) {
        if let previewImage = self.previewImage {
            complete(previewImage)
        } else {
            self.loadPreviewImageHandle = complete
        }
    }
    
    func canStartSwipe2Close(pan: UIPanGestureRecognizer) -> Bool {
        if self.scrollView.contentOffset.y == 0 {
            let v = pan.velocity(in: self.view)
            if v.y > 0, abs(v.y) > abs(v.x) {
                return true
            }
        }
        return false
    }
    
    //MARK: - target action
    
    @objc func singleTap() {
        if let alpha = self.navigationController?.navigationBar.alpha, alpha == 0 {
            self.navigationController?.navigationBar.alpha = 1
            self.navigationController?.toolbar.alpha = 1
            self.pageVC.view.backgroundColor = self.assetManager.picker.config.viewBackGroundColor
        }
        else {
            self.navigationController?.navigationBar.alpha = 0
            self.navigationController?.toolbar.alpha = 0
            self.pageVC.view.backgroundColor = .black
        }
    }
    
    @objc func doubleTap() {
        if self.scrollView.zoomScale == self.scrollView.minimumZoomScale {
            self.scrollView.setZoomScale(self.scrollView.maximumZoomScale, animated: true)
        }
        else {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        }
    }
    
    //MARK: - private method
    
    fileprivate func resizeContentView() {
        if let imgSize = self.contentElementSize {
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale
            let scale = max(imgSize.width / self.scrollView.bounds.width, imgSize.height / self.scrollView.bounds.height)
            var xoff = (self.scrollView.bounds.width - imgSize.width / scale) / 2
            var yoff = (self.scrollView.bounds.height - imgSize.height / scale) / 2
            xoff = max(xoff, 0)
            yoff = max(yoff, 0)
            self.contentView.frame = .init(x: xoff, y: yoff, width: imgSize.width / scale, height: imgSize.height / scale)
            self.scrollView.maximumZoomScale = max(self.scrollView.bounds.width / self.contentView.frame.width, 2)
        }
    }
}

extension ZKPhotoShowContentViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var xoff = (scrollView.bounds.width - self.contentView.frame.width) / 2
        xoff = max(xoff, 0)
        var yoff = (scrollView.bounds.height - self.contentView.frame.height) / 2
        yoff = max(yoff, 0)
        self.contentView.frame = .init(origin: .init(x: xoff, y: yoff), size: self.contentView.frame.size)
    }
    
}

class ZKPhotoShowImageContentViewController: ZKPhotoShowContentViewController {
    
    let imageView: FLAnimatedImageView = .init()
    override var previewImage: UIImage? {
        willSet {
            if self.assetManager.assetModel.photoType == .staticPhoto {
                self.imageView.image = newValue
            }
        }
    }
    override var contentView: UIView {
        return self.imageView
    }
    
    override func loadPreviewImage() {
        if self.assetManager.assetModel.photoType == .gif {
            PHImageManager.default().requestImageData(for: self.assetManager.assetModel.asset, options: nil, resultHandler: {
                data, uti, orientation, info in
                let img = FLAnimatedImage.init(gifData: data)
                self.imageView.animatedImage = img
                self.previewImage = img?.posterImage
                self.contentElementSize = img?.size
                self.resizeContentView()
                self.loadPreviewImageHandle?(self.imageView.image)
                self.loadPreviewImageHandle = nil
            })
        }
        else {
            super.loadPreviewImage()
        }
    }
}

class ZKPhotoShowLivePhotoContentViewController: ZKPhotoShowContentViewController, PHLivePhotoViewDelegate {
    
    let livePhotoView: PHLivePhotoView = .init()
    override var contentView: UIView {
        return self.livePhotoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.livePhotoView.delegate = self
        self.startPlayLivePhoto()
        
    }
    
    private func startPlayLivePhoto() {
        self.assetManager.loadLivePhoto(result: {
            livePhoto, err in
            self.livePhotoView.livePhoto = livePhoto
            self.livePhotoView.startPlayback(with: .full)
        })
    }
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        livePhotoView.startPlayback(with: .full)
    }
    
}

class ZKPhotoShowVideoContentViewController: ZKPhotoShowContentViewController {
    
    let playerView = UIView()
    var player: AVPlayer?
    private(set) var avplayerLayer: AVPlayerLayer?
    override var contentView: UIView {
        return self.playerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.assetManager.loadPlayerItem(result: {
            item, err in
            if let item = item {
                self.player = .init(playerItem: item)
                self.avplayerLayer = .init(player: self.player)
                self.view.setNeedsLayout()
                self.startPlay()
            }
        })
    }
    
    private func startPlay() {
        if let layer = self.avplayerLayer {
            self.playerView.layer.addSublayer(layer)
            self.player?.play()
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.avplayerLayer?.bounds = self.playerView.bounds
        self.avplayerLayer?.position = .init(x: self.playerView.bounds.width / 2, y: self.playerView.bounds.height / 2)
    }
    
    
}
