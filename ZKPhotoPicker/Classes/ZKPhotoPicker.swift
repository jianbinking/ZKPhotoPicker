//
//  ZKPhotoPicker.swift
//  ZKPhotoPicker
//
//  Created by Doby on 2020/5/11.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos


private var _currentPicker: ZKPhotoPicker?

public class ZKPhotoPicker: NSObject {
    
    public var selectedAssets: [PHAsset] = [] {
        didSet {
            self.updateBarButtons()
        }
    }
    public weak var delegate: ZKPhotoPickerDelegate?
    public let config: ZKPhotoPickerConfig
    
    internal let cachingImageManager = ZKPhotoCachingImageManager()
    private var barBtnCount = UIBarButtonItem.init(title: "已选(0)", style: .plain, target: nil, action: nil)
    private var barBtnConfirm = UIBarButtonItem.init(title: "确定", style: .plain, target: nil, action: nil)
    private var nav: UINavigationController?
    
    //MARK: - public funcs
    
    public init(_ config: ZKPhotoPickerConfig) {
        self.config = config
        super.init()
        self.barBtnCount.target = self
        self.barBtnCount.action = #selector(countButtonTapped)
        self.barBtnConfirm.target = self
        self.barBtnConfirm.action = #selector(confirmButtonTapped)
    }
    
    @objc public static func showPickerView(in vc: UIViewController,
                               delegate: ZKPhotoPickerDelegate,
                               config: ZKPhotoPickerConfig = .init(),
                               selectedAssets: [PHAsset]? = nil,
                               authorizeFailHandle:@escaping (PHAuthorizationStatus) -> Void) {
        
        PHPhotoLibrary.requestAuthorization {
            status in
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    _currentPicker = ZKPhotoPicker.init(config)
                    self.current?.delegate = delegate
                    self.current?.selectedAssets = selectedAssets ?? []
                    let groupVC = ZKPhotoGroupViewController()
                    let nav = UINavigationController.init(rootViewController: groupVC)
                    nav.modalPresentationStyle = .fullScreen
                    nav.isToolbarHidden = false
                    self.current?.nav = nav
                    nav.delegate = self.current
                    nav.interactivePopGestureRecognizer?.delegate = self.current
                    vc.present(nav, animated: true, completion: nil)
                }
            case .denied:
                authorizeFailHandle(.denied)
            case .notDetermined:
                return
            case .restricted:
                authorizeFailHandle(.restricted)
            default:
                return
            }
        }
    }
    
    //MARK: - private funcs
    
    private func updateBarButtons() {
        self.barBtnCount.title = "已选(\(self.selectedAssets.count))"
        self.barBtnConfirm.isEnabled = self.selectedAssets.count > 0
    }
    
    @objc private func countButtonTapped() {
        print("个数个数")
    }
    
    @objc private func confirmButtonTapped() {
        self.completeSelect()
    }
    
}

extension ZKPhotoPicker {
    
    internal static var current: ZKPhotoPicker? {
        return _currentPicker
    }
    internal var tbItems: [UIBarButtonItem] {
        return [self.barBtnCount, .init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), self.barBtnConfirm]
    }
    
    internal func isAssetSelected(_ asset: PHAsset) -> Bool {
        return self.selectedAssets.contains{$0.localIdentifier == asset.localIdentifier}
    }
    
    internal func didSelect(asset: PHAsset) {
        self.selectedAssets.append(asset)
        self.updateBarButtons()
    }
    
    internal func didDeselect(asset: PHAsset) {
        self.selectedAssets.removeAll(where: {$0.localIdentifier == asset.localIdentifier})
        self.delegate?.photoPicker?(picker: self, didDeselectAsset: asset)
        self.updateBarButtons()
    }
    
    internal func completeSelect() {
        self.delegate?.photoPicker?(picker: self, didFinishPick: self.selectedAssets)
        self.nav?.dismiss(animated: true, completion: {
            _currentPicker = nil
        })
    }
    
    internal func cancelSelect() {
        self.delegate?.photoPickerDidCancelPick?(picker: self)
        self.nav?.dismiss(animated: true, completion: {
            _currentPicker = nil
        })
    }
}


extension ZKPhotoPicker: UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        
        if let pageVC = fromVC as? ZKPhotoShowPageViewController {
            pageVC.trans.isPush = false
            return pageVC.trans
        }
        else if let pageVC = toVC as? ZKPhotoShowPageViewController {
            pageVC.trans.isPush = true
            return pageVC.trans
        }
        return nil
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let testTrans = animationController as? ZKPhotoShowTransition {
            return testTrans.isInteractive ? testTrans : nil
        }
        return nil
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
}
