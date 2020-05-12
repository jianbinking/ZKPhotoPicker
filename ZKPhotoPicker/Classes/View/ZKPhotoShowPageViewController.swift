//
//  ZKPhotoShowPageViewController.swift
//  ZKPhotoPicker
//
//  Created by Doby on 2020/5/9.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos

@objc protocol ZKPhotoShowDataSourceAndDelegate {
    func numberOfAssets() -> Int
    func assetManagerAt(index: Int) -> ZKPhotoAssetManager?
    
    func cellFrameAt(index: Int) -> CGRect
    
    @objc optional func pageVC(_ pageVC: ZKPhotoShowPageViewController, didScroll2Index idx: Int)
}

class ZKPhotoShowPageViewController: UIPageViewController {
    
    var isSwipe2Pop = false
    weak var showDS_D: ZKPhotoShowDataSourceAndDelegate?
    private let _startIndex: Int;
    var currentIndex: Int {
        get {
            if let currentVC = self.viewControllers?.first as? ZKPhotoShowContentViewController {
                return currentVC.index
            }
            return self._startIndex
        }
    }
    weak var currentAssetManager: ZKPhotoAssetManager? {
        didSet {
            oldValue?.removeSelectListener(self)
            self.currentAssetManager?.addSelectListener(self)
            self.updateTitle()
            self.updateRightNavItemImage()
        }
    }
    
    var trans: ZKPhotoShowTransition
    private weak var closePan: UIPanGestureRecognizer?
    var collectionCellFrame: CGRect? {
        return self.showDS_D?.cellFrameAt(index: self.currentIndex)
    }
    private let btnSelect = UIButton.init(type: .custom)
    
    init(showDataSourceAndDelegate: ZKPhotoShowDataSourceAndDelegate?, startIndex: Int) {
        self.showDS_D = showDataSourceAndDelegate
        self._startIndex = startIndex
        self.trans = ZKPhotoShowTransition()
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewController.OptionsKey.interPageSpacing: 10])
        self.delegate = self
        self.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ZKPhotoPicker.current?.config.viewBackGroundColor
        
        if let picker = ZKPhotoPicker.current {
            var tbItems = picker.tbItems
            if picker.config.enableLargeConfirmAsSelect {
                tbItems.removeLast()
                tbItems.append(.init(title: "确定", style: .plain, target: self, action: #selector(confirmButtonTapped)))
            }
            self.toolbarItems = tbItems
            self.btnSelect.setImage(picker.config.selectTagImageN, for: .normal)
            self.btnSelect.setImage(picker.config.selectTagImageS, for: .selected)
        }
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panGes(_:)))
        pan.delegate = self
        self.view.addGestureRecognizer(pan)
        self.closePan = pan
        self.btnSelect.frame = .init(x: 0, y: 0, width: 44, height: 44)
        self.btnSelect.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: self.btnSelect)
        
        guard let assetMN = self.showDS_D?.assetManagerAt(index: self.currentIndex) else {
            return
        }
        
        let startVC = ZKPhotoShowContentViewController.init(index: self.currentIndex, assetManager: assetMN, pageVC: self)
        self.setViewControllers([startVC], direction: .forward, animated: false, completion: nil)
        self.currentAssetManager = startVC.assetManager
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    private func updateTitle() {
        if let vc = self.viewControllers?.first as? ZKPhotoShowContentViewController, let assetCount = self.showDS_D?.numberOfAssets() {
            self.title = "\(vc.index + 1)/\(assetCount)"
        }
    }
    
    private func updateRightNavItemImage() {
        if let assetMN = self.currentAssetManager {
            self.btnSelect.isSelected = assetMN.isSelected
        }
    }
    
    @objc private func selectButtonTapped() {
        
        if let contentVC = self.viewControllers?.first as? ZKPhotoShowContentViewController {
            contentVC.assetManager.selectTap()
        }
    }
    
    @objc private func confirmButtonTapped() {
        if let picker = ZKPhotoPicker.current {
            if picker.selectedAssets.count == 0, let currentAsset = self.currentAssetManager?.asset {
                picker.didSelect(asset: currentAsset)
            }
        }
        ZKPhotoPicker.current?.completeSelect()
    }
    
    @objc private func panGes(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            self.navigationController?.setToolbarHidden(false, animated: false)
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.trans.isInteractive = true
            self.navigationController?.popViewController(animated: true)
        case .changed:
            let vector = pan.translation(in: self.view)
            self.trans.updateTempImage(vector: vector)
        case .ended:
            let vector = pan.translation(in: self.view)
            if vector.y > 150 {
                self.trans.endGesTransform(finish: true, endFrame: self.showDS_D?.cellFrameAt(index: self.currentIndex) ?? .zero)
            }
            else {
                self.trans.endGesTransform(finish: false, endFrame: .zero)
            }
        default:
            break
        }
    }
}

extension ZKPhotoShowPageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer,
            pan == self.closePan,
            let currentVC = self.viewControllers?.first as? ZKPhotoShowContentViewController{
            return currentVC.canStartSwipe2Close(pan: pan)
        }
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.closePan {
            return true
        }
        return false
    }
    
}

extension ZKPhotoShowPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let preIdx = self.currentIndex - 1
        guard preIdx >= 0 ,
            let itemCount = self.showDS_D?.numberOfAssets(),
            preIdx < itemCount,
            let preManager = self.showDS_D?.assetManagerAt(index: preIdx) else {
            return nil
        }
        return ZKPhotoShowContentViewController.init(index: preIdx, assetManager: preManager, pageVC: self)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let nextIdx = self.currentIndex + 1
        guard nextIdx >= 0 ,
            let itemCount = self.showDS_D?.numberOfAssets(),
            nextIdx < itemCount,
            let preManager = self.showDS_D?.assetManagerAt(index: nextIdx) else {
            return nil
        }
        return ZKPhotoShowContentViewController.init(index: nextIdx, assetManager: preManager, pageVC: self)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished , completed, let contentVC = pageViewController.viewControllers?.first as? ZKPhotoShowContentViewController {
            self.showDS_D?.pageVC?(self, didScroll2Index: contentVC.index)
            self.currentAssetManager = contentVC.assetManager
        }
        self.updateTitle()
    }
}

extension ZKPhotoShowPageViewController: ZKPhotoAssetSelectedListener {
    func assetSelectedChange(isSelected: Bool) {
        self.updateRightNavItemImage()
    }
}
