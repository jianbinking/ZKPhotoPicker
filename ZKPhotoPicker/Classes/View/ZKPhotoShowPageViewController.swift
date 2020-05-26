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
    func assetModelAt(index: Int) -> ZKAssetModel?
    
    func cellFrameAt(index: Int) -> CGRect
    
    @objc optional func pageVC(_ pageVC: ZKPhotoShowPageViewController, didScroll2Index idx: Int)
}

class ZKPhotoShowPageViewController: UIPageViewController {
    
    var isSwipe2Pop = false
    weak var showDS_D: ZKPhotoShowDataSourceAndDelegate?
    private let _startIndex: Int;
    var picker: ZKPhotoPicker {
        return self.navigationController?.parent as! ZKPhotoPicker
    }
    var currentIndex: Int {
        get {
            if let currentVC = self.viewControllers?.first as? ZKPhotoShowContentViewController {
                return currentVC.index
            }
            return self._startIndex
        }
    }
    var currentContentVC: ZKPhotoShowContentViewController? {
        return self.viewControllers?.first as? ZKPhotoShowContentViewController
    }
    weak var currentAssetManager: ZKPhotoAssetManager? {
        didSet {
            oldValue?.assetModel.removeSelectListener(self)
            self.currentAssetManager?.assetModel.addSelectListener(self)
            self.updateTitle()
            self.updateRightNavItemImage()
        }
    }
    
    var collectionCellFrame: CGRect? {
        return self.showDS_D?.cellFrameAt(index: self.currentIndex)
    }
    private let btnSelect = UIButton.init(type: .custom)
    var interactivePopTrans: ZKPhotoShowInteractivePopTransition?
    
    init(showDataSourceAndDelegate: ZKPhotoShowDataSourceAndDelegate?, startIndex: Int) {
        self.showDS_D = showDataSourceAndDelegate
        self._startIndex = startIndex
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewController.OptionsKey.interPageSpacing: 10])
        self.delegate = self
        self.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = self.picker.config.viewBackGroundColor
        
        var tbItems = self.picker.tbItems
        if picker.config.enableLargeConfirmAsSelect {
            tbItems.removeLast()
            tbItems.append(.init(title: "确定", style: .plain, target: self, action: #selector(confirmButtonTapped)))
        }
        self.toolbarItems = tbItems
        self.btnSelect.setImage(self.picker.config.selectTagImageN, for: .normal)
        self.btnSelect.setImage(self.picker.config.selectTagImageS, for: .selected)
        
        self.btnSelect.frame = .init(x: 0, y: 0, width: 44, height: 44)
        self.btnSelect.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: self.btnSelect)
        
        guard let assetModel = self.showDS_D?.assetModelAt(index: self.currentIndex) else {
            return
        }
        
        let startVC = ZKPhotoShowContentViewController.contentVCWith(index: self.currentIndex, assetManager: .init(model: assetModel), pageVC: self)
        self.setViewControllers([startVC], direction: .forward, animated: false, completion: nil)
        self.currentAssetManager = startVC.assetManager
        

        self.interactivePopTrans = .init(pageVC: self)
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
            self.btnSelect.isSelected = assetMN.assetModel.isSelected
        }
    }
    
    @objc private func selectButtonTapped() {
        
        if let contentVC = self.viewControllers?.first as? ZKPhotoShowContentViewController {
            contentVC.assetManager.assetModel.selectTap()
        }
    }
    
    @objc private func confirmButtonTapped() {
        if picker.selectedAssets.count == 0, let currentAsset = self.currentAssetManager?.assetModel.asset {
            picker.didSelect(asset: currentAsset)
        }
        picker.completeSelect()
    }
}

extension ZKPhotoShowPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let preIdx = self.currentIndex - 1
        guard preIdx >= 0 ,
            let itemCount = self.showDS_D?.numberOfAssets(),
            preIdx < itemCount,
            let preModel = self.showDS_D?.assetModelAt(index: preIdx) else {
            return nil
        }
        return ZKPhotoShowContentViewController.contentVCWith(index: preIdx, assetManager: .init(model: preModel), pageVC: self)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let nextIdx = self.currentIndex + 1
        guard nextIdx >= 0 ,
            let itemCount = self.showDS_D?.numberOfAssets(),
            nextIdx < itemCount,
            let nextModel = self.showDS_D?.assetModelAt(index: nextIdx) else {
            return nil
        }
        return ZKPhotoShowContentViewController.contentVCWith(index: nextIdx, assetManager: .init(model: nextModel), pageVC: self)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished , completed, let contentVC = self.currentContentVC {
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

extension ZKPhotoShowPageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer, pan.view == self.view {
            return self.currentContentVC!.canStartSwipe2Close(pan: pan)
        }
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
