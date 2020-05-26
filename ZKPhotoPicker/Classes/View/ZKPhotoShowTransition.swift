//
//  ZKPhotoShowTransition.swift
//  ZKPhotoPicker
//
//  Created by CallMeDoby on 2020/5/10.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit

class ZKPhotoShowTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    /// 是否是push
    var isPush = false
    var pageVC: ZKPhotoShowPageViewController?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView
        
        if isPush {
            
            guard let pageVC = transitionContext.viewController(forKey: .to) as? ZKPhotoShowPageViewController, let contentVC = pageVC.currentContentVC else {
                fatalError("只能用在collection push pagevc")
            }
            
            contentVC.loadPreviewImage2Push(complete: {
                img in
                guard let startFrame = pageVC.collectionCellFrame else {
                    fatalError("collection cell frame 必须有")
                }
                let endFrame = contentVC.imageViewFrame
                
                let bgView = UIView.init(frame: transitionContext.finalFrame(for: pageVC))
                bgView.backgroundColor = pageVC.view.backgroundColor
                let imgvTemp = UIImageView.init(frame: endFrame)
                let mask = UIView.init(frame: imgvTemp.bounds)
                mask.backgroundColor = .black
                imgvTemp.mask = mask
                imgvTemp.image = img
                container.addSubview(pageVC.view)
                
                container.addSubview(bgView)
                container.addSubview(imgvTemp)
                
                let maxScale = max(startFrame.width / endFrame.width, startFrame.height / endFrame.height)
                
                imgvTemp.center = .init(x: startFrame.midX, y: startFrame.midY)
                imgvTemp.transform = .init(scaleX: maxScale, y: maxScale)
                mask.frame = .init(x: 0, y: 0, width: startFrame.width / maxScale, height: startFrame.height / maxScale)
                mask.center = .init(x: imgvTemp.bounds.width / 2, y: imgvTemp.bounds.height / 2)
                bgView.alpha = 0
                pageVC.view.isHidden = true
                
                UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                    bgView.alpha = 1
                    imgvTemp.transform = .identity
                    imgvTemp.center = .init(x: endFrame.midX, y: endFrame.midY)
                    mask.frame = imgvTemp.bounds
                }, completion: {
                    finished in
                    pageVC.view.isHidden = false
                    imgvTemp.removeFromSuperview()
                    bgView.removeFromSuperview()
                    transitionContext.completeTransition(finished)
                })
            })
        }
        else {
            
            guard let pageVC = transitionContext.viewController(forKey: .from) as? ZKPhotoShowPageViewController, let contentVC = pageVC.currentContentVC, let collectionVC = transitionContext.viewController(forKey: .to) as? ZKPhotoCollectionListViewController else {
                fatalError("pop时只能用在pagevc到collectionvc")
            }
            let startFrame = contentVC.imageViewFrame
            guard let endFrame = pageVC.collectionCellFrame else {
                fatalError("collectionview cellframe异常")
            }
            
            let bgView = UIView.init(frame: container.bounds)
            bgView.backgroundColor = pageVC.view.backgroundColor
            let imgvTemp = UIImageView.init(frame: startFrame)
            imgvTemp.image = contentVC.previewImage
            let mask = UIView.init(frame: imgvTemp.bounds)
            mask.backgroundColor = .black
            imgvTemp.mask = mask
            
            let maxScale = max(endFrame.width / startFrame.width, endFrame.height / startFrame.height)
            
            container.insertSubview(collectionVC.view, at: 0)
            container.addSubview(bgView)
            container.addSubview(imgvTemp)
            pageVC.view.isHidden = true
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                bgView.alpha = 0
                imgvTemp.center = .init(x: endFrame.midX, y: endFrame.midY)
                imgvTemp.transform = .init(scaleX: maxScale, y: maxScale)
                mask.frame = .init(x: 0, y: 0, width: endFrame.width / maxScale, height: endFrame.height / maxScale)
                mask.center = .init(x: imgvTemp.bounds.width / 2, y: imgvTemp.bounds.height / 2)
            }, completion: {
                finished in
                pageVC.view.removeFromSuperview()
                imgvTemp.removeFromSuperview()
                bgView.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
            
        }
        
    }
    
}
