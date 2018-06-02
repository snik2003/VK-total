//
//  GroupDialogCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 14.05.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import BEMCheckBox
import SwiftyJSON

class GroupDialogCell: UITableViewCell {
    
    var delegate: GroupDialogController!
    
    var avatarImage = UIImageView()
    var messText = UILabel()
    var messView = UIView()
    var dateLabel = UILabel()
    var actLabel = UILabel()
    
    let avatarSize: CGFloat = 40
    let leftInsets: CGFloat = 5
    let topInsets: CGFloat = 15
    
    let messFont = UIFont(name: "Verdana", size: 13)!
    let fwdmFont = UIFont(name: "Verdana", size: 12)!
    let dateFont = UIFont(name: "Verdana", size: 10)!
    let actFont = UIFont(name: "Verdana", size: 11)!
    
    let inBackColor = UIColor(displayP3Red: 244/255, green: 223/255, blue: 200/255, alpha: 1)
    let outBackColor = UIColor(displayP3Red: 200/255, green: 200/255, blue: 238/255, alpha: 1)
    let actionColor = UIColor.lightGray
    
    func configureCell(dialog: DialogHistory, users: [DialogsUsers], indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView) {
        
        for subview in self.subviews {
            if subview.tag == 200 {
                subview.removeFromSuperview()
            }
        }
        
        for subview in messView.subviews {
            if subview.tag == 200 {
                subview.removeFromSuperview()
            }
        }
        
        if dialog.action == "" {
            var url = ""
            var user = users.filter({ $0.uid == "\(dialog.fromID)" })
            if dialog.out == 1 {
                user = users.filter({ $0.uid == "-\(delegate.groupID)" })
            }
            if user.count > 0 {
                url = user[0].maxPhotoOrigURL
            }
            
            messText.tag = 200
            messText.font = messFont
            messText.backgroundColor = UIColor.clear
            messText.numberOfLines = 0
            
            avatarImage.tag = 200
            let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImage, indexPath: indexPath, tableView: tableView)
            setImageToRow.addDependency(getCacheImage)
            OperationQueue().addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                self.avatarImage.layer.cornerRadius = 19
                self.avatarImage.clipsToBounds = true
                self.avatarImage.contentMode = .scaleAspectFill
                self.avatarImage.layer.borderColor = UIColor.lightGray.cgColor
                self.avatarImage.layer.borderWidth = 0.5
            }
            
            if dialog.out == 0 {
                avatarImage.frame = CGRect(x: leftInsets, y: topInsets, width: avatarSize, height: avatarSize)
            } else {
                avatarImage.frame = CGRect(x: UIScreen.main.bounds.width - leftInsets - avatarSize, y: topInsets, width: avatarSize, height: avatarSize)
            }
            
            self.addSubview(avatarImage)
            
            let tapAvatar = UITapGestureRecognizer()
            tapAvatar.add {
                if self.delegate.mode == "" {
                    self.delegate.openProfileController(id: dialog.fromID, name: "")
                }
            }
            tapAvatar.numberOfTapsRequired = 1
            avatarImage.isUserInteractionEnabled = true
            avatarImage.addGestureRecognizer(tapAvatar)
            
            
            let rect = getTextSize(text: dialog.body.prepareTextForPublic(), font: messText.font)
            
            messText.text = dialog.body
            messText.prepareTextForPublish2(self.delegate)
            
            messView.tag = 200
            messView.layer.cornerRadius = 15
            messView.layer.borderColor = UIColor.lightGray.cgColor
            messView.layer.borderWidth = 0.5
            messText.frame = CGRect(x: 10, y: 0, width: rect.width - 10, height: rect.height)
            
            var bubbleHeight: CGFloat = 0
            var bubbleWidth: CGFloat = 0
            var bubbleX: CGFloat = 0
            let bubbleY: CGFloat = topInsets
            
            
            if dialog.out == 0 {
                bubbleX = 2 * leftInsets + avatarSize
                messView.backgroundColor = inBackColor
            } else {
                bubbleX = UIScreen.main.bounds.width - 2 * leftInsets - avatarSize - rect.width - 5
                messView.backgroundColor = outBackColor
            }
            
            messView.addSubview(messText)
            
            bubbleHeight = rect.height
            bubbleWidth = rect.width + 5
            
            var attachCount = 0
            for attach in dialog.attach {
                if attach.type == "photo" && attach.photos.count > 0 {
                    attachCount += 1
                    
                    var width = 0.7 * (UIScreen.main.bounds.width - 2 * leftInsets - avatarSize)
                    var height = width
                    if attach.photos[0].width > 0 {
                        height = width * CGFloat(attach.photos[0].height) / CGFloat(attach.photos[0].width)
                    }
                    
                    let photo = UIImageView()
                    photo.tag = 200
                    let getCacheImage = GetCacheImage(url: attach.photos[0].photo604, lifeTime: .avatarImage)
                    let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: photo, indexPath: indexPath, tableView: tableView)
                    setImageToRow.addDependency(getCacheImage)
                    OperationQueue().addOperation(getCacheImage)
                    OperationQueue.main.addOperation(setImageToRow)
                    OperationQueue.main.addOperation {
                        photo.layer.cornerRadius = 12
                        photo.clipsToBounds = true
                        photo.contentMode = .scaleAspectFill
                        photo.backgroundColor = UIColor.clear
                    }
                    
                    var photoX: CGFloat = 5
                    if width > bubbleWidth {
                        bubbleWidth = width + 10
                        if dialog.out == 1 {
                            bubbleX = UIScreen.main.bounds.width - 2 * leftInsets - avatarSize - width - 10
                        }
                    } else {
                        width = bubbleWidth - 10
                        height = width
                        if attach.photos[0].width > 0 {
                            height = width * CGFloat(attach.photos[0].height) / CGFloat(attach.photos[0].width)
                        }
                        photoX = 5
                    }
                    
                    if dialog.fwdMessage.count > 0 {
                        photoX = (0.7 * UIScreen.main.bounds.width - width) / 2
                    }
                    
                    photo.frame = CGRect(x: photoX, y: bubbleHeight + 5, width: width, height: height)
                    
                    messView.addSubview(photo)
                    
                    let tap = UITapGestureRecognizer()
                    tap.add {
                        if self.delegate.mode == "" {
                            let photoViewController = self.delegate.storyboard?.instantiateViewController(withIdentifier: "photoViewController") as! PhotoViewController
                            
                            var newIndex = 0
                            if dialog.attach.count > 0 {
                                for ind in 0...dialog.attach.count-1 {
                                    if dialog.attach[ind].type == "photo" && dialog.attach[ind].photos.count > 0  {
                                        let photos = Photos(json: JSON.null)
                                        photos.uid = "\(dialog.attach[ind].photos[0].ownerID)"
                                        photos.pid = "\(dialog.attach[ind].photos[0].id)"
                                        photos.xxbigPhotoURL = dialog.attach[ind].photos[0].photo604
                                        photos.xbigPhotoURL = dialog.attach[ind].photos[0].photo604
                                        photos.bigPhotoURL = dialog.attach[ind].photos[0].photo604
                                        photos.photoURL = dialog.attach[ind].photos[0].photo604
                                        photos.width = dialog.attach[ind].photos[0].width
                                        photos.height = dialog.attach[ind].photos[0].height
                                        photos.photoAccessKey = dialog.attach[ind].photos[0].accessKey
                                        photoViewController.photos.append(photos)
                                        if dialog.attach[ind].photos[0].id == attach.photos[0].id {
                                            photoViewController.numPhoto = newIndex
                                        }
                                        newIndex += 1
                                    }
                                }
                                
                                photoViewController.delegate = self.delegate
                                
                                self.delegate.navigationController?.pushViewController(photoViewController, animated: true)
                            }
                        }
                    }
                    tap.numberOfTapsRequired = 1
                    photo.isUserInteractionEnabled = true
                    photo.addGestureRecognizer(tap)
                    
                    bubbleHeight += 5 + height
                }
                
                if attach.type == "video" && attach.videos.count > 0 {
                    attachCount += 1
                    
                    var width = 0.7 * (UIScreen.main.bounds.width - 2 * leftInsets - avatarSize)
                    var height = width * 240 / 320
                    
                    let video = UIImageView()
                    video.tag = 200
                    let getCacheImage = GetCacheImage(url: attach.videos[0].photo320, lifeTime: .avatarImage)
                    let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: video, indexPath: indexPath, tableView: tableView)
                    setImageToRow.addDependency(getCacheImage)
                    OperationQueue().addOperation(getCacheImage)
                    OperationQueue.main.addOperation(setImageToRow)
                    OperationQueue.main.addOperation {
                        video.layer.cornerRadius = 12
                        video.clipsToBounds = true
                        video.contentMode = .scaleAspectFill
                        video.backgroundColor = UIColor.clear
                    }
                    
                    var videoX: CGFloat = 5
                    if width > bubbleWidth {
                        bubbleWidth = width + 10
                        if dialog.out == 1 {
                            bubbleX = UIScreen.main.bounds.width - 2 * leftInsets - avatarSize - width - 10
                        }
                    } else {
                        width = bubbleWidth - 10
                        height = width * 240 / 320
                        
                        videoX = 5
                    }
                    
                    if dialog.fwdMessage.count > 0 {
                        videoX = (0.7 * UIScreen.main.bounds.width - width) / 2
                    }
                    
                    video.frame = CGRect(x: videoX, y: bubbleHeight + 5, width: width, height: height)
                    
                    let videoImage = UIImageView()
                    videoImage.image = UIImage(named: "video")
                    video.addSubview(videoImage)
                    videoImage.frame = CGRect(x: width / 2 - 20, y: (height - 4) / 2 - 20, width: 40, height: 40)
                    
                    let durationLabel = UILabel()
                    durationLabel.text = attach.videos[0].duration.getVideoDurationToString()
                    durationLabel.numberOfLines = 1
                    durationLabel.font = UIFont(name: "Verdana-Bold", size: 8.0)!
                    durationLabel.textAlignment = .center
                    durationLabel.contentMode = .center
                    durationLabel.textColor = UIColor.black
                    durationLabel.backgroundColor = UIColor.lightText.withAlphaComponent(0.5)
                    durationLabel.layer.cornerRadius = 6
                    durationLabel.clipsToBounds = true
                    if let length = durationLabel.text?.length, length > 5 {
                        durationLabel.frame = CGRect(x: width - 5 - 60, y: height - 5 - 15, width: 60, height: 15)
                    } else {
                        durationLabel.frame = CGRect(x: width - 5 - 40, y: height - 5 - 15, width: 40, height: 15)
                    }
                    video.addSubview(durationLabel)
                    
                    messView.addSubview(video)
                    
                    let tap = UITapGestureRecognizer()
                    tap.add {
                        if self.delegate.mode == "" {
                            self.delegate.openVideoController(ownerID: "\(attach.videos[0].ownerID)", vid: "\(attach.videos[0].id)", accessKey: attach.videos[0].accessKey, title: "Видеозапись")
                        }
                    }
                    tap.numberOfTapsRequired = 1
                    video.isUserInteractionEnabled = true
                    video.addGestureRecognizer(tap)
                    
                    bubbleHeight += 5 + height
                }
                
                if attach.type == "sticker" && attach.stickers.count > 0 {
                    let width = 0.5 * UIScreen.main.bounds.width
                    let height = width * CGFloat(attach.stickers[0].height) / CGFloat(attach.stickers[0].width)
                    
                    let photo = UIImageView()
                    photo.tag = 200
                    let getCacheImage = GetCacheImage(url: attach.stickers[0].photo256, lifeTime: .avatarImage)
                    let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: photo, indexPath: indexPath, tableView: tableView)
                    setImageToRow.addDependency(getCacheImage)
                    OperationQueue().addOperation(getCacheImage)
                    OperationQueue.main.addOperation(setImageToRow)
                    
                    if width > bubbleWidth {
                        bubbleWidth = width
                        if dialog.out == 1 {
                            bubbleX = UIScreen.main.bounds.width - 2 * leftInsets - avatarSize - width
                        }
                    }
                    
                    photo.frame = CGRect(x: 0, y: bubbleHeight, width: width, height: height)
                    
                    messView.backgroundColor = UIColor.clear
                    messView.layer.borderWidth = 0
                    messView.addSubview(photo)
                    bubbleHeight += height
                }
                
                if attach.type == "wall" && attach.wall.count > 0 {
                    attachCount += 1
                    let view = configureWall(wall: attach.wall[0], users: users, topY: bubbleHeight + 5)
                    
                    if view.frame.width > bubbleWidth {
                        bubbleWidth = view.frame.width + 10
                        if dialog.out == 1 {
                            bubbleX = UIScreen.main.bounds.width - 2 * leftInsets - avatarSize - view.frame.width - 10
                        }
                    }
                    
                    messView.addSubview(view)
                    bubbleHeight += 5 + view.frame.height
                }
                
                if attach.type == "gift" && attach.gift.count > 0 {
                    attachCount += 1
                    let view = configureGift(gift: attach.gift[0], topY: bubbleHeight + 5)
                    
                    if view.frame.width > bubbleWidth {
                        bubbleWidth = view.frame.width + 10
                        if dialog.out == 1 {
                            bubbleX = UIScreen.main.bounds.width - 2 * leftInsets - avatarSize - view.frame.width - 10
                        }
                    } else {
                        let viewX = (bubbleWidth - view.frame.width) / 2
                        view.frame = CGRect(x: viewX, y: view.frame.minY, width: view.frame.width, height: view.frame.height)
                    }
                    
                    messView.addSubview(view)
                    bubbleHeight += 5 + view.frame.height
                }
                
                if attach.type == "doc" && attach.docs.count > 0 {
                    attachCount += 1
                    let view = configureDoc(doc: attach.docs[0], users: users, topY: bubbleHeight + 5)
                    
                    if view.frame.width > bubbleWidth {
                        bubbleWidth = view.frame.width + 10
                        if dialog.out == 1 {
                            bubbleX = UIScreen.main.bounds.width - 2 * leftInsets - avatarSize - view.frame.width - 10
                        }
                    }
                    
                    messView.addSubview(view)
                    bubbleHeight += 5 + view.frame.height
                }
                
                if attach.type == "link" && attach.link.count > 0 {
                    attachCount += 1
                    
                    let view = configureLink(link: attach.link[0], topY: bubbleHeight + 5)
                    
                    if view.frame.width > bubbleWidth {
                        bubbleWidth = view.frame.width + 10
                        if dialog.out == 1 {
                            bubbleX = UIScreen.main.bounds.width - 2 * leftInsets - avatarSize - view.frame.width - 10
                        }
                    }
                    
                    messView.addSubview(view)
                    bubbleHeight += 5 + view.frame.height
                }
            }
            
            if attachCount > 0 {
                bubbleHeight += 5
            }
            
            for mess in dialog.fwdMessage {
                let view = configureFwdMessage(mess: mess, users: users, topY: bubbleHeight)
                
                if view.frame.width > bubbleWidth {
                    bubbleWidth = view.frame.width
                    if dialog.out == 1 {
                        bubbleX = UIScreen.main.bounds.width - 2 * leftInsets - avatarSize - view.frame.width
                    }
                }
                
                messView.addSubview(view)
                bubbleHeight += view.frame.height
            }
            
            messView.frame = CGRect(x: bubbleX, y: bubbleY, width: bubbleWidth, height: bubbleHeight)
            self.addSubview(messView)
            
            var markX: CGFloat = 10
            if dialog.out == 0 {
                markX = UIScreen.main.bounds.width - 10 - 20
            }
            
            let markCheck = BEMCheckBox()
            markCheck.tag = 200
            markCheck.onTintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
            markCheck.onCheckColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
            markCheck.lineWidth = 2
            markCheck.on = self.delegate.markMessages.contains(dialog.id)
            markCheck.isEnabled = false
            markCheck.isHidden = !markCheck.on
            if self.delegate.mode == "action" {
                markCheck.isEnabled = true
                markCheck.isHidden = false
            }
            markCheck.add(for: .valueChanged) {
                if markCheck.on {
                    if !self.delegate.markMessages.contains(dialog.id) {
                        self.delegate.markMessages.append(dialog.id)
                    }
                } else {
                    for mess in self.delegate.markMessages {
                        if mess == dialog.id {
                            self.delegate.markMessages.remove(object: mess)
                        }
                    }
                }
                self.delegate.deleteButton.setTitle("Удалить (\(self.delegate.markMessages.count))", for: .normal)
                self.delegate.resendButton.setTitle("Переслать (\(self.delegate.markMessages.count))", for: .normal)
                if self.delegate.markMessages.count > 0 {
                    self.delegate.deleteButton.isEnabled = true
                    self.delegate.resendButton.isEnabled = true
                } else {
                    self.delegate.deleteButton.isEnabled = false
                    self.delegate.resendButton.isEnabled = false
                }
            }
            markCheck.frame = CGRect(x: markX, y: bubbleY + bubbleHeight/2 - 10, width: 20, height: 20)
            self.addSubview(markCheck)
            
            
            dateLabel.tag = 200
            dateLabel.text = dialog.date.toStringLastTime()
            dateLabel.font = dateFont
            dateLabel.isEnabled = false
            
            if dialog.out == 0 {
                dateLabel.textAlignment = .left
                dateLabel.frame = CGRect(x: messView.frame.minX + 5, y: messView.frame.maxY, width: 200, height: 16)
            } else {
                dateLabel.textAlignment = .right
                dateLabel.frame = CGRect(x: messView.frame.maxX - 200 - 5, y: messView.frame.maxY, width: 200, height: 16)
            }
            
            self.addSubview(dateLabel)
        } else {
            
            var text = ""
            var actID = dialog.userID
            if dialog.actionID != 0 {
                actID = dialog.actionID
            }
            let user = users.filter({ $0.uid == "\(actID)" })
            if user.count > 0 {
                if dialog.action == "chat_kick_user" {
                    if user[0].sex == 1 {
                        text = "\(user[0].firstName) \(user[0].lastName) покинула беседу"
                    } else {
                        text = "\(user[0].firstName) \(user[0].lastName) покинул беседу"
                    }
                } else if dialog.action == "chat_invite_user" || dialog.action == "chat_invite_user_by_link" {
                    if user[0].sex == 1 {
                        text = "\(user[0].firstName) \(user[0].lastName) присоединилась к беседе"
                    } else {
                        text = "\(user[0].firstName) \(user[0].lastName) присоединился к беседе"
                    }
                } else if dialog.action == "chat_create" {
                    text = "Создана беседа с названием \"\(dialog.actionText)\""
                } else if dialog.action == "chat_title_update" {
                    text = "Изменено название беседы на \"\(dialog.actionText)\""
                } else if dialog.action == "chat_photo_update" {
                    text = "Обновлена главная фотография беседы"
                } else if dialog.action == "chat_photo_remove" {
                    text = "Удалена главная фотография беседы"
                } else if dialog.action == "chat_pin_message" {
                    text = "В беседе закреплено сообщение"
                } else if dialog.action == "chat_unpin_message" {
                    text = "В беседе откреплено сообщение"
                }
            }
            
            actLabel.tag = 200
            actLabel.text = text
            actLabel.font = actFont
            actLabel.numberOfLines = 1
            actLabel.adjustsFontSizeToFitWidth = true
            actLabel.minimumScaleFactor = 0.5
            actLabel.isEnabled = false
            
            actLabel.textAlignment = .center
            actLabel.frame = CGRect(x: 10, y: 10, width: self.bounds.width - 20, height: 16)
            self.addSubview(actLabel)
            
            dateLabel.tag = 200
            dateLabel.text = dialog.date.toStringLastTime()
            dateLabel.font = dateFont
            dateLabel.isEnabled = false
            
            dateLabel.textAlignment = .center
            dateLabel.frame = CGRect(x: 10, y: actLabel.frame.maxY, width: self.bounds.width - 20, height: 16)
            self.addSubview(dateLabel)
        }
        
        if dialog.readState == 0 {
            self.backgroundColor = UIColor.purple.withAlphaComponent(0.2)
        } else {
            self.backgroundColor = tableView.backgroundColor
        }
    }
    
    func getRowHeight(dialog: DialogHistory, users: [DialogsUsers]) -> CGFloat {
        
        var height: CGFloat = 0
        
        if dialog.action == "" {
            let rect = getTextSize(text: dialog.body.prepareTextForPublic(), font: messFont)
            height = topInsets + rect.height + 16
            
            var bubbleWidth = rect.width + 5
            
            var attachCount = 0
            for attach in dialog.attach {
                if attach.type == "photo" && attach.photos.count > 0 {
                    attachCount += 1
                    var width1 = 0.7 * (UIScreen.main.bounds.width - 2 * leftInsets - avatarSize)
                    var height1 = width1
                    if attach.photos[0].width > 0 {
                        height1 = width1 * CGFloat(attach.photos[0].height) / CGFloat(attach.photos[0].width)
                    }
                    
                    if width1 > bubbleWidth  {
                        bubbleWidth = width1 + 10
                    } else {
                        width1 = bubbleWidth - 10
                        height1 = width1
                        if attach.photos[0].width > 0 {
                            height1 = width1 * CGFloat(attach.photos[0].height) / CGFloat(attach.photos[0].width)
                        }
                    }
                    
                    height += 5 + height1
                }
                
                if attach.type == "video" && attach.videos.count > 0 {
                    attachCount += 1
                    
                    var width1 = 0.7 * (UIScreen.main.bounds.width - 2 * leftInsets - avatarSize)
                    var height1 = width1 * 240 / 320
                    
                    if width1 > bubbleWidth {
                        bubbleWidth = width1 + 10
                    } else {
                        width1 = bubbleWidth - 10
                        height1 = width1 * 240 / 320
                    }
                    
                    
                    height += 5 + height1
                }
                
                if attach.type == "sticker" && attach.stickers.count > 0 {
                    let height1 = 0.5 * UIScreen.main.bounds.width * CGFloat(attach.stickers[0].height) / CGFloat(attach.stickers[0].width)
                    
                    height += height1
                }
                
                if attach.type == "wall" && attach.wall.count > 0 {
                    attachCount += 1
                    height += 3 * leftInsets + 30 + 30 + 5
                }
                
                if attach.type == "gift" && attach.gift.count > 0 {
                    attachCount += 1
                    height += 150 + 15
                }
                
                if attach.type == "doc" && attach.docs.count > 0 {
                    attachCount += 1
                    height += 5 + 2 * leftInsets + 15 + 30 + 20
                }
                
                if attach.type == "link" && attach.link.count > 0 {
                    attachCount += 1
                    height += 5 + 2 * leftInsets + 15 + 30 + 30
                }
            }
            
            if attachCount > 0 {
                height += 5
            }
            
            for mess in dialog.fwdMessage {
                let rect = getFwdMessSize(text: mess.body.prepareTextForPublic(), font: fwdmFont)
                height += 3 * leftInsets + 15 + 30 + rect.height
                
                var attachCount = 0
                for attach in mess.attach {
                    if attach.type == "photo" && attach.photos.count > 0 {
                        attachCount += 1
                        
                        let width1 = rect.width - 20
                        var height1 = width1
                        if attach.photos[0].width > 0 {
                            height1 = width1 * CGFloat(attach.photos[0].height) / CGFloat(attach.photos[0].width)
                        }
                        
                        height += 5 + height1
                    }
                    
                    if attach.type == "video" && attach.videos.count > 0 {
                        attachCount += 1
                        
                        let width1 = rect.width - 10
                        let height1 = width1 * 240 / 320
                        
                        height += 5 + height1
                    }
                }
                
                if attachCount > 0 {
                    height += 5
                }
            }
            
            if height < topInsets + avatarSize {
                return topInsets + avatarSize + 15
            }
        } else {
            height = 10 + 16 + 16 - 5
        }
        
        return height + 15
    }
    
    func getTextSize(text: String, font: UIFont) -> CGSize {
        let maxWidth = 0.7 * (UIScreen.main.bounds.width - 2 * leftInsets - avatarSize)
        let size = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        let width = Double(rect.size.width + 20)
        var height = Double(rect.size.height + 20)
        
        if text == "" {
            height = 0
        }
        
        //print("height = \(height)")
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func getFwdMessSize(text: String, font: UIFont) -> CGSize {
        let maxWidth = 0.7 * UIScreen.main.bounds.width - 20
        let size = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        let width = Double(maxWidth + 20)
        var height = Double(rect.size.height + 20)
        
        if text == "" {
            height = 0
        }
        
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func configureFwdMessage(mess: Message, users: [DialogsUsers], topY: CGFloat) -> UIView {
        
        let view = UIView()
        view.tag = 200
        
        let rect = getFwdMessSize(text: mess.body.prepareTextForPublic(), font: fwdmFont)
        
        let statusLabel = UILabel()
        statusLabel.tag = 200
        statusLabel.text = "Пересланное сообщение"
        statusLabel.textAlignment = .right
        statusLabel.font = UIFont(name: "Verdana", size: 10)!
        statusLabel.isEnabled = false
        statusLabel.frame = CGRect(x: leftInsets, y: leftInsets, width: rect.width - 2 * leftInsets, height: 15)
        view.addSubview(statusLabel)
        
        var url = ""
        var name = ""
        let user = users.filter({ $0.uid == "\(mess.userID)" })
        if user.count > 0 {
            url = user[0].maxPhotoOrigURL
            name = "\(user[0].firstName) \(user[0].lastName)"
        }
        
        let avatar = UIImageView()
        
        let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        getCacheImage.completionBlock = {
            OperationQueue.main.addOperation {
                avatar.image = getCacheImage.outputImage
                avatar.layer.cornerRadius = 14
                avatar.clipsToBounds = true
                avatar.contentMode = .scaleAspectFill
                avatar.layer.borderColor = UIColor.lightGray.cgColor
                avatar.layer.borderWidth = 0.5
            }
        }
        OperationQueue().addOperation(getCacheImage)
        
        
        avatar.frame = CGRect(x: leftInsets, y: leftInsets + 15, width: 30, height: 30)
        view.addSubview(avatar)
        
        let nameLabel = UILabel()
        nameLabel.tag = 200
        nameLabel.text = name
        nameLabel.font = UIFont(name: "Verdana-Bold", size: 11)!
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        nameLabel.frame = CGRect(x: 2 * leftInsets + 30, y: leftInsets + 15, width: rect.width - 3 * leftInsets - 30, height: 16)
        view.addSubview(nameLabel)
        
        let dateLabel = UILabel()
        dateLabel.tag = 200
        dateLabel.text = mess.date.toStringLastTime()
        dateLabel.font = UIFont(name: "Verdana", size: 9)!
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.minimumScaleFactor = 0.5
        dateLabel.isEnabled = false
        dateLabel.frame = CGRect(x: 2 * leftInsets + 30, y: leftInsets + 15 + 14, width: rect.width - 3 * leftInsets - 30, height: 16)
        view.addSubview(dateLabel)
        
        let fwdBodyLabel = UILabel()
        fwdBodyLabel.tag = 200
        fwdBodyLabel.text = mess.body
        fwdBodyLabel.prepareTextForPublish2(self.delegate)
        fwdBodyLabel.font = fwdmFont
        fwdBodyLabel.backgroundColor = UIColor.clear
        fwdBodyLabel.numberOfLines = 0
        
        fwdBodyLabel.frame = CGRect(x: 10, y: 2 * leftInsets + 15 + 30, width: rect.width - 20, height: rect.height)
        view.addSubview(fwdBodyLabel)
        
        var heightTotal = 3 * leftInsets + 15 + 30 + rect.height
        
        var attachCount = 0
        for attach in mess.attach {
            if attach.type == "photo" && attach.photos.count > 0 {
                attachCount += 1
                
                let width = rect.width - 10
                var height = width
                if attach.photos[0].width > 0 {
                    height = width * CGFloat(attach.photos[0].height) / CGFloat(attach.photos[0].width)
                }
                
                let photo = UIImageView()
                photo.tag = 200
                let getCacheImage = GetCacheImage(url: attach.photos[0].photo604, lifeTime: .avatarImage)
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        photo.image = getCacheImage.outputImage
                    }
                }
                OperationQueue().addOperation(getCacheImage)
                OperationQueue.main.addOperation {
                    photo.layer.cornerRadius = 12
                    photo.clipsToBounds = true
                    photo.contentMode = .scaleAspectFill
                    photo.backgroundColor = UIColor.clear
                }
                
                photo.frame = CGRect(x: 5, y: heightTotal + 5, width: width, height: height)
                
                view.addSubview(photo)
                
                let tap = UITapGestureRecognizer()
                tap.add {
                    if self.delegate.mode == "" {
                        let photoViewController = self.delegate.storyboard?.instantiateViewController(withIdentifier: "photoViewController") as! PhotoViewController
                        
                        var newIndex = 0
                        if mess.attach.count > 0 {
                            for ind in 0...mess.attach.count-1 {
                                if mess.attach[ind].type == "photo" && mess.attach[ind].photos.count > 0  {
                                    let photos = Photos(json: JSON.null)
                                    photos.uid = "\(mess.attach[ind].photos[0].ownerID)"
                                    photos.pid = "\(mess.attach[ind].photos[0].id)"
                                    photos.xxbigPhotoURL = mess.attach[ind].photos[0].photo604
                                    photos.xbigPhotoURL = mess.attach[ind].photos[0].photo604
                                    photos.bigPhotoURL = mess.attach[ind].photos[0].photo604
                                    photos.photoURL = mess.attach[ind].photos[0].photo604
                                    photos.width = mess.attach[ind].photos[0].width
                                    photos.height = mess.attach[ind].photos[0].height
                                    photos.photoAccessKey = mess.attach[ind].photos[0].accessKey
                                    photoViewController.photos.append(photos)
                                    if mess.attach[ind].photos[0].id == attach.photos[0].id {
                                        photoViewController.numPhoto = newIndex
                                    }
                                    newIndex += 1
                                }
                            }
                            
                            photoViewController.delegate = self.delegate
                            
                            self.delegate.navigationController?.pushViewController(photoViewController, animated: true)
                        }
                    }
                }
                tap.numberOfTapsRequired = 1
                photo.isUserInteractionEnabled = true
                photo.addGestureRecognizer(tap)
                
                heightTotal += 5 + height
            }
            
            if attach.type == "video" && attach.videos.count > 0 {
                attachCount += 1
                
                let width = rect.width - 10
                let height = width * 240 / 320
                
                let video = UIImageView()
                video.tag = 200
                let getCacheImage = GetCacheImage(url: attach.videos[0].photo320, lifeTime: .avatarImage)
                OperationQueue().addOperation(getCacheImage)
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        video.image = getCacheImage.outputImage
                    }
                }
                OperationQueue.main.addOperation {
                    video.layer.cornerRadius = 12
                    video.clipsToBounds = true
                    video.contentMode = .scaleAspectFill
                    video.backgroundColor = UIColor.clear
                }
                
                video.frame = CGRect(x: 5, y: heightTotal + 5, width: width, height: height)
                
                let videoImage = UIImageView()
                videoImage.image = UIImage(named: "video")
                video.addSubview(videoImage)
                videoImage.frame = CGRect(x: width / 2 - 20, y: (height - 4) / 2 - 20, width: 40, height: 40)
                
                let durationLabel = UILabel()
                durationLabel.text = attach.videos[0].duration.getVideoDurationToString()
                durationLabel.numberOfLines = 1
                durationLabel.font = UIFont(name: "Verdana-Bold", size: 8.0)!
                durationLabel.textAlignment = .center
                durationLabel.contentMode = .center
                durationLabel.textColor = UIColor.black
                durationLabel.backgroundColor = UIColor.lightText.withAlphaComponent(0.5)
                durationLabel.layer.cornerRadius = 6
                durationLabel.clipsToBounds = true
                if let length = durationLabel.text?.length, length > 5 {
                    durationLabel.frame = CGRect(x: width - 5 - 60, y: height - 5 - 15, width: 60, height: 15)
                } else {
                    durationLabel.frame = CGRect(x: width - 5 - 40, y: height - 5 - 15, width: 40, height: 15)
                }
                video.addSubview(durationLabel)
                
                view.addSubview(video)
                
                let tap = UITapGestureRecognizer()
                tap.add {
                    if self.delegate.mode == "" {
                        self.delegate.openVideoController(ownerID: "\(attach.videos[0].ownerID)", vid: "\(attach.videos[0].id)", accessKey: attach.videos[0].accessKey, title: "Видеозапись")
                    }
                }
                tap.numberOfTapsRequired = 1
                video.isUserInteractionEnabled = true
                video.addGestureRecognizer(tap)
                
                heightTotal += 5 + height
            }
        }
        
        if attachCount > 0 {
            heightTotal += 5
        }
        
        view.frame = CGRect(x: 0, y: topY, width: rect.width, height: heightTotal)
        
        return view
    }
    
    func configureWall(wall: WallAttach, users: [DialogsUsers], topY: CGFloat) -> UIView {
        
        let view = UIView()
        view.tag = 200
        
        var url = ""
        var name = ""
        let user = users.filter({ $0.uid == "\(wall.fromID)" })
        if user.count > 0 {
            url = user[0].maxPhotoOrigURL
            name = "\(user[0].firstName) \(user[0].lastName)"
        }
        
        let avatar = UIImageView()
        
        let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        getCacheImage.completionBlock = {
            OperationQueue.main.addOperation {
                avatar.image = getCacheImage.outputImage
                avatar.layer.cornerRadius = 14
                avatar.clipsToBounds = true
                avatar.contentMode = .scaleAspectFill
                avatar.layer.borderColor = UIColor.lightGray.cgColor
                avatar.layer.borderWidth = 0.5
            }
        }
        OperationQueue().addOperation(getCacheImage)
        
        
        avatar.frame = CGRect(x: leftInsets, y: leftInsets, width: 30, height: 30)
        view.addSubview(avatar)
        
        let width = 0.7 * UIScreen.main.bounds.width
        
        let nameLabel = UILabel()
        nameLabel.tag = 200
        nameLabel.text = name
        nameLabel.font = UIFont(name: "Verdana-Bold", size: 11)!
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        nameLabel.frame = CGRect(x: 2 * leftInsets + 30, y: leftInsets, width: width - 3 * leftInsets - 30, height: 16)
        view.addSubview(nameLabel)
        
        let dateLabel = UILabel()
        dateLabel.tag = 200
        dateLabel.text = wall.date.toStringLastTime()
        dateLabel.font = UIFont(name: "Verdana", size: 9)!
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.minimumScaleFactor = 0.5
        dateLabel.isEnabled = false
        dateLabel.frame = CGRect(x: 2 * leftInsets + 30, y: leftInsets + 14, width: width - 3 * leftInsets - 30, height: 16)
        view.addSubview(dateLabel)
        
        let bodyLabel = UILabel()
        bodyLabel.tag = 200
        
        if wall.text != "" {
            bodyLabel.text = wall.text.prepareTextForPublic()
            bodyLabel.textAlignment = .left
        } else {
            bodyLabel.text = "... Запись на стене ..."
            bodyLabel.textAlignment = .center
        }
        
        bodyLabel.font = UIFont(name: "Verdana", size: 11)!
        bodyLabel.textColor = UIColor.gray
        bodyLabel.numberOfLines = 2
        bodyLabel.frame = CGRect(x: topInsets, y: 2 * leftInsets + 30, width: width - 2 * topInsets, height: 30)
        view.addSubview(bodyLabel)
        
        let height = 3 * leftInsets + 30 + 30
        view.frame = CGRect(x: 5, y: topY, width: width, height: height)
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 13
        view.backgroundColor = UIColor.white
        
        let tap = UITapGestureRecognizer()
        tap.add {
            if self.delegate.mode == "" {
                self.delegate.openWallRecord(ownerID: wall.fromID, postID: wall.id, accessKey: "", type: "post")
            }
        }
        tap.numberOfTapsRequired = 1
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
        
        return view
    }
    
    func configureGift(gift: GiftAttach, topY: CGFloat) -> UIView {
        
        let view = UIView()
        view.tag = 200
        
        let width: CGFloat = 150
        let height = width + 15
        
        let statusLabel = UILabel()
        statusLabel.tag = 200
        statusLabel.text = "Подарок"
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont(name: "Verdana", size: 9)!
        statusLabel.isEnabled = false
        statusLabel.frame = CGRect(x: 0, y: width, width: width, height: 15)
        view.addSubview(statusLabel)
        
        let giftImage = UIImageView()
        
        let getCacheImage = GetCacheImage(url: gift.thumb256, lifeTime: .avatarImage)
        getCacheImage.completionBlock = {
            OperationQueue.main.addOperation {
                giftImage.image = getCacheImage.outputImage
                giftImage.layer.cornerRadius = 14
                giftImage.clipsToBounds = true
                giftImage.contentMode = .scaleAspectFill
            }
        }
        OperationQueue().addOperation(getCacheImage)
        
        
        giftImage.frame = CGRect(x: 0, y: 0, width: width, height: width)
        view.addSubview(giftImage)
        
        view.frame = CGRect(x: 5, y: topY, width: width, height: height)
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 13
        view.backgroundColor = UIColor.white
        
        return view
    }
    
    func configureDoc(doc: DocAttach, users: [DialogsUsers], topY: CGFloat) -> UIView {
        
        let view = UIView()
        view.tag = 200
        
        let width: CGFloat = 0.7 * UIScreen.main.bounds.width
        
        let statusLabel = UILabel()
        statusLabel.tag = 200
        if doc.type == 1 {
            statusLabel.text = "Документ: текстовый документ"
        } else if doc.type == 2 {
            statusLabel.text = "Документ: архив"
        } else if doc.type == 3 {
            statusLabel.text = "Документ: GIF"
        } else if doc.type == 4 {
            statusLabel.text = "Документ: фотография"
        } else if doc.type == 5 {
            statusLabel.text = "Документ: аудиозапись"
        } else if doc.type == 6 {
            statusLabel.text = "Документ: видеозапись"
        } else if doc.type == 7 {
            statusLabel.text = "Документ: электронная книга"
        } else {
            statusLabel.text = "Документ: неизвестный тип"
        }
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont(name: "Verdana", size: 9)!
        statusLabel.isEnabled = false
        statusLabel.frame = CGRect(x: leftInsets, y: leftInsets, width: width - 2 * leftInsets, height: 15)
        view.addSubview(statusLabel)
        
        
        let nameLabel = UILabel()
        nameLabel.tag = 200
        nameLabel.text = doc.title
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont(name: "Verdana-Bold", size: 12)!
        nameLabel.numberOfLines = 2
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.4
        nameLabel.frame = CGRect(x: leftInsets, y: leftInsets + 15, width: width - 2 * leftInsets, height: 30)
        view.addSubview(nameLabel)
        
        let loadButton = UIButton()
        loadButton.setTitle("Открыть документ", for: .normal)
        loadButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 11)!
        loadButton.frame = CGRect(x: leftInsets, y: leftInsets + 15 + 30, width: width - 2 * leftInsets, height: 20)
        loadButton.setTitleColor(loadButton.tintColor, for: .normal)
        view.addSubview(loadButton)
        
        loadButton.add(for: .touchUpInside) {
            if self.delegate.mode == "" {
                self.delegate.openBrowserControllerNoCheck(url: doc.url)
            }
        }
        
        let height = 2 * leftInsets + 15 + 30 + 20
        view.frame = CGRect(x: 5, y: topY, width: width, height: height)
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 13
        view.backgroundColor = UIColor.white
        
        return view
    }
    
    func configureLink(link: LinkAttach, topY: CGFloat) -> UIView {
        
        let view = UIView()
        view.tag = 200
        
        let width: CGFloat = 0.7 * UIScreen.main.bounds.width
        
        let statusLabel = UILabel()
        statusLabel.tag = 200
        statusLabel.text = "Ссылка"
        statusLabel.textAlignment = .right
        statusLabel.font = UIFont(name: "Verdana", size: 10)!
        statusLabel.isEnabled = false
        statusLabel.frame = CGRect(x: leftInsets, y: leftInsets, width: width - 2 * leftInsets, height: 15)
        view.addSubview(statusLabel)
        
        let titleLabel = UILabel()
        titleLabel.tag = 200
        titleLabel.text = link.title.prepareTextForPublic()
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont(name: "Verdana", size: 12)!
        titleLabel.frame = CGRect(x: leftInsets, y: leftInsets + 15, width: width - 2 * leftInsets, height: 30)
        view.addSubview(titleLabel)
        
        let linkLabel = UILabel()
        linkLabel.tag = 200
        linkLabel.text = link.url
        linkLabel.prepareTextForPublish2(self.delegate)
        linkLabel.font = UIFont(name: "Verdana", size: 11)!
        linkLabel.backgroundColor = UIColor.clear
        linkLabel.numberOfLines = 2
        
        linkLabel.frame = CGRect(x: leftInsets, y: leftInsets + 15 + 30, width: width - 2 * leftInsets, height: 30)
        view.addSubview(linkLabel)
        
        let height = 2 * leftInsets + 15 + 30 + 30
        view.frame = CGRect(x: 5, y: topY, width: width, height: height)
        view.backgroundColor = UIColor.clear
        
        return view
    }
}
