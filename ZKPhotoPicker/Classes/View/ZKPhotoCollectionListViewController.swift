//
//  ZKPhotoCollectionListViewController.swift
//  ZKPhotoPicker
//
//  Created by CallMeDoby on 2020/5/8.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos

class ZKPhotoCollectionListViewController: ZKBaseViewController {
    
    var manager: ZKPhotoCollectionManager!
    private var collectionView: UICollectionView!
    
    init(collectionModel: ZKAssetCollectionModel) {
        super.init(nibName: nil, bundle: nil)
        self.manager = .init(model: collectionModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = self.manager.picker.config.viewBackGroundColor
        self.title = self.manager.title
        
        self.toolbarItems = self.manager.picker.tbItems
        
        let flowLayout = ZKPhotoCollectionFlowLayout.init(collectionModel: self.manager.collectionModel)
        flowLayout.itemCount = self.manager.assetCount
        
        self.collectionView = UICollectionView.init(frame: self.view.bounds.inset(by: self.view.safeAreaInsets), collectionViewLayout: flowLayout)
        self.collectionView.backgroundColor = self.manager.picker.config.viewBackGroundColor
        self.collectionView.contentInsetAdjustmentBehavior = .never
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(ZKPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.view.addSubview(self.collectionView)
        
        self.showHud()
        self.manager.requestAssets {
            [weak self] in
            self?.hideHud()
            self?.collectionView.reloadData()
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.collectionView.frame = self.view.bounds.inset(by: self.view.safeAreaInsets)
    }

}

extension ZKPhotoCollectionListViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.manager.assetModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ZKPhotoCollectionViewCell
        cell.assetModel = self.manager.assetModels[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let insets = self.manager.picker.delegate?.sectionInset?(in: self.manager.collectionModel.collection) {
            return insets
        }
        return .init(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let pagevc = ZKPhotoShowPageViewController.init(showDataSourceAndDelegate: self, startIndex: indexPath.item)
        self.navigationController?.pushViewController(pagevc, animated: true)
    }
    
}

extension ZKPhotoCollectionListViewController: ZKPhotoShowDataSourceAndDelegate {
    
    func numberOfAssets() -> Int {
        return self.manager.assetCount
    }
    
    func assetModelAt(index: Int) -> ZKAssetModel? {
        return self.manager.assetModels[index]
    }
    
    func cellFrameAt(index: Int) -> CGRect {
        //根据layout拿到动画cell的frame
        let cellFrame = self.collectionView.layoutAttributesForItem(at: .init(item: index, section: 0))!.frame
        //转换到self.view的坐标系
        return self.view.convert(cellFrame, from: self.collectionView)
    }
    
    func pageVC(_ pageVC: ZKPhotoShowPageViewController, didScroll2Index idx: Int) {
        //这个visibleItems里木有顺序，所以要先排下序，比较最大最小值
        let sortedIndexPaths = self.collectionView.indexPathsForVisibleItems.sorted(by: {$0<$1})
        //如果超出顶部，移动collectionview到顶
        if let topIndexPath = sortedIndexPaths.first, idx < topIndexPath.item {
            self.collectionView.scrollToItem(at: .init(item: idx, section: 0), at: .top, animated: false)
        }
        //超出底部，移动collectionview到底
        else if let bottomIndexPath = sortedIndexPaths.last, idx > bottomIndexPath.item {
            self.collectionView.scrollToItem(at: .init(item: idx, section: 0), at: .bottom, animated: true)
        }
    }
    
}
