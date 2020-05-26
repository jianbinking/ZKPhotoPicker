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



public class ZKPhotoPicker: UIViewController {
    
    public var selectedAssets: [PHAsset] = [] {
        didSet {
            self.updateBarButtons()
        }
    }
    public weak var delegate: ZKPhotoPickerDelegate?
    public let config: ZKPhotoPickerConfig
    let defaultImage: UIImage
    
    internal let cachingImageManager = ZKPhotoCachingImageManager()
    private var barBtnCount = UIBarButtonItem.init(title: "已选(0)", style: .plain, target: nil, action: nil)
    private var barBtnConfirm = UIBarButtonItem.init(title: "确定", style: .plain, target: nil, action: nil)
    
    //MARK: - public funcs
    
    public init(_ config: ZKPhotoPickerConfig) {
        self.config = config
        //读取自定义bundle里的image
        defaultImage = config.loadBundleImage(for: "image_placeholder")
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
        self.barBtnCount.target = self
        self.barBtnCount.action = #selector(countButtonTapped)
        self.barBtnConfirm.target = self
        self.barBtnConfirm.action = #selector(confirmButtonTapped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                    let picker = ZKPhotoPicker.init(config)
                    picker.delegate = delegate
                    picker.selectedAssets = selectedAssets ?? []
                    vc.present(picker, animated: true, completion: nil)
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        let groupVC = ZKPhotoGroupViewController.init(picker: self)
        let nav = UINavigationController.init(rootViewController: groupVC)
        nav.modalPresentationStyle = .fullScreen
        nav.isToolbarHidden = false
        nav.delegate = self
        nav.interactivePopGestureRecognizer?.delegate = self
        
        nav.willMove(toParent: self)
        self.view.addSubview(nav.view)
        self.addChild(nav)
        nav.didMove(toParent: self)
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
        self.dismiss(animated: true, completion: {
            _currentPicker = nil
        })
    }
    
    internal func cancelSelect() {
        self.delegate?.photoPickerDidCancelPick?(picker: self)
        self.dismiss(animated: true, completion: {
            _currentPicker = nil
        })
    }
}


extension ZKPhotoPicker: UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        var trans: ZKPhotoShowTransition? = nil
        
        if let _ = fromVC as? ZKPhotoCollectionListViewController, let _ = toVC as? ZKPhotoShowPageViewController, operation == .push {
            trans = .init()
            trans?.isPush = true
        }
        else if let pageVC = fromVC as? ZKPhotoShowPageViewController, let _ = toVC as? ZKPhotoCollectionListViewController, operation == .pop {
            trans = .init()
            trans?.pageVC = pageVC
            trans?.isPush = false
        }
        
        return trans
    }
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let trans = animationController as? ZKPhotoShowTransition, let pageVC = trans.pageVC, let interactiveTrans = pageVC.interactivePopTrans, interactiveTrans.isInteractive {
            return interactiveTrans
        }
        return nil
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let nav = self.children.first as? UINavigationController, nav.navigationBar.alpha == 0 {
            return false
        }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


class ZKBaseViewController: UIViewController {
    
    func showHud(message: String = "") {
        var hud: UIView!
        var lbl: UILabel!
        if let h = self.view.viewWithTag(100881) {
            hud = h
            lbl = (hud.viewWithTag(100882) as? UILabel)!
        }
        else {
            let height = message.isEmpty ? 100 : 100
            hud = UIView.init(frame: .init(x: 0, y: 0, width: 100, height: height))
            hud.tag = 100881
            hud.backgroundColor = .black
            hud.layer.cornerRadius = 16
            hud.clipsToBounds = true
            let indicator = UIActivityIndicatorView.init(frame: .init(x: 0, y: 0, width: 100, height: 100))
            indicator.style = .large
            indicator.hidesWhenStopped = true
            indicator.color = .white
            hud.addSubview(indicator)
            indicator.startAnimating()
            lbl = UILabel.init(frame: .init(x: 0, y: 100, width: 100, height: 30))
            lbl.textAlignment = .center
            lbl.textColor = .white
            lbl.tag = 100882
            hud.addSubview(lbl)
        }
        lbl.text = message
        hud.alpha = 0
        self.view.addSubview(hud)
        hud.center = self.view.center
        UIView.animate(withDuration: 0.3) {
            hud.alpha = 1
        }
    }
    
    func hideHud() {
        if let hud = self.view.viewWithTag(100881) {
            UIView.animate(withDuration: 0.3, animations: {
                hud.alpha = 0
            }, completion: {
                _ in
                hud.removeFromSuperview()
            })
        }
        
    }
    
}
