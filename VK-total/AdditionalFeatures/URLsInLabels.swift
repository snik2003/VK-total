//
//  URLsInLabels.swift
//  VK-total
//
//  Created by Сергей Никитин on 25.05.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Popover

extension String {
    
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            let finalResult = results.map {
                String(self[Range($0.range, in: self)!])
            }
            return finalResult
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func getNameFromLink() -> String {
        
        var name = ""
        let textArray = self.components(separatedBy: ["[","]"])
        for arr in textArray {
            if arr.containsIgnoringCase(find: "|") {
                let arr1 = arr.components(separatedBy: "|")
                for index in 1...arr1.count-1 {
                    if name != "" {
                        name = "\(name)|"
                    }
                    name = "\(name)\(arr1[index])"
                }
            }
        }
        
        return name
    }
    
    func getIdFromLink() -> String {
        
        var sid = ""
        let textArray = self.components(separatedBy: ["[","]"])
        for arr in textArray {
            if arr.containsIgnoringCase(find: "|") {
                var arr1 = arr.components(separatedBy: "|")
                if arr1[0].containsIgnoringCase(find: ":") {
                    var arr2 = arr1[0].components(separatedBy: ":")
                    sid = arr2[0]
                } else {
                    sid = arr1[0]
                }
            }
        }
        
        return sid
    }
    
    func prepareTextForPublic() -> String {
        
        var text = self.replacingOccurrences(of: "<br>", with: "\n")
        text = text.replacingOccurrences(of: "&quot;", with: "\"")
        
        let regex1 = "\\[[\\w\\:\\-\\_]+\\|[\\s\\w\\|\\.\\,\\!\\@\\-\\<\\>\\\"\\\"\\≪\\≫\\«\\»\\?]+\\]"
        let allMatches1 = text.matches(for: regex1)
        
        for match in allMatches1 {
            text = text.replacingOccurrences(of: match, with: match.getNameFromLink())
        }
        
        return text
    }
}

extension UILabel {
    
    func didTapAttributedTextInLabel2(tap: UITapGestureRecognizer, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines
        
        let labelSize = self.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = tap.location(in: self)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
    func prepareTextForPublish2(_ delegate: UIViewController) {
        if var text = self.text {
            
            text = text.replacingOccurrences(of: "<br>", with: "\n")
            text = text.replacingOccurrences(of: "&quot;", with: "\"")
            
            // внутренние ссылки ВК
            let regex1 = "\\[[\\w\\:\\-\\_]+\\|[\\s\\w\\|\\.\\,\\!\\@\\-\\<\\>\\\"\\\"\\≪\\≫\\«\\»\\?]+\\]"
            let allMatches1 = text.matches(for: regex1)
            var ranges1: [String:NSRange] = [:]
            
            for match in allMatches1 {
                text = text.replacingOccurrences(of: match, with: match.getNameFromLink())
            }
            
            let fullString = text
            let attributedString = NSMutableAttributedString(string: fullString)
            attributedString.setAttributes([NSAttributedStringKey.font: self.font], range: NSRange(location: 0, length: fullString.length))
            
            for match in allMatches1 {
                let range = (fullString as NSString).range(of: match.getNameFromLink())
                
                attributedString.addAttributes([NSAttributedStringKey.foregroundColor: self.tintColor], range: range)
                
                ranges1[match] = range
            }
            
            // хэштеги
            let regex2 = "#[\\w\\@\\-\\.\\_]+\\b"
            let allMatches2 = fullString.matches(for: regex2)
            var ranges2: [String:NSRange] = [:]

            for match in allMatches2 {
                let range = (fullString as NSString).range(of: match)

                ranges2[match] = range
            }

            let regex22 = try! NSRegularExpression(pattern: "#[\\w\\@\\-\\.\\_]+\\b", options: [])
            let allMatches22 = regex22.matches(in: fullString, options:[], range:NSMakeRange(0, fullString.length))
            
            for match in allMatches22 {
                attributedString.addAttributes([NSAttributedStringKey.foregroundColor: self.tintColor], range: match.range)
            }
            
            // url'ы
            let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let allMatches3 = detector.matches(in: fullString, options: [], range: NSRange(location: 0, length: fullString.length))
            var ranges3: [String:NSRange] = [:]
            
            for match in allMatches3 {
                attributedString.addAttributes([NSAttributedStringKey.foregroundColor: self.tintColor], range: match.range)
                
                if let url = match.url {
                    ranges3[url.absoluteString] = match.range
                }
            }
            
            let tap = UITapGestureRecognizer()
            
            tap.numberOfTapsRequired = 1
            self.attributedText = attributedString
            self.addGestureRecognizer(tap)
            self.isUserInteractionEnabled = true
            
            tap.add {
                var isTap = false
                
                for match in ranges1.keys {
                    if let range = ranges1[match] {
                        if self.didTapAttributedTextInLabel2(tap: tap, inRange: range) {
                            isTap = true
                            delegate.popoverHideAll()
                            delegate.openBrowserController(url: "https://vk.com/\(match.getIdFromLink())")
                        }
                    }
                }
                
                for match in ranges2.keys {
                    if let range = ranges2[match] {
                        if self.didTapAttributedTextInLabel2(tap: tap, inRange: range) {
                            isTap = true
                            delegate.popoverHideAll()
                            delegate.openNewsfeedSearchController(ownerID: Int(vkSingleton.shared.userID)!, hash: match)
                        }
                    }
                }
                
                for match in ranges3.keys {
                    if let range = ranges3[match] {
                        if self.didTapAttributedTextInLabel2(tap: tap, inRange: range) {
                            isTap = true
                            delegate.popoverHideAll()
                            delegate.openBrowserController(url: match)
                        }
                    }
                }
                
                if isTap == false {
                    print("tap nithing")
                    
                    if let vc = delegate as? Record2Controller {
                        
                        if tap.state == .ended {
                            let buttonPosition: CGPoint = tap.location(in: vc.tableView)
                            
                            if let indexPath = vc.tableView.indexPathForRow(at: buttonPosition) {
                                if indexPath.section == 0 {
                                    let record = vc.news[indexPath.row]
                                    if let cell = vc.tableView.cellForRow(at: indexPath) as? Record2Cell {
                                        if self == cell.repostTextLabel {
                                            vc.openWallRecord(ownerID: record.repostOwnerID, postID: record.repostID, accessKey: "", type: "post")
                                        }
                                    }
                                } else {
                                    vc.selectComment(sender: tap)
                                }
                            }
                        }
                        
                    } else if let vc = delegate as? VideoController {
                        
                        vc.selectComment(sender: tap)
                        
                    } else if let vc = delegate as? TopicController {
                        
                        vc.selectComment(sender: tap)
                        
                    } else if let vc = delegate as? VideoListController {
                        
                        if tap.state == .ended {
                            let buttonPosition: CGPoint = tap.location(in: vc.tableView)
                            
                            if let indexPath = vc.tableView.indexPathForRow(at: buttonPosition), let cell = vc.tableView.cellForRow(at: indexPath) as? VideoListCell {
                                
                                let video = vc.videos[indexPath.row]
                                
                                if vc.source != "" {
                                    if vc.markPhotos[video.id] != nil {
                                        vc.markPhotos[video.id] = nil
                                    } else {
                                        vc.markPhotos[video.id] = cell.videoImage.image!
                                    }
                                    vc.tableView.reloadRows(at: [indexPath], with: .automatic)
                                    
                                    if vc.markPhotos.count > 0 {
                                        vc.selectButton.isEnabled = true
                                        vc.selectButton.title = "Вложить (\(vc.markPhotos.count))"
                                    } else {
                                        vc.selectButton.isEnabled = false
                                        vc.selectButton.title = "Вложить"
                                    }
                                } else {
                                    vc.openVideoController(ownerID: "\(video.ownerID)", vid: "\(video.id)", accessKey: video.accessKey, title: "Видеозапись")
                                }
                            }
                        }
                        
                    } else if let vc = delegate as? ProfileController2 {
                        
                        if tap.state == .ended {
                            let buttonPosition: CGPoint = tap.location(in: vc.tableView)
                            
                            if let indexPath = vc.tableView.indexPathForRow(at: buttonPosition) {
                                let record = vc.wall[indexPath.section]
                                vc.openWallRecord(ownerID: record.ownerID, postID: record.id, accessKey: "", type: "post")
                            }
                        }
                        
                    } else if let vc = delegate as? GroupProfileController2 {
                        
                        if tap.state == .ended {
                            let buttonPosition: CGPoint = tap.location(in: vc.tableView)
                            
                            if let indexPath = vc.tableView.indexPathForRow(at: buttonPosition) {
                                let record = vc.wall[indexPath.section]
                                vc.openWallRecord(ownerID: record.ownerID, postID: record.id, accessKey: "", type: "post")
                            }
                        }
        
                    } else if let vc = delegate as? PostponedWallController {
                        
                        if tap.state == .ended {
                            let buttonPosition: CGPoint = tap.location(in: vc.tableView)
                            
                            if let indexPath = vc.tableView.indexPathForRow(at: buttonPosition) {
                                let record = vc.wall[indexPath.section]
                                vc.openWallRecord(ownerID: record.ownerID, postID: record.id, accessKey: "", type: "post")
                            }
                        }
                        
                    } else if let vc = delegate as? Newsfeed2Controller {
                        
                        if tap.state == .ended {
                            let buttonPosition: CGPoint = tap.location(in: vc.tableView)
                            
                            if let indexPath = vc.tableView.indexPathForRow(at: buttonPosition) {
                                let record = vc.news[indexPath.section]
                                vc.openWallRecord(ownerID: record.sourceID, postID: record.postID, accessKey: "", type: "post")
                            }
                        }
                        
                    } else if let vc = delegate as? Newsfeed2Controller {
                        
                        if tap.state == .ended {
                            let buttonPosition: CGPoint = tap.location(in: vc.tableView)
                            
                            if let indexPath = vc.tableView.indexPathForRow(at: buttonPosition) {
                                let record = vc.news[indexPath.section]
                                vc.openWallRecord(ownerID: record.sourceID, postID: record.postID, accessKey: "", type: "post")
                            }
                        }
                        
                    } else if let vc = delegate as? NewsfeedSearchController {
                        
                        if tap.state == .ended {
                            let buttonPosition: CGPoint = tap.location(in: vc.tableView)
                            
                            if let indexPath = vc.tableView.indexPathForRow(at: buttonPosition) {
                                let record = vc.wall[indexPath.section]
                                vc.openWallRecord(ownerID: record.ownerID, postID: record.id, accessKey: "", type: "post")
                            }
                        }
                        
                    } else if let vc = delegate as? FavePostsController2 {
                        
                        if tap.state == .ended {
                            let buttonPosition: CGPoint = tap.location(in: vc.tableView)
                            
                            if let indexPath = vc.tableView.indexPathForRow(at: buttonPosition) {
                                switch vc.source {
                                case "post":
                                    let record = vc.wall[indexPath.section]
                                    vc.openWallRecord(ownerID: record.ownerID, postID: record.id, accessKey: "", type: "post")
                                case "video":
                                    let video = vc.videos[indexPath.row]
                                    
                                    vc.openVideoController(ownerID: "\(video.ownerID)", vid: "\(video.id)", accessKey: video.accessKey, title: "Видеозапись")
                                default:
                                    break
                                }
                            }
                        }
                        
                    }
                }
            }
            
            
            let longPress = UILongPressGestureRecognizer()
            longPress.minimumPressDuration = 0.5
            self.addGestureRecognizer(longPress)
            
            var isLongPress = false
            
            longPress.add {
                for match in ranges3.keys {
                    if let range = ranges3[match] {
                        if self.didTapAttributedTextInLabel2(tap: tap, inRange: range) {
                            isLongPress = true
                            delegate.popoverHideAll()
                            
                            let alertController = UIAlertController(title: match, message: "", preferredStyle: .actionSheet)
                            
                            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                            alertController.addAction(cancelAction)
                            
                            let action1 = UIAlertAction(title: "Перейти по ссылке", style: .default) { action in
                                
                                delegate.openBrowserController(url: match)
                            }
                            alertController.addAction(action1)
                            
                            let action2 = UIAlertAction(title: "Скопировать ссылку", style: .default) { action in
                                
                                UIPasteboard.general.string = match
                                if let string = UIPasteboard.general.string {
                                    delegate.showInfoMessage(title: "Ссылка скопирована в буфер обмена:\n" , msg: "\(string)")
                                }
                            }
                            alertController.addAction(action2)
                            
                            let action3 = UIAlertAction(title: "Открыть ссылку в Safari", style: .destructive) { action in
                                
                                if let url = URL(string: match) {
                                    UIApplication.shared.open(url, options: [:])
                                }
                            }
                            alertController.addAction(action3)
                            
                            delegate.present(alertController, animated: true, completion: { () -> Void in
                                isLongPress = false
                            })
                        }
                    }
                }
                
                if isLongPress == false {
                    self.becomeFirstResponder()
                    let menu = UIMenuController.shared
                    if !menu.isMenuVisible {
                        menu.setTargetRect(self.bounds, in: self)
                        menu.setMenuVisible(true, animated: true)
                    }
                }
            }
            self.text = text
        }
    }
}
