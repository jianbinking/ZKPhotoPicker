//
//  ZKPhotoShowTransition.swift
//  ZKPhotoPicker
//
//  Created by CallMeDoby on 2020/5/10.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit

class ZKPhotoShowTransition: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    
    var isPush = false
    
    var isInteractive = false
    
    var bgView = UIView()
    var imgvTemp = UIImageView()
    
    private var preCenter = CGPoint.zero
    func updateTempImage(vector: CGPoint) {
        
        var scale = 1 - vector.y / 400
        scale = min(scale, 1)
        self.update(1 - scale)
        
        self.imgvTemp.center = self.preCenter + vector
        self.imgvTemp.transform = .init(scaleX: scale, y: scale)
        self.bgView.alpha = scale
    }
    
    func endGesTransform(finish: Bool, endFrame: CGRect) {

        let secondsRemain = 0.35
        if finish {
            let startFrame = self.imgvTemp.bounds
            let scale = max(endFrame.width / startFrame.width, endFrame.height / startFrame.height)
            
            let mask = UIView.init(frame: startFrame)
            mask.backgroundColor = .black
            self.imgvTemp.mask = mask
            
            UIView.animate(withDuration: TimeInterval(secondsRemain), animations: {
                var maskRC = CGRect.init(x: 0, y: 0, width: endFrame.width / scale, height: endFrame.height / scale)
                maskRC.origin.x = (startFrame.width - maskRC.width) / 2
                maskRC.origin.y = (startFrame.height - maskRC.height) / 2
                mask.frame = maskRC
                self.bgView.alpha = 0
                self.imgvTemp.center = .init(x: endFrame.midX, y: endFrame.midY)
                self.imgvTemp.transform = .init(scaleX: scale, y: scale)
            }) { (finished) in
                if finished {
                    self.imgvTemp.removeFromSuperview()
                    self.bgView.removeFromSuperview()
                }
            }
            
            self.finish()
        }
        else {
            UIView.animate(withDuration: TimeInterval(secondsRemain), animations: {
                self.imgvTemp.transform = .identity
                self.imgvTemp.center = self.preCenter
                self.bgView.alpha = 1
            }) { (finished) in
                if finished {
                    self.imgvTemp.removeFromSuperview()
                    self.bgView.removeFromSuperview()
                }
            }
            self.cancel()
        }
        self.isInteractive = false
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!
        
        let container = transitionContext.containerView
        bgView.frame = container.bounds
        
        if (isPush) {
            toVC.view.isHidden = true
            container.addSubview(toVC.view)
            
            guard  let pageVC = toVC as? ZKPhotoShowPageViewController, let startFrame = pageVC.collectionCellFrame else {
                return
            }
            guard let contentVC = pageVC.viewControllers?.first as? ZKPhotoShowContentViewController, let tempImg = contentVC.imageView.image else {
                return
            }
            let endFrame = contentVC.imageViewFrame
            
            bgView.backgroundColor = pageVC.view.backgroundColor
            
            self.imgvTemp.image = tempImg
            imgvTemp.frame = endFrame
            
            let scale = max(startFrame.width / endFrame.width, startFrame.height / endFrame.height)
            let mask = UIView.init(frame: .init(x: 0, y: 0, width: startFrame.width / scale, height: startFrame.height / scale))
            mask.center = .init(x: endFrame.width / 2, y: endFrame.height / 2)
            mask.backgroundColor = .black
            imgvTemp.mask = mask
            
            container.addSubview(bgView)
            container.addSubview(imgvTemp)
            
            bgView.alpha = 0
            imgvTemp.center = .init(x: startFrame.midX, y: startFrame.midY)
            imgvTemp.transform = .init(scaleX: scale, y: scale)
            
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                self.bgView.alpha = 1
                self.imgvTemp.transform = .identity
                self.imgvTemp.center = .init(x: endFrame.midX, y: endFrame.midY)
                mask.frame = .init(x: 0, y: 0, width: endFrame.width, height: endFrame.height)
            }) { (finished) in
                transitionContext.completeTransition(finished)
                if finished {
                    toVC.view.isHidden = false
                    self.imgvTemp.image = nil
                    self.imgvTemp.removeFromSuperview()
                    self.bgView.removeFromSuperview()
                }
            }
        }
        else {
            
            container.insertSubview(toVC.view, at: 0)
            var endFrame = CGRect.zero
            self.imgvTemp.mask = nil
            
            if let pageVC = fromVC as? ZKPhotoShowPageViewController, let contentVC = pageVC.viewControllers?.first as? ZKPhotoShowContentViewController {
                self.bgView.alpha = 1
                self.bgView.backgroundColor = pageVC.view.backgroundColor
                self.imgvTemp.frame = contentVC.imageViewFrame
                self.imgvTemp.image = contentVC.imageView.image
                container.addSubview(self.bgView)
                container.addSubview(self.imgvTemp)
                self.preCenter = self.imgvTemp.center
                endFrame = pageVC.collectionCellFrame ?? .zero
            }
            
            if transitionContext.isInteractive {
                fromVC.view.alpha = 0.1
                UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                    fromVC.view.alpha = 0
                }) { (finished) in
                    if transitionContext.transitionWasCancelled {
                        fromVC.view.alpha = 1
                        //TODO会闪一下
                        transitionContext.completeTransition(false)
                    }
                    else {
                        transitionContext.completeTransition(true)
                    }
                }
            }
            else {
                let startFrame = self.imgvTemp.bounds
                let scale = max(endFrame.width / startFrame.width, endFrame.height / startFrame.height)
                
                let mask = UIView.init(frame: startFrame)
                mask.backgroundColor = .black
                self.imgvTemp.mask = mask
                
                fromVC.view.alpha = 0
                UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                    var maskRC = CGRect.init(x: 0, y: 0, width: endFrame.width / scale, height: endFrame.height / scale)
                    maskRC.origin.x = (startFrame.width - maskRC.width) / 2
                    maskRC.origin.y = (startFrame.height - maskRC.height) / 2
                    mask.frame = maskRC
                    self.bgView.alpha = 0
                    self.imgvTemp.center = .init(x: endFrame.midX, y: endFrame.midY)
                    self.imgvTemp.transform = .init(scaleX: scale, y: scale)
                }) { (finished) in
                    if finished {
                        self.imgvTemp.removeFromSuperview()
                        self.bgView.removeFromSuperview()
                        transitionContext.completeTransition(true)
                    }
                }
            }
        }
    }
    
}
