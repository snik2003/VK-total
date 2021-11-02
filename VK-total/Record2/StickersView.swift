//
//  StickersView.swift
//  VK-total
//
//  Created by Сергей Никитин on 27.08.2021.
//  Copyright © 2021 Sergey Nikitin. All rights reserved.
//

import UIKit
import Popover

class StickersView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    var delegate: VkOperationProtocol!
    
    var width: CGFloat = UIScreen.main.bounds.width
    var height: CGFloat = UIScreen.main.bounds.width
    
    var sWidth: CGFloat = 0
    var bWidth: CGFloat = 0
    
    var stickersIndex = 0
    
    var leftShape = UIImageView()
    var rightShape = UIImageView()
    var nameLabel = UILabel()
    
    var popover: Popover!
    
    var collectionView1: UICollectionView!
    var collectionView2: UICollectionView!
    
    func configure(width: CGFloat) {
        
        self.backgroundColor = vkSingleton.shared.backPopupColor
        
        self.bWidth = (self.width - 60) / 5.0
        
        self.width = width
        self.height = width + bWidth + 100
        
        nameLabel.font = UIFont(name: "Verdana-Bold", size: 14)
        nameLabel.textColor = vkSingleton.shared.labelPopupColor
        nameLabel.numberOfLines = 2
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.75
        nameLabel.textAlignment = .center
        nameLabel.text = vkSingleton.shared.stickers.first?.title.uppercased()
        nameLabel.frame = CGRect(x: 20, y: 5, width: self.width - 40, height: 30)
        self.addSubview(nameLabel)
        
        var targetText = ""
        if let delegate = self.delegate {
            if delegate is DialogController || delegate is GroupDialogController {
                targetText = " в сообщение"
            } else if delegate is TopicController {
                targetText = " в комментарий к обсуждению"
            } else if delegate is VideoController {
                targetText = " в комментарий к видеозаписи"
            } else if delegate is Record2Controller {
                targetText = " в комментарий к записи"
            }
        }
        
        let hintLabel = UILabel()
        hintLabel.font = UIFont(name: "Verdana", size: 9)
        hintLabel.textColor = vkSingleton.shared.labelPopupColor
        hintLabel.alpha = 0.6
        hintLabel.numberOfLines = 4
        hintLabel.adjustsFontSizeToFitWidth = true
        hintLabel.minimumScaleFactor = 0.5
        hintLabel.textAlignment = .center
        hintLabel.text = "Быстрое нажатие на стикер отправляет его\(targetText). Долгое нажатие на стикер (более одной секунды) позволяет его добавить в раздел «Избранные стикеры»."
        hintLabel.frame = CGRect(x: 10, y: self.height - 48, width: self.width - 20, height: 40)
        self.addSubview(hintLabel)
        
        self.bWidth = (self.width - 60) / 5.0 - 10
        print("button width = \(bWidth)")
        let layout1: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout1.scrollDirection = .horizontal
        layout1.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout1.itemSize = CGSize(width: bWidth, height: bWidth)
        
        var frame1 = CGRect(x: 30, y: self.height - bWidth - 55, width: self.width - 60, height: bWidth)
        if vkSingleton.shared.stickers.count <= 5 {
            let width = (bWidth + 10) * CGFloat(vkSingleton.shared.stickers.count)
            let leftX = (self.width - 60 - width) / 2
            frame1 = CGRect(x: 30 + leftX, y: self.height - bWidth - 55, width: width, height: bWidth)
        }
        
        collectionView1 = UICollectionView(frame: frame1, collectionViewLayout: layout1)
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
        
        let frame2 = CGRect(x: 10, y: 40, width: self.width - 20, height: self.width)
        collectionView2 = UICollectionView(frame: frame2, collectionViewLayout: layout2)
        collectionView2.tag = 2
        collectionView2.delegate = self
        collectionView2.dataSource = self
        collectionView2.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "stickerCell")
        collectionView2.backgroundColor = .clear
        collectionView2.showsVerticalScrollIndicator = false
        collectionView2.showsHorizontalScrollIndicator = false
        self.addSubview(collectionView2)
        
        if vkSingleton.shared.stickers.count > 5 {
            let topY = self.height - bWidth - 55 + (bWidth - 16) / 2;
            
            leftShape.frame = CGRect(x: 12, y: topY, width: 9, height: 16)
            leftShape.image = UIImage(named: "shape-left")
            leftShape.tintColor = vkSingleton.shared.secondaryLabelPopupColor
            self.addSubview(leftShape)
            
            rightShape.frame = CGRect(x: self.width - 21, y: topY, width: 9, height: 16)
            rightShape.image = UIImage(named: "shape-right")
            rightShape.tintColor = vkSingleton.shared.secondaryLabelPopupColor
            self.addSubview(rightShape)
            
            leftShape.isHidden = true
            rightShape.isHidden = false
        }
        
        self.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height)
    }
    
    func show(fromView view: UIView) {
        
        let popoverOptions: [PopoverOption] = [
            .type(.up),
            .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6)),
            .color(vkSingleton.shared.backPopupColor)
        ]
        
        self.popover = Popover(options: popoverOptions)
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
        return bWidth
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == collectionView1 { return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5) }
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
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
            menuButton.frame = CGRect(x: 0, y: 0, width: bWidth, height: bWidth)
            
            menuButton.backgroundColor = vkSingleton.shared.labelPopupColor.withAlphaComponent(0.2)
            menuButton.layer.cornerRadius = 6
            menuButton.layer.borderWidth = 1.5
            menuButton.layer.borderColor = vkSingleton.shared.secondaryLabelPopupColor.cgColor
            
            if indexPath.item == stickersIndex {
                menuButton.backgroundColor = vkSingleton.shared.labelPopupColor.withAlphaComponent(0.6)
            }
            
            let stickers = vkSingleton.shared.stickers[indexPath.item]
            
            if stickers.id == 0 {
                menuButton.setImage(UIImage(named: "favorite"), for: .normal)
                //menuButton.setImage(UIImage(named: "favorite-stickers"), for: .normal)
            } else {
                let url = stickers.previewURL
                let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        menuButton.setImage(getCacheImage.outputImage, for: .normal)
                    }
                }
                OperationQueue().addOperation(getCacheImage)
            }
        
            menuButton.add(for: .touchUpInside) {
                self.stickersIndex = menuButton.tag
                self.nameLabel.text = vkSingleton.shared.stickers[self.stickersIndex].title.uppercased()
                
                self.collectionView1.reloadData()
                self.collectionView2.reloadData()
                
                self.collectionView2.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                self.collectionView1.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
            
            cell.addSubview(menuButton)
            return cell
        }
        
        if collectionView.tag == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stickerCell", for: indexPath)
            
            for subview in cell.subviews {
                if subview is UIImageView { subview.removeFromSuperview() }
            }
            
            let index: Int = indexPath.section * 4 + indexPath.row
            
            let stickers = vkSingleton.shared.stickers[stickersIndex]
            let sticker = stickers.stickers[index]
            
            let sImageView = UIImageView()
            sImageView.tag = sticker.stickerID
            sImageView.contentMode = .scaleAspectFit
            sImageView.frame = CGRect(x: 8, y: 8, width: sWidth - 16, height: sWidth - 16)
            
            sImageView.backgroundColor = .clear
            sImageView.layer.borderColor = UIColor.clear.cgColor
            sImageView.layer.cornerRadius = 0
            sImageView.layer.borderWidth = 0
            
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
            activityIndicator.clipsToBounds = true
            activityIndicator.style = .white
            activityIndicator.color = vkSingleton.shared.secondaryLabelPopupColor
            activityIndicator.center = CGPoint(x: sImageView.frame.width/2, y: sImageView.frame.height/2)
            sImageView.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            let url = sticker.url
            let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    sImageView.image = getCacheImage.outputImage
                    sImageView.alpha = stickers.active == 1 ? 1 : 0.5
                    
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()
                }
            }
            OperationQueue().addOperation(getCacheImage)
        
            let sTapGesture = UITapGestureRecognizer()
            sImageView.isUserInteractionEnabled = true
            sImageView.addGestureRecognizer(sTapGesture)
            sTapGesture.add {
                let guid = "\(Date().timeIntervalSince1970)"
                
                if let vc = self.delegate as? Record2Controller {
                    vc.checkAndAddStickersToFavorite(stickerID: sImageView.tag, success: {
                        OperationQueue.main.addOperation {
                            vc.createRecordComment(text: "", attachments: "", replyID: 0, guid: guid, stickerID: sImageView.tag, controller: vc)
                        }
                    })
                } else if let vc = self.delegate as? VideoController {
                    vc.checkAndAddStickersToFavorite(stickerID: sImageView.tag, success: {
                        OperationQueue.main.addOperation {
                            vc.createVideoComment(text: "", attachments: "", stickerID: sImageView.tag, replyID: 0, guid: guid, controller: vc)
                        }
                    })
                } else if let vc = self.delegate as? TopicController {
                    vc.checkAndAddStickersToFavorite(stickerID: sImageView.tag, success: {
                        OperationQueue.main.addOperation {
                            vc.createTopicComment(text: "", attachments: "", stickerID: sImageView.tag, guid: guid, controller: vc)
                        }
                    })
                } else if let vc = self.delegate as? DialogController {
                    vc.checkAndAddStickersToFavorite(stickerID: sImageView.tag, success: {
                        OperationQueue.main.addOperation {
                            vc.sendMessage(message: "", attachment: "", fwdMessages: "", stickerID: sImageView.tag, controller: vc)
                        }
                    })
                } else if let vc = self.delegate as? GroupDialogController {
                    vc.checkAndAddStickersToFavorite(stickerID: sImageView.tag, success: {
                        OperationQueue.main.addOperation {
                            vc.sendMessageGroupDialog(message: "", attachment: "", fwdMessages: "", stickerID: sImageView.tag, controller: vc)
                        }
                    })
                }
            
                self.hide()
            }
            
            let sLongPressGesture = UILongPressGestureRecognizer()
            sLongPressGesture.minimumPressDuration = 1.0
            sImageView.isUserInteractionEnabled = true
            sImageView.addGestureRecognizer(sLongPressGesture)
            sLongPressGesture.add {
                sImageView.backgroundColor = vkSingleton.shared.labelPopupColor.withAlphaComponent(0.2)
                sImageView.layer.borderColor = vkSingleton.shared.secondaryLabelPopupColor.cgColor
                sImageView.layer.cornerRadius = 3
                sImageView.layer.borderWidth = 0.6
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
                    sImageView.backgroundColor = .clear
                    sImageView.layer.borderColor = UIColor.clear.cgColor
                    sImageView.layer.cornerRadius = 0
                    sImageView.layer.borderWidth = 0
                }
                alertController.addAction(cancelAction)
                
                if vkSingleton.shared.containsInFavoriteStickers(stickerID: sImageView.tag) {
                    let action = UIAlertAction(title: "Удалить стикер из «Избранное»", style: .destructive) { action in
                        self.delegate.removeStickersFromFavorite(stickerID: sImageView.tag) {
                            OperationQueue.main.addOperation {
                                var frame1 = CGRect(x: 30, y: self.height - self.bWidth - 55, width: self.width - 60, height: self.bWidth)
                                if vkSingleton.shared.stickers.count <= 5 {
                                    let width = (self.bWidth + 10) * CGFloat(vkSingleton.shared.stickers.count)
                                    let leftX = (self.width - 60 - width) / 2
                                    frame1 = CGRect(x: 30 + leftX, y: self.height - self.bWidth - 55, width: width, height: self.bWidth)
                                }
                                self.collectionView1.frame = frame1
                                
                                if self.stickersIndex >= vkSingleton.shared.stickers.count { self.stickersIndex = 0 }
                                
                                self.collectionView1.reloadData()
                                self.collectionView2.reloadData()
                                
                                self.collectionView2.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                            }
                        }
                        
                        sImageView.backgroundColor = .clear
                        sImageView.layer.borderColor = UIColor.clear.cgColor
                        sImageView.layer.cornerRadius = 0
                        sImageView.layer.borderWidth = 0
                    }
                    alertController.addAction(action)
                } else {
                    let action = UIAlertAction(title: "Добавить стикер в «Избранное»", style: .default) { action in
                        self.delegate.checkAndAddStickersToFavorite(stickerID: sImageView.tag) {
                            OperationQueue.main.addOperation {
                                var frame1 = CGRect(x: 30, y: self.height - self.bWidth - 55, width: self.width - 60, height: self.bWidth)
                                if vkSingleton.shared.stickers.count <= 5 {
                                    let width = (self.bWidth + 10) * CGFloat(vkSingleton.shared.stickers.count)
                                    let leftX = (self.width - 60 - width) / 2
                                    frame1 = CGRect(x: 30 + leftX, y: self.height - self.bWidth - 55, width: width, height: self.bWidth)
                                }
                                self.collectionView1.frame = frame1
                                
                                if self.stickersIndex >= vkSingleton.shared.stickers.count { self.stickersIndex = 0 }
                                
                                self.collectionView1.reloadData()
                                self.collectionView2.reloadData()
                                
                                self.collectionView2.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                            }
                        }
                        
                        sImageView.backgroundColor = .clear
                        sImageView.layer.borderColor = UIColor.clear.cgColor
                        sImageView.layer.cornerRadius = 0
                        sImageView.layer.borderWidth = 0
                    }
                    alertController.addAction(action)
                }
                
                if let delegate = self.delegate as? UIViewController { delegate.present(alertController, animated: true) }
            }
            
            cell.addSubview(sImageView)
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
        if scrollView == collectionView1 && vkSingleton.shared.stickers.count > 5 {
            let contentOffset = scrollView.contentOffset.x
            
            if (contentOffset < 1) {
                leftShape.isHidden = true
                rightShape.isHidden = false
            } else if (contentOffset > scrollView.contentSize.width - scrollView.bounds.width - 1) {
                leftShape.isHidden = false
                rightShape.isHidden = true
            } else {
                leftShape.isHidden = false
                rightShape.isHidden = false
            }
        }
    }
}
