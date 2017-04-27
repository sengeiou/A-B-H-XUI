//
//  SelectPhotoCollectionViewController.swift
//  随心行
//
//  Created by 有限公司 深圳市 on 2017/4/25.
//  Copyright © 2017年 SMA. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

public protocol photoSelectDelegate:NSObjectProtocol {//制定协议(不写NSObjectProtocol暂时不会报错,但是写属性是无法写weak)
    func photoSlectIndex(index: Int)
}

class SelectPhotoCollectionViewController: UICollectionViewController {
    
    var imaArr: Array<UIImage> = []
    var selectIndex: Int = 0
    var delegate: photoSelectDelegate? //这里不需要用weak，‘？’可以起到相关作用
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(UINib.init(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        createUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func createUI() {
        title = Localizeable(key: "选择默认头像") as String!
        collectionView?.backgroundColor = UIColor.white
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imaArr.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        cell.image.image = imaArr[indexPath.row]
        if indexPath.row == selectIndex {
            cell.imaSelect = true
        }
        else{
            cell.imaSelect = false
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for i in 0...(imaArr.count - 1) {
            let index = IndexPath(row: i, section: 0)
            let cell = collectionView.cellForItem(at: index) as! PhotoCollectionViewCell
            cell.imaSelect = false
        }
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
         cell.imaSelect = true
        selectIndex = indexPath.row
        delegate?.photoSlectIndex(index: selectIndex)//触发，在OC中是需要用到respondsToSelector方法来判断方法是否存在的，这里的‘？’起到了这样的作用，如果没有的话delegate就为nil
    }

    
}
