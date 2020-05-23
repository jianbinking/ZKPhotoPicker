//
//  ZKPhotoGroupViewController.swift
//  ZKPhotoPicker
//
//  Created by Doby on 2020/5/8.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos

class ZKPhotoGroupViewController: ZKBaseViewController {

    private let groupManager: ZKPhotoGroupManager
    private lazy var tableView: UITableView = .init(frame: self.view.bounds, style: .plain)
    
    init(picker: ZKPhotoPicker) {
        self.groupManager = .init(picker: picker)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.groupManager.picker.config.mediaType.desc
        self.view.backgroundColor = self.groupManager.picker.config.viewBackGroundColor
        
        self.toolbarItems = self.groupManager.picker.tbItems
        
        self.tableView.backgroundColor = self.groupManager.picker.config.viewBackGroundColor
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(ZKPhotoGroupTableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        
        self.navigationItem.leftBarButtonItem = .init(title: "取消", style: .plain, target: self, action: #selector(close))
        
        self.showHud()
        self.groupManager.requestCollections {
            [weak self] in
            self?.hideHud()
            self?.tableView.reloadData()
        }
        
//        let defaultCollectionModel: ZKAssetCollectionModel? = self.groupManager.collectionModels.first(where: {
//            model in
//            if let isDefault = self.picker.delegate?.photoPicker?(picker: self.picker, isDefaultCollection: model.collection),
//                isDefault {
//                return true
//            }
//            return false
//        })
//        if let model = defaultCollectionModel {
//            self.navigationController?.pushViewController(ZKPhotoCollectionListViewController.init(collectionManager: mn), animated: false)
//        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView.frame = self.view.bounds.inset(by: self.view.safeAreaInsets)
    }
    
    //MARK: - private method
    
    @objc private func close() {
        self.groupManager.picker.dismiss(animated: true) {
            
            self.groupManager.picker.delegate?.photoPickerDidCancelPick?(picker: self.groupManager.picker)
        }
    }


}

extension ZKPhotoGroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupManager.collectionModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ZKPhotoGroupTableViewCell
        let model = self.groupManager.collectionModels[indexPath.row]
        cell.loadCollectionModel(model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(ZKPhotoCollectionListViewController.init(collectionModel: self.groupManager.collectionModels[indexPath.row]), animated: true)
    }
    
}
