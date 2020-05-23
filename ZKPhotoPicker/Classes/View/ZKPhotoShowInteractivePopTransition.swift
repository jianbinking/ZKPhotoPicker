//
//  ZKPhotoShowInteractivePopTransition.swift
//  ZKPhotoPickerDemo
//
//  Created by CallMeDoby on 2020/5/24.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import FLAnimatedImage

class ZKPhotoShowInteractivePopTransition: UIPercentDrivenInteractiveTransition {
    
    unowned var transCtx: UIViewControllerContextTransitioning!
    private let bgView = UIView()
    private let imgvTemp = FLAnimatedImageView()
    private let mask = UIView()
    private var ptImgvStartCenter = CGPoint.zero
    private(set) var isInteractive = false
    private var animateNavToolBar = false
    
    private unowned let pageVC: ZKPhotoShowPageViewController
    private var contentVC: ZKPhotoShowContentViewController {
        self.pageVC.currentContentVC!
    }
    private unowned var collectionVC: ZKPhotoCollectionListViewController?
    
    
    init(pageVC: ZKPhotoShowPageViewController) {
        self.pageVC = pageVC
        super.init()
        let panges = UIPanGestureRecognizer.init(target: self, action: #selector(panGes(pan:)))
        pageVC.view.addGestureRecognizer(panges)
        panges.delegate = pageVC
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transCtx = transitionContext
        transitionContext.containerView.insertSubview(transitionContext.view(forKey: .to)!, at: 0)
        self.pageVC.view.isHidden = true
        self.bgView.frame = self.pageVC.view.bounds
        self.bgView.backgroundColor = self.pageVC.view.backgroundColor
        self.imgvTemp.frame = self.contentVC.imageViewFrame
        if self.contentVC.assetManager.assetModel.photoType == .gif {
            self.imgvTemp.animatedImage = self.contentVC.imageView.animatedImage
        }
        else {
            self.imgvTemp.image = self.contentVC.imageView.image
        }
        self.ptImgvStartCenter = self.imgvTemp.center
        transitionContext.containerView.addSubview(self.bgView)
        transitionContext.containerView.addSubview(self.imgvTemp)
        
        self.mask.backgroundColor = .black
        self.mask.frame = self.imgvTemp.bounds
        self.imgvTemp.mask = self.mask
        
        self.collectionVC = transitionContext.viewController(forKey: .to) as? ZKPhotoCollectionListViewController
        self.animateNavToolBar = self.pageVC.navigationController!.navigationBar.alpha == 0
    }
    
    @objc private func panGes(pan: UIPanGestureRecognizer) {
        
        let vector = pan.translation(in: pan.view)
        let yoff = max(vector.y, 0)
        let scale:CGFloat = 1 - (yoff / self.pageVC.view.bounds.height)
        
        switch pan.state {
        case .began:
            self.isInteractive = true
            self.pageVC.navigationController?.popViewController(animated: true)
        case .changed:
            self.imgvTemp.center = .init(x: self.ptImgvStartCenter.x + vector.x, y: self.ptImgvStartCenter.y + vector.y)
            self.imgvTemp.transform = .init(scaleX: scale, y: scale)
            self.bgView.alpha = scale
            self.update(1 - scale)
            if self.animateNavToolBar {
                self.collectionVC?.navigationController?.navigationBar.alpha = 1 - scale
                self.collectionVC?.navigationController?.toolbar.alpha = 1 - scale
            }
        case .ended:
            self.isInteractive = false
            if scale < 0.7 {
                self.finish()
                self.interactiveTransFinish()
            }
            else {
                self.cancel()
                self.interactiveTransCancel()
            }
        default:
            if self.isInteractive {
                self.isInteractive = false
                self.cancel()
                self.interactiveTransCancel()
            }
        }
    }
    
    
    private func interactiveTransFinish() {
        let startFrame = self.imgvTemp.bounds
        let endFrame = self.pageVC.collectionCellFrame!
        
        let maxScale = max(endFrame.width / startFrame.width, endFrame.height / startFrame.height)
        
        UIView.animate(withDuration: 0.35, animations: {
            self.imgvTemp.center = .init(x: endFrame.midX, y: endFrame.midY)
            self.imgvTemp.transform = .init(scaleX: maxScale, y: maxScale)
            self.mask.frame = .init(x: 0, y: 0, width: endFrame.width / maxScale, height: endFrame.height / maxScale)
            self.mask.center = .init(x: startFrame.width / 2, y: startFrame.height / 2)
            self.bgView.alpha = 0
            if self.animateNavToolBar {
                self.collectionVC?.navigationController?.navigationBar.alpha = 1
                self.collectionVC?.navigationController?.toolbar.alpha = 1
            }
        }, completion: {
            finished in
            self.imgvTemp.removeFromSuperview()
            self.bgView.removeFromSuperview()
            self.pageVC.view.removeFromSuperview()
            self.transCtx.completeTransition(!self.transCtx.transitionWasCancelled)
        })
        
    }
    
    private func interactiveTransCancel() {
        UIView.animate(withDuration: 0.35, animations: {
            self.imgvTemp.transform = .identity
            self.imgvTemp.center = self.ptImgvStartCenter
            self.bgView.alpha = 1
            if self.animateNavToolBar {
                self.collectionVC?.navigationController?.navigationBar.alpha = 0
                self.collectionVC?.navigationController?.toolbar.alpha = 0
            }
        }, completion: {
            finished in
            self.imgvTemp.removeFromSuperview()
            self.bgView.removeFromSuperview()
            self.pageVC.view.isHidden = false
            self.transCtx.completeTransition(!self.transCtx.transitionWasCancelled)
            
        })
    }
    
}
