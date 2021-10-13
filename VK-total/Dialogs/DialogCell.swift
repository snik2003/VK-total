//
//  DialogCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 21.04.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import AVFoundation
import BEMCheckBox
import SwiftyJSON

class DialogCell: UITableViewCell {

    var delegate: UIViewController!
    
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
    
    var drawCell = true
    
    func configureCell(dialog: DialogHistory, users: [DialogsUsers], indexPath: IndexPath, cell: UITableViewCell, tableView: UITableView) -> CGFloat {
        
        var topY: CGFloat = 0
        
        if drawCell {
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
        }
        
        if dialog.action == "" {
            
            if drawCell {
                var url = ""
                var user = users.filter({ $0.uid == "\(dialog.fromID)" })
                
                if let controller = self.delegate as? GroupDialogController {
                    if dialog.out == 1 {
                        user = users.filter({ $0.uid == "-\(controller.groupID)" })
                    }
                }
                
                if user.count > 0 {
                    url = user[0].maxPhotoOrigURL
                }
                
                messText.tag = 200
                messText.font = messFont
                messText.backgroundColor = .clear
                messText.numberOfLines = 0
                
                avatarImage.tag = 200
                avatarImage.image = UIImage(named: "error")
                let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
                let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImage, indexPath: indexPath, tableView: tableView)
                setImageToRow.addDependency(getCacheImage)
                OperationQueue().addOperation(getCacheImage)
                OperationQueue.main.addOperation(setImageToRow)
                OperationQueue.main.addOperation {
                    self.avatarImage.layer.cornerRadius = self.avatarSize/2
                    self.avatarImage.clipsToBounds = true
                    self.avatarImage.contentMode = .scaleAspectFill
                    self.avatarImage.layer.borderColor = vkSingleton.shared.secondaryLabelColor.cgColor
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
                    if let controller = self.delegate as? DialogController, controller.mode == .edit { return }
    
                    self.delegate.openProfileController(id: dialog.fromID, name: "")
                }
                tapAvatar.numberOfTapsRequired = 1
                avatarImage.isUserInteractionEnabled = true
                avatarImage.addGestureRecognizer(tapAvatar)
            }
            
            let rect = getTextSize(text: dialog.body.prepareTextForPublic(), font: messFont)
            
            var bubbleHeight = rect.height
            var bubbleWidth = rect.width
            var bubbleX: CGFloat = 0
            let bubbleY: CGFloat = topInsets
            
            if drawCell {
                messText.text = dialog.body
                messText.prepareTextForPublish2(self.delegate, color: .black)
                
                messView.tag = 200
                messView.layer.cornerRadius = 15
                messView.layer.borderColor = vkSingleton.shared.secondaryLabelColor.cgColor
                messView.layer.borderWidth = 0.5
                messText.frame = CGRect(x: 10, y: 0, width: rect.width - 20, height: rect.height)
                
                if dialog.out == 0 {
                    bubbleX = 2 * leftInsets + avatarSize
                    messView.backgroundColor = vkSingleton.shared.inBackColor
                } else {
                    bubbleX = UIScreen.main.bounds.width - 2 * leftInsets - avatarSize - rect.width
                    messView.backgroundColor = vkSingleton.shared.outBackColor
                }
                
                messView.addSubview(messText)
            }
            
            var attachCount = 0
            
            var photos: [Photos] = []
            for attach in dialog.attach {
                if attach.type == "photo" && attach.photos.count > 0 {
                    attachCount += 1
                    
                    let photo = Photos(json: JSON.null)
                    photo.width = attach.photos[0].width
                    photo.height = attach.photos[0].height
                    photo.text = attach.photos[0].text
                    photo.xxbigPhotoURL = attach.photos[0].photo1280
                    photo.xbigPhotoURL = attach.photos[0].photo1280
                    photo.bigPhotoURL = attach.photos[0].photo807
                    photo.smallPhotoURL = attach.photos[0].photo604
                    photo.pid = "\(attach.photos[0].id)"
                    photo.uid = "\(attach.photos[0].userID)"
                    photo.ownerID = "\(attach.photos[0].ownerID)"
                    photo.createdTime = attach.photos[0].date
                    photos.append(photo)
                }
            }
            
            if attachCount > 0 {
                let aView = AttachmentsView()
                aView.photos = photos
                
                let width = 0.7 * (UIScreen.main.bounds.width - 2 * leftInsets - avatarSize) + 2.5
                
                if drawCell {
                    let height = aView.configureAttachView(maxSize: width, getRow: false)
                    
                    aView.backgroundColor = .clear
                    aView.tag = 200
                    aView.delegate = self.delegate
                    
                    var photoX: CGFloat = 5
                    if width > bubbleWidth - 10 {
                        bubbleWidth = width + 10
                        if dialog.out == 1 {
                            bubbleX = UIScreen.main.bounds.width - 2 * leftInsets - avatarSize - width - 10
                        }
                    } else {
                        photoX = (bubbleWidth - width) / 2
                    }
                    
                    if dialog.fwdMessage.count > 0 {
                        photoX = (0.7 * UIScreen.main.bounds.width - width) / 2
                    }
                    
                    aView.frame = CGRect(x: photoX, y: bubbleHeight + 5, width: width, height: height)
                    messView.addSubview(aView)
                
                    bubbleHeight += 5 + height
                } else {
                    let height = aView.configureAttachView(maxSize: width, getRow: true)
                    bubbleHeight += 5 + height
                }
            }
        
            for attach in dialog.attach {
                if attach.type == "video" && attach.videos.count > 0 {
                    attachCount += 1
                    
                    var width = 0.7 * (UIScreen.main.bounds.width - 2 * leftInsets - avatarSize)
                    var height = width * 240 / 320
                    
                    if drawCell {
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
                            video.backgroundColor = .clear
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
                        durationLabel.textColor = .white
                        durationLabel.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
                        durationLabel.layer.cornerRadius = 4
                        durationLabel.clipsToBounds = true
                        let durationLabelWidth = durationLabel.getTextWidth(maxWidth: 200)
                        durationLabel.frame = CGRect(x: width - 5 - durationLabelWidth, y: height - 5 - 15, width: durationLabelWidth, height: 15)
                        video.addSubview(durationLabel)
                        
                        messView.addSubview(video)
                        
                        let tap = UITapGestureRecognizer()
                        tap.add {
                            if let controller = self.delegate as? DialogController, controller.mode == .edit { return }
                            
                            video.viewTouched(controller: self.delegate)
                            self.delegate.openVideoController(ownerID: "\(attach.videos[0].ownerID)", vid: "\(attach.videos[0].id)", accessKey: attach.videos[0].accessKey, title: "Видеозапись", scrollToComment: false)
                        }
                        tap.numberOfTapsRequired = 1
                        video.isUserInteractionEnabled = true
                        video.addGestureRecognizer(tap)
                    } else {
                        if width <= bubbleWidth {
                            width = bubbleWidth - 10
                            height = width * 240 / 320
                        }
                    }
                    
                    bubbleHeight += 5 + height
                }
                
                if attach.type == "sticker" && attach.stickers.count > 0 {
                    let width = 0.5 * UIScreen.main.bounds.width
                    let height = width * CGFloat(attach.stickers[0].height) / CGFloat(attach.stickers[0].width)
                    
                    if drawCell {
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
                        
                        messView.backgroundColor = .clear
                        messView.layer.borderWidth = 0
                        messView.addSubview(photo)
                    }
                    
                    bubbleHeight += height
                }
                
                if attach.type == "wall" && attach.wall.count > 0 {
                    attachCount += 1
                    
                    let view = configureWall(wall: attach.wall[0], users: users, topY: bubbleHeight + 5)
                    
                    if drawCell {
                        if view.frame.width > bubbleWidth {
                            bubbleWidth = view.frame.width + 10
                            if dialog.out == 1 {
                                bubbleX = UIScreen.main.bounds.width - 2 * leftInsets - avatarSize - view.frame.width - 10
                            }
                        }
                        
                        messView.addSubview(view)
                    }
                    
                    bubbleHeight += 5 + view.frame.height
                }
                
                if attach.type == "gift" && attach.gift.count > 0 {
                    attachCount += 1
                    let view = configureGift(gift: attach.gift[0], topY: bubbleHeight + 5)
                    
                    if drawCell {
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
                    }
                    
                    bubbleHeight += 5 + view.frame.height
                }
                
                if attach.type == "doc" && attach.docs.count > 0 {
                    attachCount += 1
                    let view = configureDoc(doc: attach.docs[0], users: users, topY: bubbleHeight + 5)
                    
                    if drawCell {
                        if view.frame.width > bubbleWidth {
                            bubbleWidth = view.frame.width + 10
                            if dialog.out == 1 {
                                bubbleX = UIScreen.main.bounds.width - 2 * leftInsets - avatarSize - view.frame.width - 10
                            }
                        }
                        
                        if view.frame.width < bubbleWidth {
                            view.frame = CGRect(x: (bubbleWidth - view.frame.width) / 2, y: bubbleHeight + 5, width: view.frame.width, height: view.frame.height)
                        }
                        
                        if attach.docs[0].type == 4 && !attach.docs[0].link.isEmpty {
                            messView.backgroundColor = .clear
                            messView.layer.borderWidth = 0
                        }
                
                        messView.addSubview(view)
                    }
                    
                    bubbleHeight += 5 + view.frame.height
                }
                
                if attach.type == "audio" && attach.audio.count > 0 {
                    attachCount += 1
                    let view = configureAudio(audio: attach.audio[0], topY: bubbleHeight + 5)
                    
                    if drawCell {
                        if view.frame.width > bubbleWidth {
                            bubbleWidth = view.frame.width + 10
                            if dialog.out == 1 {
                                bubbleX = UIScreen.main.bounds.width - 2 * leftInsets - avatarSize - view.frame.width - 10
                            }
                        }
                        
                        messView.addSubview(view)
                    }
                    
                    bubbleHeight += 5 + view.frame.height
                }
                
                if attach.type == "link" && attach.link.count > 0 {
                    attachCount += 1
                    let view = configureLink(link: attach.link[0], topY: bubbleHeight + 5)
                    
                    if drawCell {
                        if view.frame.width > bubbleWidth {
                            bubbleWidth = view.frame.width + 10
                            if dialog.out == 1 {
                                bubbleX = UIScreen.main.bounds.width - 2 * leftInsets - avatarSize - view.frame.width - 10
                            }
                        }
                        
                        messView.addSubview(view)
                    }
                    
                    bubbleHeight += 5 + view.frame.height
                }
            }
            
            if attachCount > 0 {
                bubbleHeight += 5
            }
            
            for mess in dialog.fwdMessage {
                let view = configureFwdMessage(mess: mess, users: users, topY: bubbleHeight)
                
                if drawCell {
                    if view.frame.width > bubbleWidth {
                        bubbleWidth = view.frame.width
                        if dialog.out == 1 {
                            bubbleX = UIScreen.main.bounds.width - 2 * leftInsets - avatarSize - view.frame.width
                        }
                    }
                    
                    messView.addSubview(view)
                }
                
                bubbleHeight += view.frame.height
            }
            
            messView.frame = CGRect(x: bubbleX, y: bubbleY, width: bubbleWidth, height: bubbleHeight)
            if !dialog.hasSticker {
                messView.configureMessageView(out: dialog.out, radius: 12, border: 1)
            }
            
            if drawCell {
                self.addSubview(messView)
                
                var markX: CGFloat = 10
                if dialog.out == 0 {
                    markX = UIScreen.main.bounds.width - 10 - 20
                }
                
                if dialog.important == 1 {
                    let favoriteImage = UIImageView()
                    favoriteImage.tag = 200
                    favoriteImage.image = UIImage(named: "favorite")
                    favoriteImage.contentMode = .scaleAspectFill
                    var leftX = bubbleX - 25
                    if dialog.out == 0 {
                        leftX = bubbleX + bubbleWidth + 5
                    }
                    favoriteImage.frame = CGRect(x: leftX, y: bubbleY + bubbleHeight - 25, width: 20, height: 20)
                    self.addSubview(favoriteImage)
                }
                
                if let controller = self.delegate as? DialogController {
                    let markCheck = BEMCheckBox()
                    markCheck.tag = 200
                    markCheck.onTintColor = vkSingleton.shared.mainColor
                    markCheck.onCheckColor = vkSingleton.shared.mainColor
                    markCheck.lineWidth = 2
                    markCheck.on = controller.markMessages.contains(dialog.id)
                    markCheck.isEnabled = false
                    markCheck.isHidden = !markCheck.on
                    if controller.mode == .edit {
                        markCheck.isEnabled = true
                        markCheck.isHidden = false
                    }
                    markCheck.add(for: .valueChanged) {
                        if markCheck.on {
                            if !controller.markMessages.contains(dialog.id) {
                                controller.markMessages.append(dialog.id)
                            }
                        } else {
                            for mess in controller.markMessages {
                                if mess == dialog.id {
                                    controller.markMessages.remove(object: mess)
                                }
                            }
                        }
                        controller.deleteButton.setTitle("Удалить (\(controller.markMessages.count))", for: .normal)
                        controller.resendButton.setTitle("Переслать (\(controller.markMessages.count))", for: .normal)
                        if controller.markMessages.count > 0 {
                            controller.deleteButton.isEnabled = true
                            controller.resendButton.isEnabled = true
                        } else {
                            controller.deleteButton.isEnabled = false
                            controller.resendButton.isEnabled = false
                        }
                    }
                    markCheck.frame = CGRect(x: markX, y: bubbleY + bubbleHeight/2 - 10, width: 20, height: 20)
                    self.addSubview(markCheck)
                }
                
                dateLabel.textColor = vkSingleton.shared.secondaryLabelColor
                dateLabel.tag = 200
                dateLabel.text = dialog.date.toStringLastTime()
                dateLabel.font = dateFont
                
                if dialog.out == 0 {
                    dateLabel.textAlignment = .left
                    dateLabel.frame = CGRect(x: messView.frame.minX + 8, y: messView.frame.maxY, width: 200, height: 16)
                } else {
                    dateLabel.textAlignment = .right
                    dateLabel.frame = CGRect(x: messView.frame.maxX - 200 - 8, y: messView.frame.maxY, width: 200, height: 16)
                }
                
                self.addSubview(dateLabel)
            }
            
            topY = messView.frame.maxY + 16 + 15
        } else {
            if drawCell {
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
                        text = "Создана беседа с названием «\(dialog.actionText)»"
                    } else if dialog.action == "chat_title_update" {
                        text = "Изменено название беседы на «\(dialog.actionText)»"
                    } else if dialog.action == "chat_photo_update" {
                        text = "Обновлена главная фотография беседы"
                    } else if dialog.action == "chat_photo_remove" {
                        text = "Удалена главная фотография беседы"
                    } else if dialog.action == "chat_pin_message" {
                        text = "В беседе закреплено сообщение"
                    } else if dialog.action == "chat_unpin_message" {
                        text = "В беседе откреплено сообщение"
                    } else {
                        text = dialog.action
                    }
                } else {
                    if dialog.action == "chat_create" {
                        text = "Создана беседа с названием «\(dialog.actionText)»"
                    } else if dialog.action == "chat_title_update" {
                        text = "Изменено название беседы на «\(dialog.actionText)»"
                    } else if dialog.action == "chat_photo_update" {
                        text = "Обновлена главная фотография беседы"
                    } else if dialog.action == "chat_photo_remove" {
                        text = "Удалена главная фотография беседы"
                    } else if dialog.action == "chat_pin_message" {
                        text = "В беседе закреплено сообщение"
                    } else if dialog.action == "chat_unpin_message" {
                        text = "В беседе откреплено сообщение"
                    } else {
                        text = dialog.action
                    }
                }
                
                actLabel.textColor = vkSingleton.shared.secondaryLabelColor
                dateLabel.textColor = vkSingleton.shared.secondaryLabelColor
                
                actLabel.tag = 200
                actLabel.text = text
                actLabel.font = actFont
                actLabel.numberOfLines = 1
                actLabel.adjustsFontSizeToFitWidth = true
                actLabel.minimumScaleFactor = 0.5
                
                actLabel.textAlignment = .center
                actLabel.frame = CGRect(x: 10, y: 10, width: self.bounds.width - 20, height: 16)
                self.addSubview(actLabel)
                
                dateLabel.tag = 200
                dateLabel.text = dialog.date.toStringLastTime()
                dateLabel.font = dateFont
                
                dateLabel.textAlignment = .center
                dateLabel.frame = CGRect(x: 10, y: actLabel.frame.maxY, width: self.bounds.width - 20, height: 16)
                self.addSubview(dateLabel)
            
                topY = actLabel.frame.maxY + 16 + 15
            } else {
                topY = 10 + 16 + 16 + 15
            }
        }
        
        if drawCell {
            if dialog.readState == 0 {
                self.backgroundColor = vkSingleton.shared.unreadColor
            } else {
                self.backgroundColor = vkSingleton.shared.backColor
            }
        }
        
        return topY
    }
    
    func getTextSize(text: String, font: UIFont) -> CGSize {
        let maxWidth = 0.7 * (UIScreen.main.bounds.width - 2 * leftInsets - avatarSize)
        let size = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        let width = Double(rect.size.width + 20)
        var height = Double(rect.size.height + 16)
        
        if text == "" {
            height = 0
        }
        
        //print("height = \(height)")
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func getFwdMessSize(text: String, font: UIFont) -> CGSize {
        let maxWidth = 0.7 * UIScreen.main.bounds.width - 20
        let size = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        let width = Double(maxWidth + 20)
        var height = Double(rect.size.height + 20)
        
        if text == "" {
            height = 0
        }
        
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func configureFwdMessage(mess: Message, users: [DialogsUsers], topY: CGFloat) -> UIView {
        
        let rect = getFwdMessSize(text: mess.body.prepareTextForPublic(), font: fwdmFont)
        
        let view = UIView()
        
        if drawCell {
            view.tag = 200
            
            let statusLabel = UILabel()
            statusLabel.tag = 200
            statusLabel.text = "Пересланное сообщение"
            statusLabel.textAlignment = .right
            statusLabel.font = UIFont(name: "Verdana", size: 10)!
            statusLabel.textColor = .black
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
                    avatar.layer.borderColor = vkSingleton.shared.secondaryLabelColor.cgColor
                    avatar.layer.borderWidth = 0.5
                }
            }
            OperationQueue().addOperation(getCacheImage)
            
            
            avatar.frame = CGRect(x: leftInsets, y: leftInsets + 15, width: 30, height: 30)
            view.addSubview(avatar)
            
            let tap = UITapGestureRecognizer()
            tap.add {
                if let controller = self.delegate as? DialogController, controller.mode == .edit { return }
                
                self.delegate.openProfileController(id: mess.userID, name: name)
            }
            tap.numberOfTapsRequired = 1
            avatar.isUserInteractionEnabled = true
            avatar.addGestureRecognizer(tap)
            
            
            let nameLabel = UILabel()
            nameLabel.tag = 200
            nameLabel.text = name
            nameLabel.textColor = .black
            nameLabel.font = UIFont(name: "Verdana-Bold", size: 11)!
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.minimumScaleFactor = 0.5
            nameLabel.frame = CGRect(x: 2 * leftInsets + 30, y: leftInsets + 15, width: rect.width - 3 * leftInsets - 30, height: 16)
            view.addSubview(nameLabel)
            
            let dateLabel = UILabel()
            dateLabel.tag = 200
            dateLabel.text = mess.date.toStringLastTime()
            dateLabel.textColor = .black
            dateLabel.isEnabled = false
            dateLabel.font = UIFont(name: "Verdana", size: 9)!
            dateLabel.adjustsFontSizeToFitWidth = true
            dateLabel.minimumScaleFactor = 0.5
            dateLabel.isEnabled = false
            dateLabel.frame = CGRect(x: 2 * leftInsets + 30, y: leftInsets + 15 + 14, width: rect.width - 3 * leftInsets - 30, height: 16)
            view.addSubview(dateLabel)
            
            let fwdBodyLabel = UILabel()
            fwdBodyLabel.tag = 200
            fwdBodyLabel.text = mess.body
            fwdBodyLabel.prepareTextForPublish2(self.delegate, color: .black)
            fwdBodyLabel.font = fwdmFont
            fwdBodyLabel.backgroundColor = UIColor.clear
            fwdBodyLabel.numberOfLines = 0
            
            fwdBodyLabel.frame = CGRect(x: 10, y: 2 * leftInsets + 15 + 30, width: rect.width - 20, height: rect.height)
            view.addSubview(fwdBodyLabel)
        }
        
        var heightTotal = 3 * leftInsets + 15 + 30 + rect.height
        
        var attachCount = 0
        
        var photos: [Photos] = []
        for attach in mess.attach {
            if attach.type == "photo" && attach.photos.count > 0 {
                attachCount += 1
                
                let photo = Photos(json: JSON.null)
                photo.width = attach.photos[0].width
                photo.height = attach.photos[0].height
                photo.text = attach.photos[0].text
                photo.xxbigPhotoURL = attach.photos[0].photo1280
                photo.xbigPhotoURL = attach.photos[0].photo1280
                photo.bigPhotoURL = attach.photos[0].photo807
                photo.smallPhotoURL = attach.photos[0].photo604
                photo.pid = "\(attach.photos[0].id)"
                photo.uid = "\(attach.photos[0].userID)"
                photo.ownerID = "\(attach.photos[0].ownerID)"
                photo.createdTime = attach.photos[0].date
                photos.append(photo)
            }
        }
        
        if attachCount > 0 {
            let aView = AttachmentsView()
            aView.photos = photos
            
            let width = rect.width - 10 + 2.5
            
            if drawCell {
                let height = aView.configureAttachView(maxSize: width, getRow: false)
                
                aView.backgroundColor = .clear
                aView.tag = 200
                aView.delegate = self.delegate
                aView.frame = CGRect(x: 5, y: heightTotal + 5, width: width, height: height)
                view.addSubview(aView)
                
                heightTotal += 5 + height
            } else {
                let height = aView.configureAttachView(maxSize: width, getRow: true)
                heightTotal += 5 + height
            }
        }
        
        for attach in mess.attach {
            if attach.type == "video" && attach.videos.count > 0 {
                attachCount += 1
                
                let width = rect.width - 10
                let height = width * 240 / 320
                
                if drawCell {
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
                    durationLabel.textColor = .white
                    durationLabel.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
                    durationLabel.layer.cornerRadius = 4
                    durationLabel.clipsToBounds = true
                    let durationLabelWidth = durationLabel.getTextWidth(maxWidth: 200)
                    durationLabel.frame = CGRect(x: width - 5 - durationLabelWidth, y: height - 5 - 15, width: durationLabelWidth, height: 15)
                    video.addSubview(durationLabel)
                    
                    view.addSubview(video)
                    
                    let tap = UITapGestureRecognizer()
                    tap.add {
                        if let controller = self.delegate as? DialogController, controller.mode == .edit { return }
                        
                        self.delegate.openVideoController(ownerID: "\(attach.videos[0].ownerID)", vid: "\(attach.videos[0].id)", accessKey: attach.videos[0].accessKey, title: "Видеозапись", scrollToComment: false)
                    }
                    tap.numberOfTapsRequired = 1
                    video.isUserInteractionEnabled = true
                    video.addGestureRecognizer(tap)
                }
                
                heightTotal += 5 + height
            }
            
            if attach.type == "sticker" && attach.stickers.count > 0 {
                let width = rect.width - 10
                let height = width * CGFloat(attach.stickers[0].height) / CGFloat(attach.stickers[0].width)
                
                if drawCell {
                    let photo = UIImageView()
                    photo.tag = 200
                    let getCacheImage = GetCacheImage(url: attach.stickers[0].photo256, lifeTime: .avatarImage)
                    getCacheImage.completionBlock = {
                        OperationQueue.main.addOperation {
                            photo.image = getCacheImage.outputImage
                        }
                    }
                    OperationQueue().addOperation(getCacheImage)
                    
                    photo.frame = CGRect(x: 0, y: heightTotal + 5, width: width, height: height)
                    
                    view.addSubview(photo)
                }
                
                heightTotal += 5 + height
            }
            
            if attach.type == "wall" && attach.wall.count > 0 {
                attachCount += 1
                let view1 = configureWall(wall: attach.wall[0], users: users, topY: heightTotal + 5)
                
                if drawCell {
                    view1.frame = CGRect(x: 5, y: heightTotal + 5, width: rect.width - 10, height: view1.frame.height)
                    view.addSubview(view1)
                }
                
                heightTotal += 5 + view1.frame.height
            }
            
            if attach.type == "gift" && attach.gift.count > 0 {
                attachCount += 1
                let view1 = configureGift(gift: attach.gift[0], topY: heightTotal + 5)
                
                if drawCell {
                    view1.frame = CGRect(x: 5, y: heightTotal + 5, width: rect.width - 10, height: view1.frame.height)
                    view.addSubview(view1)
                }
                
                heightTotal += 5 + view1.frame.height
            }
            
            if attach.type == "doc" && attach.docs.count > 0 {
                attachCount += 1
                let view1 = configureDoc(doc: attach.docs[0], users: users, topY: heightTotal + 5)
                
                if drawCell {
                    var leftX: CGFloat = 5
                    if view1.frame.width < rect.width { leftX = 5 + (rect.width - view1.frame.width) / 2
                    }
                    view1.frame = CGRect(x: leftX, y: heightTotal + 5, width: rect.width - 10, height: view1.frame.height)
                    
                    view.addSubview(view1)
                }
                
                heightTotal += 5 + view1.frame.height
            }
            
            if attach.type == "audio" && attach.audio.count > 0 {
                attachCount += 1
                let view1 = configureAudio(audio: attach.audio[0], topY: heightTotal + 5)
                
                if drawCell {
                    view1.frame = CGRect(x: 5, y: heightTotal + 5, width: rect.width - 10, height: view1.frame.height)
                    view.addSubview(view1)
                }
                
                heightTotal += 5 + view1.frame.height
            }
            
            if attach.type == "link" && attach.link.count > 0 {
                attachCount += 1
                let view1 = configureLink(link: attach.link[0], topY: heightTotal + 5)
                
                if drawCell {
                    view1.frame = CGRect(x: 5, y: heightTotal + 5, width: rect.width - 10, height: view1.frame.height)
                    view.addSubview(view1)
                }
                
                heightTotal += 5 + view1.frame.height
            }
        }
        
        if attachCount > 0 {
            heightTotal += 5
        }
        
        view.frame = CGRect(x: 0, y: topY, width: rect.width, height: heightTotal)
        
        return view
    }
    
    func configureWall(wall: WallAttach, users: [DialogsUsers], topY: CGFloat) -> UIView {
        
        let width = 0.7 * UIScreen.main.bounds.width
        let height = 3 * leftInsets + 30 + 30
        
        let view = UIView()
        
        if drawCell {
            view.backgroundColor = vkSingleton.shared.backColor
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
                    avatar.layer.cornerRadius = 15
                    avatar.clipsToBounds = true
                    avatar.contentMode = .scaleAspectFill
                    avatar.layer.borderColor = vkSingleton.shared.secondaryLabelColor.cgColor
                    avatar.layer.borderWidth = 0.5
                }
            }
            OperationQueue().addOperation(getCacheImage)
            
            
            avatar.frame = CGRect(x: topInsets, y: leftInsets, width: 30, height: 30)
            view.addSubview(avatar)
            
            let nameLabel = UILabel()
            nameLabel.tag = 200
            nameLabel.text = name
            nameLabel.font = UIFont(name: "Verdana-Bold", size: 11)!
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.minimumScaleFactor = 0.5
            nameLabel.frame = CGRect(x: topInsets + leftInsets + 30, y: leftInsets, width: width - topInsets - 2 * leftInsets - 30, height: 16)
            view.addSubview(nameLabel)
            
            let dateLabel = UILabel()
            dateLabel.tag = 200
            dateLabel.text = wall.date.toStringLastTime()
            dateLabel.font = UIFont(name: "Verdana", size: 9)!
            dateLabel.adjustsFontSizeToFitWidth = true
            dateLabel.minimumScaleFactor = 0.5
            dateLabel.isEnabled = false
            dateLabel.frame = CGRect(x: topInsets + leftInsets + 30, y: leftInsets + 14, width: width - topInsets - 2 * leftInsets - 30, height: 16)
            view.addSubview(dateLabel)
            
            nameLabel.textColor = vkSingleton.shared.labelColor
            dateLabel.textColor = vkSingleton.shared.secondaryLabelColor
            
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
            bodyLabel.textColor = vkSingleton.shared.secondaryLabelColor
            bodyLabel.numberOfLines = 2
            bodyLabel.frame = CGRect(x: topInsets, y: 2 * leftInsets + 30, width: width - 2 * topInsets, height: 30)
            view.addSubview(bodyLabel)
        }
        
        view.frame = CGRect(x: 5, y: topY, width: width, height: height)
        
        if drawCell {
            view.layer.borderColor = vkSingleton.shared.secondaryLabelColor.cgColor
            view.layer.borderWidth = 0.6
            view.layer.cornerRadius = height/4
            view.backgroundColor = vkSingleton.shared.backColor
            
            let tap = UITapGestureRecognizer()
            tap.add {
                if let controller = self.delegate as? DialogController, controller.mode == .edit { return }
                
                view.viewTouched(controller: self.delegate)
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let action1 = UIAlertAction(title: "Открыть запись на стене", style: .default) { action in
                    
                    self.delegate.openWallRecord(ownerID: wall.fromID, postID: wall.id, accessKey: "", type: "post", scrollToComment: false)
                }
                alertController.addAction(action1)
                
                self.delegate.present(alertController, animated: true)
            }
            tap.numberOfTapsRequired = 1
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(tap)
        }
        
        return view
    }
    
    func configureGift(gift: GiftAttach, topY: CGFloat) -> UIView {
        
        let width: CGFloat = 150
        let height = width + 15
        
        let view = UIView()
        
        if drawCell {
            view.backgroundColor = vkSingleton.shared.backColor
            view.tag = 200
            
            let statusLabel = UILabel()
            statusLabel.tag = 200
            statusLabel.text = "Подарок"
            statusLabel.textAlignment = .center
            statusLabel.font = UIFont(name: "Verdana", size: 9)!
            statusLabel.textColor = vkSingleton.shared.secondaryLabelColor
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
        
            view.layer.borderColor = vkSingleton.shared.secondaryLabelColor.cgColor
            view.layer.borderWidth = 0.6
            view.layer.cornerRadius = 13
        }
        
        view.frame = CGRect(x: 5, y: topY, width: width, height: height)
            
        return view
    }
    
    func configureDoc(doc: DocAttach, users: [DialogsUsers], topY: CGFloat) -> UIView {
        
        var width: CGFloat = 0.7 * UIScreen.main.bounds.width
        var height: CGFloat = 0
        
        if doc.type == 4 && !doc.link.isEmpty {
            width = 0.5 * UIScreen.main.bounds.width
        }
        
        let view = UIView()
        
        if drawCell {
            view.backgroundColor = vkSingleton.shared.backColor
            view.layer.borderColor = vkSingleton.shared.secondaryLabelColor.cgColor
            view.layer.borderWidth = 0.6
            view.tag = 200
        }
        
        if doc.ext == "ogg" {
            var selfY: CGFloat = leftInsets
            
            if drawCell {
                let avatar = UIImageView()
                avatar.image = UIImage(named: "mic")
                avatar.tintColor = .black
                avatar.frame = CGRect(x: leftInsets, y: selfY + 2, width: 26, height: 26)
                view.addSubview(avatar)
                
                let titleLabel = UILabel()
                titleLabel.tag = 200
                titleLabel.text = "Голосовое сообщение"
                titleLabel.numberOfLines = 2
                titleLabel.font = UIFont(name: "Verdana-Bold", size: 12)!
                titleLabel.adjustsFontSizeToFitWidth = true
                titleLabel.minimumScaleFactor = 0.6
                titleLabel.frame = CGRect(x: leftInsets + 30, y: selfY, width: width - 2 * leftInsets - 30, height: 15)
                view.addSubview(titleLabel)
                selfY += 15
                
                let timeInMinutes = doc.duration / 60;
                let timeInSeconds = doc.duration % 60;
                
                let linkLabel = UILabel()
                linkLabel.tag = 200
                linkLabel.text = String(format: "%02d:%02d", arguments: [timeInMinutes,timeInSeconds])
                linkLabel.textColor = linkLabel.tintColor
                linkLabel.font = UIFont(name: "Verdana", size: 12)!
                linkLabel.adjustsFontSizeToFitWidth = true
                linkLabel.minimumScaleFactor = 0.6
                linkLabel.backgroundColor = UIColor.clear
                linkLabel.numberOfLines = 1
                
                titleLabel.textColor = vkSingleton.shared.labelColor
                linkLabel.textColor = vkSingleton.shared.secondaryLabelColor
                avatar.tintColor = vkSingleton.shared.labelColor
                
                linkLabel.frame = CGRect(x: leftInsets + 30, y: selfY, width: width - 2 * leftInsets - 30, height: 15)
                view.addSubview(linkLabel)
                
                selfY += 15
                
                let tap = UITapGestureRecognizer()
                tap.add {
                    view.viewTouched(controller: self.delegate)
                    
                    if let controller = self.delegate as? DialogController {
                        if let url = URL(string: doc.linkMP3) {
                            controller.player = AVPlayer(url: url)
                            controller.player.seek(to: CMTime.zero)
                            controller.player.play()
                            controller.showAudioMessageOnScreen(doc: doc, users: users, player: controller.player)
                        }
                    } else if let controller = self.delegate as? GroupDialogController {
                        if let url = URL(string: doc.linkMP3) {
                            controller.player = AVPlayer(url: url)
                            controller.player.seek(to: CMTime.zero)
                            controller.player.play()
                            controller.showAudioMessageOnScreen(doc: doc, users: users, player: controller.player)
                        }
                    }
                }
                view.isUserInteractionEnabled = true
                view.addGestureRecognizer(tap)
            } else {
                selfY += 30
            }
            
            height = selfY + leftInsets
            
        } else if doc.type == 4 && !doc.link.isEmpty {
            height = width
            if doc.width > 0 {
                height = width * CGFloat(doc.height) / CGFloat(doc.width)
            }
            
            if drawCell {
                let photo = UIImageView()
                photo.tag = 200
                let getCacheImage = GetCacheImage(url: doc.link, lifeTime: .avatarImage)
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        photo.image = getCacheImage.outputImage
                        photo.layer.cornerRadius = 0
                        photo.layer.borderWidth = 0
                        photo.clipsToBounds = true
                        photo.contentMode = .scaleAspectFill
                        photo.backgroundColor = .clear
                    }
                }
                OperationQueue().addOperation(getCacheImage)
                
                photo.frame = CGRect(x: 0, y: 0, width: width, height: height)
                view.backgroundColor = .clear
                view.layer.borderWidth = 0
                view.addSubview(photo)
            }
        } else {
            if drawCell {
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
                statusLabel.textColor = vkSingleton.shared.secondaryLabelColor
                statusLabel.frame = CGRect(x: leftInsets, y: leftInsets, width: width - 2 * leftInsets, height: 15)
                view.addSubview(statusLabel)
                
                
                let nameLabel = UILabel()
                nameLabel.tag = 200
                nameLabel.text = doc.title
                nameLabel.textColor = vkSingleton.shared.labelColor
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
                    if let controller = self.delegate as? DialogController, controller.mode == .edit { return }
                    
                    view.viewTouched(controller: self.delegate)
                    
                    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                        
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                    alertController.addAction(cancelAction)
                    
                    let action1 = UIAlertAction(title: "Открыть документ", style: .default) { action in
                        
                        self.delegate.openBrowserControllerNoCheck(url: doc.url)
                    }
                    alertController.addAction(action1)
                    
                    self.delegate.present(alertController, animated: true)
                }
            }
            
            height = 2 * leftInsets + 15 + 30 + 20
        }
        
        view.frame = CGRect(x: 5, y: topY, width: width, height: height)
        
        if drawCell { view.layer.cornerRadius = height/4 }
        
        return view
    }
    
    func configureAudio(audio: AudioAttach, topY: CGFloat) -> UIView {
        
        let width: CGFloat = 0.7 * UIScreen.main.bounds.width
        var selfY: CGFloat = leftInsets
        
        let view = UIView()
        
        if drawCell {
            view.tag = 200
            
            let avatar = UIImageView()
            avatar.image = UIImage(named: "music")
            avatar.frame = CGRect(x: leftInsets, y: selfY + 2, width: 26, height: 26)
            view.addSubview(avatar)
            
            let titleLabel = UILabel()
            titleLabel.tag = 200
            titleLabel.text = audio.artist
            titleLabel.numberOfLines = 2
            titleLabel.font = UIFont(name: "Verdana-Bold", size: 12)!
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.minimumScaleFactor = 0.6
            titleLabel.frame = CGRect(x: leftInsets + 30, y: selfY, width: width - 2 * leftInsets - 30, height: 15)
            view.addSubview(titleLabel)
            selfY += 15
            
            let linkLabel = UILabel()
            linkLabel.tag = 200
            linkLabel.text = audio.title
            linkLabel.font = UIFont(name: "Verdana", size: 12)!
            linkLabel.adjustsFontSizeToFitWidth = true
            linkLabel.minimumScaleFactor = 0.6
            linkLabel.backgroundColor = UIColor.clear
            linkLabel.numberOfLines = 1
            
            titleLabel.textColor = vkSingleton.shared.labelColor
            linkLabel.textColor = vkSingleton.shared.secondaryLabelColor
            
            linkLabel.frame = CGRect(x: leftInsets + 30, y: selfY, width: width - 2 * leftInsets - 30, height: 15)
            view.addSubview(linkLabel)
            
            let height =  selfY + 15 + leftInsets
            
            view.frame = CGRect(x: 5, y: topY, width: width, height: height)
            view.layer.borderColor = vkSingleton.shared.secondaryLabelColor.cgColor
            view.layer.borderWidth = 0.6
            view.layer.cornerRadius = height/4
            view.backgroundColor = vkSingleton.shared.backColor
            
            let tap = UITapGestureRecognizer()
            tap.add {
                view.viewTouched(controller: self.delegate)
                
                self.delegate.getITunesInfo2(artist: audio.artist, title: audio.title)
            }
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(tap)
        } else {
            let height =  leftInsets + 15 + 15 + leftInsets
            view.frame = CGRect(x: 5, y: topY, width: width, height: height)
        }
        
        return view
    }
    
    func configureLink(link: LinkAttach, topY: CGFloat) -> UIView {
        
        let width: CGFloat = 0.7 * UIScreen.main.bounds.width
        var selfY: CGFloat = leftInsets
        
        let view = UIView()
        
        if drawCell {
            view.tag = 200
            
            let avatar = UIImageView()
            avatar.image = UIImage(named: "link")
            avatar.frame = CGRect(x: leftInsets, y: selfY + 2, width: 26, height: 26)
            avatar.tintColor = vkSingleton.shared.labelColor
            view.addSubview(avatar)
            
            let titleLabel = UILabel()
            titleLabel.tag = 200
            titleLabel.text = "Внешняя ссылка"
            if link.title != "" {
                titleLabel.text = link.title
            }
            titleLabel.numberOfLines = 1
            titleLabel.font = UIFont(name: "Verdana-Bold", size: 12)!
            //titleLabel.adjustsFontSizeToFitWidth = true
            //titleLabel.minimumScaleFactor = 0.6
            titleLabel.frame = CGRect(x: leftInsets + 30, y: selfY, width: width - 2 * leftInsets - 30, height: 15)
            view.addSubview(titleLabel)
            selfY += 15
            
            let linkLabel = UILabel()
            linkLabel.tag = 200
            linkLabel.text = link.url
            linkLabel.font = UIFont(name: "Verdana", size: 12)!
            //linkLabel.adjustsFontSizeToFitWidth = true
            //linkLabel.minimumScaleFactor = 0.6
            linkLabel.textColor = linkLabel.tintColor
            linkLabel.numberOfLines = 1
            
            titleLabel.textColor = vkSingleton.shared.labelColor
            linkLabel.textColor = vkSingleton.shared.secondaryLabelColor
            
            linkLabel.frame = CGRect(x: leftInsets + 30, y: selfY, width: width - 2 * leftInsets - 30, height: 15)
            view.addSubview(linkLabel)
            
            let height =  selfY + 15 + leftInsets
            view.frame = CGRect(x: 5, y: topY, width: width, height: height)
            view.layer.borderColor = vkSingleton.shared.secondaryLabelColor.cgColor
            view.layer.borderWidth = 0.6
            view.layer.cornerRadius = height/4
            view.backgroundColor = vkSingleton.shared.backColor
            
            let tap = UITapGestureRecognizer()
            tap.add {
                view.viewTouched(controller: self.delegate)
                
                let alertController = UIAlertController(title: titleLabel.text!, message: linkLabel.text!, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let action1 = UIAlertAction(title: "Перейти по ссылке", style: .default) { action in
                    
                    self.delegate.openBrowserController(url: link.url)
                }
                alertController.addAction(action1)
                
                let action2 = UIAlertAction(title: "Открыть ссылку в Safari", style: .default) { action in
                    
                    if let url = URL(string: link.url) {
                        UIApplication.shared.open(url, options: [:])
                    }
                }
                alertController.addAction(action2)
                
                let action3 = UIAlertAction(title: "Скопировать в буфер обмена", style: .default) { action in
                    
                    UIPasteboard.general.string = link.url
                    if let string = UIPasteboard.general.string {
                        self.delegate.showInfoMessage(title: "Ссылка скопирована в буфер обмена:\n" , msg: "\(string)")
                    }
                }
                alertController.addAction(action3)
                
                self.delegate.present(alertController, animated: true)
            }
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(tap)
        } else {
            let height =  leftInsets + 15 + 15 + leftInsets
            view.frame = CGRect(x: 5, y: topY, width: width, height: height)
        }
        
        return view
    }
}

class ClosureSleeve {
    let closure: ()->()
    
    init (_ closure: @escaping ()->()) {
        self.closure = closure
    }
    
    @objc func invoke () {
        closure()
    }
}

extension UIControl {
    func add (for controlEvents: UIControl.Event, _ closure: @escaping ()->()) {
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}

extension UITapGestureRecognizer {
    func add (_ closure: @escaping ()->()) {
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke))
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}

extension UILongPressGestureRecognizer {
    func add (_ closure: @escaping ()->()) {
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke))
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}

extension Array where Element: Equatable {
    
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}

extension UIView {
    
    func configureMessageView(out: Int, radius: CGFloat, border: CGFloat) {
        
        if #available(iOS 11.0, *) {
            self.layer.borderColor = vkSingleton.shared.secondaryLabelColor.cgColor
            self.layer.borderWidth = border
            self.layer.cornerRadius = radius
            if out == 0 {
                self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            } else {
                self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner]
            }
        } else {
            if out == 0 {
                self.roundCorners([.bottomLeft, .bottomRight, .topRight], radius: radius)
            } else {
                self.roundCorners([.bottomLeft, .bottomRight, .topLeft], radius: radius)
            }
        }
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        
        let mask = CAShapeLayer()
        mask.bounds = self.frame
        mask.position = self.center
        //mask.borderColor = UIColor.gray.cgColor
        //mask.borderWidth = 1
        
        mask.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        
        self.layer.mask = mask
    }
}
