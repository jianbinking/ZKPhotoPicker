//
//  ZKPhotoGroupViewController.swift
//  ZKPhotoPicker
//
//  Created by Doby on 2020/5/8.
//  Copyright © 2020 Doby. All rights reserved.
//

import UIKit
import Photos

class ZKPhotoGroupViewController: UIViewController {

    private let groupManager: ZKPhotoGroupManager = .init()
    private lazy var tableView: UITableView = .init(frame: self.view.bounds, style: .plain)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ZKPhotoPicker.current?.config.mediaType.desc
        self.view.backgroundColor = ZKPhotoPicker.current?.config.viewBackGroundColor
        
        self.toolbarItems = ZKPhotoPicker.current?.tbItems
        
        self.tableView.backgroundColor = ZKPhotoPicker.current?.config.viewBackGroundColor
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(ZKPhotoGroupTableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.tableFooterView = UIView()
        self.view.addSubview(self.tableView)
        
        self.navigationItem.leftBarButtonItem = .init(title: "取消", style: .plain, target: self, action: #selector(close))

        self.groupManager.startCachingCollectionKeyThumbImages()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView.frame = self.view.bounds.inset(by: self.view.safeAreaInsets)
    }
    
    //MARK: - private method
    
    @objc private func close() {
        ZKPhotoPicker.current?.cancelSelect()
    }


}

extension ZKPhotoGroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupManager.collections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ZKPhotoGroupTableViewCell
        let collection = self.groupManager.collections[indexPath.row]
        cell.collectionManager = collection
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(ZKPhotoCollectionListViewController.init(collectionManager: self.groupManager.collections[indexPath.row]), animated: true)
    }
    
}
