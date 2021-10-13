//
//  StickersView.swift
//  VK-total
//
//  Created by Сергей Никитин on 27.08.2021.
//  Copyright © 2021 Sergey Nikitin. All rights reserved.
//

import UIKit
import Popover

class StickersView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var delegate: UIViewController!
    
    var width: CGFloat = UIScreen.main.bounds.width
    var height: CGFloat = UIScreen.main.bounds.width
    var sWidth: CGFloat = 0
    
    var stickersIndex = 0
    
    var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.up),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6)),
        .color(vkSingleton.shared.backColor)
    ]
    
    var collectionView1: UICollectionView!
    var collectionView2: UICollectionView!
    
    func configure(width: CGFloat) {
        self.backgroundColor = vkSingleton.shared.backColor
        
        self.width = width
        self.height = width + 90
        self.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        
        let layout1: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout1.scrollDirection = .horizontal
        layout1.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        layout1.itemSize = CGSize(width: 45, height: 45)
        
        collectionView1 = UICollectionView(frame: CGRect(x: 10, y: self.height - 60, width: self.width - 20, height: 50), collectionViewLayout: layout1)
        collectionView1.tag = 1
        collectionView1.delegate = self
        collectionView1.dataSource = self
        collectionView1.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "titleCell")
        collectionView1.backgroundColor = .clear
        collectionView1.showsVerticalScrollIndicator = false
        collectionView1.showsHorizontalScrollIndicator = false
        
        self.addSubview(collectionView1)
        
        sWidth = (self.width - 20) / 4 - 10
        let layout2: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout2.scrollDirection = .vertical
        layout2.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout2.itemSize = CGSize(width: sWidth, height: sWidth)
        
        collectionView2 = UICollectionView(frame: CGRect(x: 10, y: 10, width: self.width - 20, height: self.width), collectionViewLayout: layout2)
        collectionView2.tag = 2
        collectionView2.delegate = self
        collectionView2.dataSource = self
        collectionView2.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "stickerCell")
        collectionView2.backgroundColor = .clear
        collectionView2.showsVerticalScrollIndicator = true
        collectionView2.showsHorizontalScrollIndicator = false
        
        self.addSubview(collectionView2)
    }
    
    func show(fromView view: UIView) {
        self.popover = Popover(options: self.popoverOptions)
        self.popover.show(self, fromView: view)
    }
    
    func hide() {
        self.popover.dismiss()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView.tag == 2 {
            let count1: Int = vkSingleton.shared.stickers[stickersIndex].stickers.count / 4
            let count2: Int = vkSingleton.shared.stickers[stickersIndex].stickers.count % 4
            return count2 == 0 ? count1 : count1 + 1
        }
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 2 {
            let count1: Int = vkSingleton.shared.stickers[stickersIndex].stickers.count / 4
            let count2: Int = vkSingleton.shared.stickers[stickersIndex].stickers.count % 4
            let sectionsCount = count2 == 0 ? count1 : count1 + 1
            
            if section < sectionsCount - 1 { return 4 }
            return count2 == 0 ? 4 : count2
        }
        
        return vkSingleton.shared.stickers.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if collectionView.tag == 2 { return sWidth }
        return 45
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "titleCell", for: indexPath)
            
            for subview in cell.subviews {
                if subview is UIButton { subview.removeFromSuperview() }
            }
            
            let menuButton = UIButton()
            menuButton.tag = indexPath.row
            menuButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            menuButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
            
            let url = vkSingleton.shared.stickers[indexPath.item].previewURL
            let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    menuButton.setImage(getCacheImage.outputImage, for: .normal)
                    
                    menuButton.layer.cornerRadius = 10
                    menuButton.layer.borderColor = UIColor.gray.cgColor
                    menuButton.layer.borderWidth = 1
                    
                    if indexPath.item == self.stickersIndex {
                        menuButton.backgroundColor = vkSingleton.shared.mainColor.withAlphaComponent(0.5)
                        menuButton.layer.cornerRadius = 10
                        menuButton.layer.borderColor = vkSingleton.shared.mainColor.cgColor
                        menuButton.layer.borderWidth = 1
                    }
                }
            }
            OperationQueue().addOperation(getCacheImage)
        
            menuButton.add(for: .touchUpInside) {
                self.stickersIndex = menuButton.tag
                self.collectionView1.reloadData()
                self.collectionView2.reloadData()
                self.collectionView2.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            }
            
            cell.addSubview(menuButton)
            return cell
        }
        
        if collectionView.tag == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stickerCell", for: indexPath)
            
            for subview in cell.subviews {
                if subview is UIButton { subview.removeFromSuperview() }
            }
            
            let index: Int = indexPath.section * 4 + indexPath.row
            let sticker = vkSingleton.shared.stickers[stickersIndex].stickers[index]
            
            let sButton = UIButton()
            sButton.tag = sticker.stickerID
            sButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            sButton.frame = CGRect(x: 0, y: 0, width: sWidth, height: sWidth)
            
            
            
            let url = sticker.url
            let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    sButton.setImage(getCacheImage.outputImage, for: .normal)
                }
            }
            OperationQueue().addOperation(getCacheImage)
        
            sButton.add(for: .touchUpInside) {
                let guid = "\(Date().timeIntervalSince1970)"
                
                if let vc = self.delegate as? Record2Controller {
                    vc.createRecordComment(text: "", attachments: "", replyID: 0, guid: guid, stickerID: sButton.tag, controller: vc)
                } else if let vc = self.delegate as? VideoController {
                    vc.createVideoComment(text: "", attachments: "", stickerID: sButton.tag, replyID: 0, guid: guid, controller: vc)
                } else if let vc = self.delegate as? TopicController {
                    vc.createTopicComment(text: "", attachments: "", stickerID: sButton.tag, guid: guid, controller: vc)
                } else if let vc = self.delegate as? DialogController {
                    vc.sendMessage(message: "", attachment: "", fwdMessages: "", stickerID: sButton.tag, controller: vc)
                } else if let vc = self.delegate as? GroupDialogController {
                    vc.sendMessageGroupDialog(message: "", attachment: "", fwdMessages: "", stickerID: sButton.tag, controller: vc)
                }
                
                self.hide()
            }
            
            cell.addSubview(sButton)
            return cell
        }
        
        return UICollectionViewCell()
    }
}
