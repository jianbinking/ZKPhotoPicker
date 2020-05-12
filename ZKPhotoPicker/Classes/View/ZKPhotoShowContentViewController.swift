//
//  ZKPhotoShowContentViewController.swift
//  ZKPhotoPicker
//
//  Created by Doby on 2020/5/9.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos

class ZKPhotoShowContentViewController: UIViewController {
    
    let index: Int
    let assetManager: ZKPhotoAssetManager
    unowned var pageVC: ZKPhotoShowPageViewController
    
    private var scrollView: UIScrollView!
    private(set) var imageView: UIImageView!
    
    var imageViewFrame: CGRect {
        return self.view.convert(self.imageView.frame, from: self.scrollView)
    }
    
    init(index: Int, assetManager: ZKPhotoAssetManager, pageVC: ZKPhotoShowPageViewController) {
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
        
        self.imageView = UIImageView()
        self.scrollView.addSubview(self.imageView)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(singleTap))
        self.view.addGestureRecognizer(tap)
        let double = UITapGestureRecognizer.init(target: self, action: #selector(doubleTap))
        double.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(double)
        tap.require(toFail: double)
        
        self.assetManager.asset.zkFetchImage(targetSize: .zero, contentMode: .default, usePlaceholder: false) { (image, isPlaceholder, err) in
            if let image = image {
                self.imageView.image = image
                self.resizeImageView()
            }
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
        if let hidden = self.navigationController?.isNavigationBarHidden, hidden == true {
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.isToolbarHidden = false
            self.pageVC.view.backgroundColor = ZKPhotoPicker.current?.config.viewBackGroundColor
        }
        else {
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.isToolbarHidden = true
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
    
    private func resizeImageView() {
        if let imgSize = self.imageView.image?.size {
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale
            let scale = max(imgSize.width / self.scrollView.bounds.width, imgSize.height / self.scrollView.bounds.height)
            var xoff = (self.scrollView.bounds.width - imgSize.width / scale) / 2
            var yoff = (self.scrollView.bounds.height - imgSize.height / scale) / 2
            xoff = max(xoff, 0)
            yoff = max(yoff, 0)
            self.imageView.frame = .init(x: xoff, y: yoff, width: imgSize.width / scale, height: imgSize.height / scale)
            self.scrollView.maximumZoomScale = max(self.scrollView.bounds.width / self.imageView.frame.width, 2)
        }
    }
    
    private func createPreVCSnapshot() -> UIImage {
        let imgSize = self.view.bounds.size * UIScreen.main.scale
        UIGraphicsBeginImageContext(imgSize)
        var vcs = self.navigationController?.viewControllers
        _ = vcs?.popLast()
        if let preVC = vcs?.popLast() {
            preVC.view.drawHierarchy(in: .init(origin: .zero, size: imgSize), afterScreenUpdates: true)
        }
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
}

extension ZKPhotoShowContentViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var xoff = (scrollView.bounds.width - self.imageView.frame.width) / 2
        xoff = max(xoff, 0)
        var yoff = (scrollView.bounds.height - self.imageView.frame.height) / 2
        yoff = max(yoff, 0)
        self.imageView.frame = .init(origin: .init(x: xoff, y: yoff), size: self.imageView.frame.size)
    }
    
}
