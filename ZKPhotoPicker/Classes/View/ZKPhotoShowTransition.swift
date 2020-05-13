//
//  ZKPhotoShowTransition.swift
//  ZKPhotoPicker
//
//  Created by CallMeDoby on 2020/5/10.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit

class ZKPhotoShowTransition: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    
    /// 是否是push
    var isPush = false
    /// 是否是手势pop，如果是，pop动画只更新navbar
    var isInteractive = false
    
    /// 背景色
    var bgView = UIView()
    /// 用来展示缩小的imageview
    var imgvTemp = UIImageView()
    
    /// 手势pop前的center，用来取消时还原
    private var preCenter = CGPoint.zero
    /// 更新手势的imageview
    /// - Parameter vector: pan手势的位移
    func updateTempImage(vector: CGPoint) {
        
        var progress = vector.y / 400
        progress = min(progress, 1)
        progress = max(0, progress)
        self.update(progress)
        
        var imgScale = 1 - vector.y / (max(self.imgvTemp.bounds.height , 400))
        imgScale = min(imgScale, 1)
        imgScale = max(0, imgScale)
        
        self.imgvTemp.center = self.preCenter + vector
        self.imgvTemp.transform = .init(scaleX: imgScale, y: imgScale)
        self.bgView.alpha = 1 - progress
    }
    
    /// 结束手势动画，完成后续动画
    /// - Parameters:
    ///   - finish: 是完成pop还是取消pop
    ///   - endFrame: collectionview中的cell的frame（window坐标系）
    func endGesTransform(finish: Bool, endFrame: CGRect) {

        let secondsRemain = 0.35
        if finish {
            // 这里取imgvTemp的初始大小，frame的话时算了transform的
            let startFrame = self.imgvTemp.bounds
            // 取aspectfill的缩放倍率
            let scale = max(endFrame.width / startFrame.width, endFrame.height / startFrame.height)
            
            // imgvTemp的mask，初始为imgvTemp等大
            let mask = UIView.init(frame: startFrame)
            mask.backgroundColor = .black
            self.imgvTemp.mask = mask
            
            UIView.animate(withDuration: TimeInterval(secondsRemain), animations: {
                // mask变更为enfFrame的比例大小
                var maskRC = CGRect.init(x: 0, y: 0, width: endFrame.width / scale, height: endFrame.height / scale)
                // mask居中
                maskRC.origin.x = (startFrame.width - maskRC.width) / 2
                maskRC.origin.y = (startFrame.height - maskRC.height) / 2
                mask.frame = maskRC
                self.bgView.alpha = 0
                //imgvTemp移动到endFrame位置
                self.imgvTemp.center = .init(x: endFrame.midX, y: endFrame.midY)
                //缩放到endframe大小
                self.imgvTemp.transform = .init(scaleX: scale, y: scale)
            }) { (finished) in
                if finished {
                    //结束后移除imgvTemp，背景色
                    self.imgvTemp.removeFromSuperview()
                    self.bgView.removeFromSuperview()
                }
            }
            //完成pop动画（navbar动画）
            self.finish()
        }
        else {
            // 取消pop
            UIView.animate(withDuration: TimeInterval(secondsRemain), animations: {
                // 恢复imgvTemp跟背景色
                self.imgvTemp.transform = .identity
                self.imgvTemp.center = self.preCenter
                self.bgView.alpha = 1
            }) { (finished) in
                if finished {
                    self.imgvTemp.removeFromSuperview()
                    self.bgView.removeFromSuperview()
                }
            }
            //调用取消pop
            self.cancel()
        }
        // 关闭手势
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
            // push的话是简单的放大效果，动画用imgvTemp跟bgView实现
            toVC.view.isHidden = true
            container.addSubview(toVC.view)
            // 动画只针对groupvc<->pagevc之间的转换
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
            // pop需要判定是否是滑动缩小手势
            container.insertSubview(toVC.view, at: 0)
            var endFrame = CGRect.zero
            self.imgvTemp.mask = nil
            
            if let pageVC = fromVC as? ZKPhotoShowPageViewController, let contentVC = pageVC.viewControllers?.first as? ZKPhotoShowContentViewController {
                //初始化相关参数
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
                //如果是滑动缩小手势，隐藏fromVC，不执行动画，只使用系统的nav转场，设置fromvc从0.01->0是为了让动画体执行。
                fromVC.view.alpha = 0.01
                UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                    fromVC.view.alpha = 0
                }) { (finished) in
                    if transitionContext.transitionWasCancelled {
                        //取消动画记得得把fromvc的透明还原
                        fromVC.view.alpha = 1
                        transitionContext.completeTransition(false)
                    }
                    else {
                        transitionContext.completeTransition(true)
                    }
                }
            }
            else {
                //如果不是滑动缩小手势，执行缩小转场动画
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
