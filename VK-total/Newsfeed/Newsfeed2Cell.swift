//
//  Newsfeed2Cell.swift
//  VK-total
//
//  Created by Сергей Никитин on 10.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import FLAnimatedImage
import SwiftyJSON
import WebKit

class Newsfeed2Cell: UITableViewCell {

    @IBOutlet weak var repostsButton: UIButton! {
        didSet { repostsButton.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var commentsButton: UIButton! {
        didSet { commentsButton.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var likesButton: UIButton! {
        didSet { likesButton.translatesAutoresizingMaskIntoConstraints = false } }
    var viewsButton = UIButton()
    
    @IBOutlet weak var musicTitle10: UILabel! {
        didSet { musicTitle10.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicTitle9: UILabel! {
        didSet { musicTitle9.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicTitle8: UILabel! {
        didSet { musicTitle8.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicTitle7: UILabel! {
        didSet { musicTitle7.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicTitle6: UILabel! {
        didSet { musicTitle6.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicTitle5: UILabel! {
        didSet { musicTitle5.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicTitle4: UILabel! {
        didSet { musicTitle4.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicTitle3: UILabel! {
        didSet { musicTitle3.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicTitle2: UILabel! {
        didSet { musicTitle2.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicTitle1: UILabel! {
        didSet { musicTitle1.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicArtist10: UILabel! {
        didSet { musicArtist10.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicArtist9: UILabel! {
        didSet { musicArtist9.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicArtist8: UILabel! {
        didSet { musicArtist8.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicArtist7: UILabel! {
        didSet { musicArtist7.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicArtist6: UILabel! {
        didSet { musicArtist6.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicArtist5: UILabel! {
        didSet { musicArtist5.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicArtist4: UILabel! {
        didSet { musicArtist4.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicArtist3: UILabel! {
        didSet { musicArtist3.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicArtist2: UILabel! {
        didSet { musicArtist2.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicArtist1: UILabel! {
        didSet { musicArtist1.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicImage10: UIImageView! {
        didSet { musicImage10.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicImage9: UIImageView! {
        didSet { musicImage9.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicImage8: UIImageView! {
        didSet { musicImage8.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicImage7: UIImageView! {
        didSet { musicImage7.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicImage6: UIImageView! {
        didSet { musicImage6.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicImage5: UIImageView! {
        didSet { musicImage5.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicImage4: UIImageView! {
        didSet { musicImage4.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicImage3: UIImageView! {
        didSet { musicImage3.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicImage2: UIImageView! {
        didSet { musicImage2.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var musicImage1: UIImageView! {
        didSet { musicImage1.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var linkNameLabel10: UILabel! {
        didSet { linkNameLabel10.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var linkNameLabel9: UILabel! {
        didSet { linkNameLabel9.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var linkNameLabel8: UILabel! {
        didSet { linkNameLabel8.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var linkNameLabel7: UILabel! {
        didSet { linkNameLabel7.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var linkNameLabel6: UILabel! {
        didSet { linkNameLabel6.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var linkNameLabel5: UILabel! {
        didSet { linkNameLabel5.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var linkNameLabel4: UILabel! {
        didSet { linkNameLabel4.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var linkNameLabel3: UILabel! {
        didSet { linkNameLabel3.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var linkNameLabel2: UILabel! {
        didSet { linkNameLabel2.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var linkNameLabel1: UILabel! {
        didSet { linkNameLabel1.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var linkImage10: UIImageView! {
        didSet { linkImage10.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var linkImage9: UIImageView! {
        didSet { linkImage9.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var linkImage8: UIImageView! {
        didSet { linkImage8.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var linkImage7: UIImageView! {
        didSet { linkImage7.translatesAutoresizingMaskIntoConstraints = false } }
   @IBOutlet weak var linkImage6: UIImageView! {
        didSet { linkImage6.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var linkImage5: UIImageView! {
        didSet { linkImage5.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var linkImage4: UIImageView! {
        didSet { linkImage4.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var linkImage3: UIImageView! {
        didSet { linkImage3.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var linkImage2: UIImageView! {
        didSet { linkImage2.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var linkImage1: UIImageView! {
        didSet { linkImage1.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var imageView10: UIImageView! {
        didSet { imageView10.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var imageView9: UIImageView! {
        didSet { imageView9.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var imageView8: UIImageView! {
        didSet { imageView8.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var imageView7: UIImageView! {
        didSet { imageView7.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var imageView6: UIImageView! {
        didSet { imageView6.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var imageView5: UIImageView! {
        didSet { imageView5.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var imageView4: UIImageView! {
        didSet { imageView4.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var imageView3: UIImageView! {
        didSet { imageView3.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var imageView2: UIImageView! {
        didSet { imageView2.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var imageView1: UIImageView! {
        didSet { imageView1.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var repostDateLabel: UILabel! {
        didSet { repostDateLabel.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var repostNameLabel: UILabel! {
        didSet { repostNameLabel.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var repostAvatarImageView: UIImageView! {
        didSet { repostAvatarImageView.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var readMoreButton: UIButton! {
        didSet { readMoreButton.translatesAutoresizingMaskIntoConstraints = false } }
    
    let postTextLabel = KGCopyableLabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    let repostTextLabel = KGCopyableLabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    
    var linkImage = UIImageView()
    var linkLabel = KGCopyableLabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    var signerLabel = UILabel()
    
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet { avatarImageView.translatesAutoresizingMaskIntoConstraints = false }}
    
    @IBOutlet weak var nameLabel: UILabel! {
        didSet { nameLabel.translatesAutoresizingMaskIntoConstraints = false }}
    
    @IBOutlet weak var datePostLabel: UILabel! {
        didSet { datePostLabel.translatesAutoresizingMaskIntoConstraints = false }}
    
    @IBOutlet weak var repostReadMoreButton: UIButton! {
        didSet { repostReadMoreButton.translatesAutoresizingMaskIntoConstraints = false }}
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    var delegate: UIViewController!
    
    var position: CGPoint = CGPoint.zero
    
    var readMoreButtonTapped = false
    var readMoreButtonTapped2 = false
    
    let avatarImageSize: CGFloat = 60.0
    let repostAvatarImageSize: CGFloat = 44.0
    
    let textFont: UIFont = UIFont(name: "Verdana", size: 15.0)!
    let linkFont: UIFont = UIFont(name: "Verdana", size: 12.0)!
    
    let audioImageSize: CGFloat = 30.0
    let linkImageSize: CGFloat = 100.0
    let topLinkInsets: CGFloat = 5.0
    
    let leftInsets: CGFloat = 10.0
    let topInsets: CGFloat = 10.0
    
    let topNameLabelInsets: CGFloat = 20.0
    let nameLabelHeight: CGFloat = 21.0
    
    let dateLabelHeight: CGFloat = 18.0
    
    let verticalSpacingElements: CGFloat = 5.0
    
    let readMoreLevel: CGFloat = 190.0
    
    let likesButtonWidth: CGFloat = 80.0
    let repostsButtonWidth: CGFloat = 70.0
    let likesButtonHeight: CGFloat = 40.0
    
    let signerLabelHeight: CGFloat = 22.0
    let signerFont = UIFont.boldSystemFont(ofSize: 15) //UIFont(name: "Verdana-Bold", size: 13)!
    
    let qLabelFont = UIFont(name: "Verdana-Bold", size: 13)!
    let aLabelFont = UIFont(name: "Verdana", size: 12)!
    
    var answerLabels: [UILabel] = []
    var rateLabels: [UILabel] = []
    var totalLabel = UILabel()
    var poll: Poll!
    
    var webView: WKWebView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImageViewFrame()
        nameLabelFrame()
        datePostLabelFrame()
        readMoreButtonFrame()
    }
    
    func configureCell(record: News, profiles: [NewsProfiles], groups: [NewsGroups], videos: [Videos], indexPath: IndexPath, tableView: UITableView, cell: UITableViewCell, viewController: UIViewController) -> CGFloat {
        
        self.backgroundColor = vkSingleton.shared.backColor
        
        for subview in self.subviews {
            if subview.tag == 100 {
                subview.removeFromSuperview()
            }
            if subview is UIImageView || subview is UILabel || subview is UIButton || subview is WKWebView {
                subview.removeFromSuperview()
            }
        }
        
        signerLabel.text = ""
        postTextLabel.text = ""
        repostTextLabel.text = ""
        
        answerLabels.removeAll(keepingCapacity: false)
        rateLabels.removeAll(keepingCapacity: false)
        
        var url = ""
        var name = ""
        
        if record.sourceID > 0 {
            let users = profiles.filter( { $0.uid == record.sourceID } )
            if users.count > 0 {
                url = users[0].photoURL
                name = "\(users[0].firstName) \(users[0].lastName)"
            }
        } else {
            let groups = groups.filter( { $0.gid == abs(record.sourceID) } )
            if groups.count > 0 {
                url = groups[0].photoURL
                name = groups[0].name
            }
        }
    
        var getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        var setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImageView, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        queue.addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            self.avatarImageView.layer.cornerRadius = 29
            self.avatarImageView.clipsToBounds = true
        }
        
        
        nameLabel.textColor = vkSingleton.shared.labelColor
        repostNameLabel.textColor = vkSingleton.shared.labelColor
        datePostLabel.textColor = vkSingleton.shared.secondaryLabelColor
        repostDateLabel.textColor = vkSingleton.shared.secondaryLabelColor
        postTextLabel.textColor = vkSingleton.shared.labelColor
        repostTextLabel.textColor = vkSingleton.shared.labelColor
        
        
        nameLabel.text = name
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        
        datePostLabel.text = record.date.toStringLastTime()
        if record.postSource != "" {
            datePostLabel.setSourceOfRecord(text: " \(datePostLabel.text!)", source: record.postSource, delegate: viewController)
        }
        
        readMoreButton.setTitleColor(UIColor.init(red: 20/255, green: 120/255, blue: 246/255, alpha: 1), for: .normal)
        repostReadMoreButton.setTitleColor(UIColor.init(red: 20/255, green: 120/255, blue: 246/255, alpha: 1), for: .normal)
        
        if record.readMore1 == 0 {
            readMoreButtonTapped = true
        }
        postTextLabel.text = record.text //.prepareTextForPublic()
        postTextLabel.prepareTextForPublish2(viewController)
        postTextLabel.font = textFont
        postTextLabel.numberOfLines = 0
        
        repostTextLabel.text = ""
        repostTextLabel.font = textFont
        repostTextLabel.numberOfLines = 0
        
        if record.repostOwnerID != 0 {
            if record.repostOwnerID > 0 {
                let users = profiles.filter( { $0.uid == record.repostOwnerID } )
                if users.count > 0 {
                    url = users[0].photoURL
                    name = "\(users[0].firstName) \(users[0].lastName)"
                }
            } else {
                let groups = groups.filter( { $0.gid == abs(record.repostOwnerID) } )
                if groups.count > 0 {
                    url = groups[0].photoURL
                    name = groups[0].name
                }
            }
            
            getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
            setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: repostAvatarImageView, indexPath: indexPath, tableView: tableView)
            setImageToRow.addDependency(getCacheImage)
            queue.addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                self.repostAvatarImageView.layer.cornerRadius = 21
                self.repostAvatarImageView.clipsToBounds = true
            }
            
            repostNameLabel.text = name
            repostNameLabel.adjustsFontSizeToFitWidth = true
            repostNameLabel.minimumScaleFactor = 0.5
            
            repostDateLabel.text = record.repostDate.toStringLastTime()
            
            if record.readMore2 == 0 {
                readMoreButtonTapped2 = true
            }
            repostTextLabel.text = record.repostText //.prepareTextForPublic()
            repostTextLabel.prepareTextForPublish2(viewController)
            
            repostAvatarImageView.isHidden = false
            repostNameLabel.isHidden = false
            repostDateLabel.isHidden = false
            repostTextLabel.isHidden = false
        } else {
            repostAvatarImageView.isHidden = true
            repostNameLabel.isHidden = true
            repostDateLabel.isHidden = true
            repostTextLabel.isHidden = true
            repostReadMoreButton.isHidden = true
        }
        
        avatarImageViewFrame()
        nameLabelFrame()
        datePostLabelFrame()
        textLabelFrame(readmore: record.readMore1)
        readMoreButtonFrame()
        repostAvatarImageViewFrame()
        repostNameLabelFrame()
        repostDateLabelFrame()
        repostTextLabelFrame(readmore: record.readMore2)
        repostReadMoreButtonFrame()
        
        
        var topY: CGFloat = topInsets + avatarImageSize + verticalSpacingElements + postTextLabel.frame.height + readMoreButton.frame.height + 2 * verticalSpacingElements
        
        if record.repostOwnerID != 0 {
             topY = topY + repostAvatarImageSize + verticalSpacingElements + repostTextLabel.frame.height + repostReadMoreButton.frame.height + 1 + 2 * verticalSpacingElements
        }
        
        var photos: [Photos] = []
        let maxWidth = UIScreen.main.bounds.width - 20
        for index in 0...9 {
            if record.mediaType[index] == "photo" && record.photoID[index] != 0 {
                let photo = Photos(json: JSON.null)
                photo.width = record.photoWidth[index]
                photo.height = record.photoHeight[index]
                photo.text = record.photoText[index]
                photo.xxbigPhotoURL = record.photoURL[index]
                photo.xbigPhotoURL = record.photoURL[index]
                photo.bigPhotoURL = record.photoURL[index]
                photo.smallPhotoURL = record.photoURL[index]
                photo.pid = "\(record.photoID[index])"
                photo.uid = "\(record.photoOwnerID[index])"
                photo.ownerID = "\(record.photoOwnerID[index])"
                photo.createdTime = record.date
                photos.append(photo)
            }
        }
        
        let aView = AttachmentsView()
        aView.backgroundColor = .clear
        aView.tag = 100
        aView.delegate = self.delegate
        aView.photos = photos
        let aHeight = aView.configureAttachView(maxSize: maxWidth, getRow: false)
        aView.frame = CGRect(x: 10, y: topY, width: maxWidth, height: aHeight)
        self.addSubview(aView)
        
        topY += aHeight
        
        topY = setImageView(0, topY, record, videos, cell, indexPath, imageView1, tableView)
        topY = setImageView(1, topY, record, videos, cell, indexPath, imageView2, tableView)
        topY = setImageView(2, topY, record, videos, cell, indexPath, imageView3, tableView)
        topY = setImageView(3, topY, record, videos, cell, indexPath, imageView4, tableView)
        topY = setImageView(4, topY, record, videos, cell, indexPath, imageView5, tableView)
        topY = setImageView(5, topY, record, videos, cell, indexPath, imageView6, tableView)
        topY = setImageView(6, topY, record, videos, cell, indexPath, imageView7, tableView)
        topY = setImageView(7, topY, record, videos, cell, indexPath, imageView8, tableView)
        topY = setImageView(8, topY, record, videos, cell, indexPath, imageView9, tableView)
        topY = setImageView(9, topY, record, videos, cell, indexPath, imageView10, tableView)
        
        for index in 0...9 {
            if record.mediaType[index] == "link" {
                topY = setLinkLabel(index, topY, record, cell, indexPath, linkImage, linkLabel, tableView, viewController)
            }
        }
        
        topY = setAudioLabel(0, topY, record, cell, indexPath, musicImage1, musicTitle1, musicArtist1, tableView)
        topY = setAudioLabel(1, topY, record, cell, indexPath, musicImage2, musicTitle2, musicArtist2, tableView)
        topY = setAudioLabel(2, topY, record, cell, indexPath, musicImage3, musicTitle3, musicArtist3, tableView)
        topY = setAudioLabel(3, topY, record, cell, indexPath, musicImage4, musicTitle4, musicArtist4, tableView)
        topY = setAudioLabel(4, topY, record, cell, indexPath, musicImage5, musicTitle5, musicArtist5, tableView)
        topY = setAudioLabel(5, topY, record, cell, indexPath, musicImage6, musicTitle6, musicArtist6, tableView)
        topY = setAudioLabel(6, topY, record, cell, indexPath, musicImage7, musicTitle7, musicArtist7, tableView)
        topY = setAudioLabel(7, topY, record, cell, indexPath, musicImage8, musicTitle8, musicArtist8, tableView)
        topY = setAudioLabel(8, topY, record, cell, indexPath, musicImage9, musicTitle9, musicArtist9, tableView)
        topY = setAudioLabel(9, topY, record, cell, indexPath, musicImage10, musicTitle10, musicArtist10, tableView)
        
        for index in 0...9 {
            if record.mediaType[index] == "poll" {
                if let poll = record.poll {
                    self.poll = poll
                    topY = configurePoll(poll, topY: topY)
                }
            }
        }
        
        if record.signerID != 0 {
            let users = profiles.filter({ $0.uid == record.signerID })
            if users.count > 0 {
                signerLabel.text = "\(users[0].firstName) \(users[0].lastName)"
                signerLabel.font = signerFont
                signerLabel.textAlignment = .right
                signerLabel.contentMode = .top
                signerLabel.textColor = signerLabel.tintColor
                signerLabel.frame = CGRect(x: leftInsets, y: topY, width: self.bounds.width - 2 * leftInsets, height: signerLabelHeight)
                self.addSubview(signerLabel)
                topY += signerLabelHeight
            }
        }
        
        
        if let vc = delegate as? Newsfeed2Controller, vc.filters == "post" {
            likesButton.frame = CGRect(x: leftInsets/2, y: topY, width: likesButtonWidth, height: likesButtonHeight)
            
            setLikesButton(record: record)
            
            var titleColor = UIColor.darkGray
            var tintColor = UIColor.darkGray
            
            titleColor = vkSingleton.shared.secondaryLabelColor
            tintColor = vkSingleton.shared.secondaryLabelColor
            
            repostsButton.frame = CGRect(x: likesButton.frame.maxX, y: topY, width: repostsButtonWidth, height: likesButtonHeight)
            repostsButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)!
            repostsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
            
            repostsButton.setTitle("\(record.countReposts)", for: UIControl.State.normal)
            repostsButton.setTitle("\(record.countReposts)", for: UIControl.State.selected)
            repostsButton.setImage(UIImage(named: "repost3"), for: .normal)
            repostsButton.imageView?.tintColor = tintColor
            repostsButton.setTitleColor(titleColor, for: .normal)
            if record.userReposted == 1 {
                repostsButton.setTitleColor(vkSingleton.shared.likeColor, for: .normal)
                repostsButton.imageView?.tintColor = vkSingleton.shared.likeColor
            }
            
            viewsButton.frame = CGRect(x: bounds.size.width - likesButtonWidth - leftInsets/2, y: topY, width: likesButtonWidth, height: likesButtonHeight)
            viewsButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 14)!
            viewsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
            
            viewsButton.setTitle("\(record.countViews.getCounterToString())", for: UIControl.State.normal)
            viewsButton.setTitle("\(record.countViews.getCounterToString())", for: UIControl.State.selected)
            viewsButton.setImage(UIImage(named: "views"), for: .normal)
            viewsButton.setTitleColor(titleColor, for: .normal)
            viewsButton.imageView?.tintColor = tintColor
            
            self.addSubview(viewsButton)
            
            if record.canComment == 1 || record.countComments > 0 {
                commentsButton.frame = CGRect(x: viewsButton.frame.minX - repostsButtonWidth, y: topY, width: repostsButtonWidth, height: likesButtonHeight)
                
                commentsButton.setTitle("\(record.countComments)", for: UIControl.State.normal)
                commentsButton.setTitle("\(record.countComments)", for: UIControl.State.selected)
                
                commentsButton.setTitleColor(commentsButton.tintColor.withAlphaComponent(0.8), for: .normal)
                commentsButton.imageView?.tintColor = commentsButton.tintColor.withAlphaComponent(0.8)
                
                commentsButton.isHidden = false
            } else {
                commentsButton.isHidden = true
            }
                
            likesButton.isHidden = false
            repostsButton.isHidden = false
            viewsButton.isHidden = false
            
            return topY + likesButtonHeight
            
        } else  {
            likesButton.isHidden = true
            repostsButton.isHidden = true
            commentsButton.isHidden = true
            viewsButton.isHidden = true
        }
        
        return topY + topInsets
    }
    
    func configurePoll(_ poll: Poll, topY: CGFloat) -> CGFloat {
        
        let view = UIView()
        view.tag = 100
        var viewY: CGFloat = 5
        
        let qLabel = UILabel()
        qLabel.font = qLabelFont
        qLabel.text = "Опрос: \(poll.question)"
        qLabel.textAlignment = .center
        qLabel.backgroundColor = vkSingleton.shared.mainColor
        qLabel.textColor = UIColor.white
        qLabel.numberOfLines = 0
        
        let qLabelSize = getPollLabelSize(text: "Опрос: \(poll.question)", font: qLabelFont)
        qLabel.frame = CGRect(x: 5, y: viewY, width: bounds.width - 2 * leftInsets, height: qLabelSize.height + 5)
        view.addSubview(qLabel)
        
        if poll.anonymous == 1 {
            let anonLabel = UILabel()
            anonLabel.text = "Анонимный опрос"
            anonLabel.textAlignment = .right
            anonLabel.isEnabled = false
            anonLabel.font = UIFont(name: "Verdana", size: 10)!
            anonLabel.frame = CGRect(x: 2 * leftInsets, y: viewY + qLabelSize.height + 5, width: bounds.width - 4 * leftInsets, height: 15)
            view.addSubview(anonLabel)
        }
        viewY += qLabelSize.height + 25
        
        
        for index in 0...poll.answers.count-1 {
            let aLabel = UILabel()
            aLabel.font = aLabelFont
            aLabel.text = "\(index+1). \(poll.answers[index].text)"
            aLabel.textColor = .white
            aLabel.numberOfLines = 0
            aLabel.tag = index
            
            let aLabelSize = getPollLabelSize(text: "\(index+1). \(poll.answers[index].text)", font: aLabelFont)
            aLabel.frame = CGRect(x: 5, y: viewY, width: aLabelSize.width, height: aLabelSize.height + 5)
            view.addSubview(aLabel)
            
            viewY += aLabelSize.height
            
            let rLabel = UILabel()
            rLabel.text = ""
            rLabel.textAlignment = .right
            rLabel.textColor = UIColor.clear
            rLabel.font = UIFont(name: "Verdana-Bold", size: 10)!
            rLabel.frame = CGRect(x: 5, y: viewY + 5, width: aLabelSize.width, height: 15)
            view.addSubview(rLabel)
            rateLabels.append(rLabel)
            
            
            viewY += 25
            answerLabels.append(aLabel)
        }
        
        totalLabel.font = UIFont(name: "Verdana-Bold", size: 12)!
        totalLabel.textAlignment = .right
        totalLabel.textColor = vkSingleton.shared.mainColor
        totalLabel.isEnabled = true
        totalLabel.numberOfLines = 1
        
        totalLabel.frame = CGRect(x: 2 * leftInsets, y: viewY, width: bounds.width - 4 * leftInsets, height: 20)
        view.addSubview(totalLabel)
        viewY += 20
        
        view.frame = CGRect(x: 5, y: topY, width: bounds.width - 10, height: viewY)
        view.layer.borderColor = vkSingleton.shared.mainColor.cgColor
        view.layer.borderWidth = 1.0
        self.addSubview(view)
        
        updatePoll()
        
        return topY + viewY + verticalSpacingElements
    }
    
    func updatePoll() {
        if answerLabels.count > 0 {
            for index in 0...answerLabels.count-1 {
                if self.poll.answerID != 0 {
                    answerLabels[index].backgroundColor = vkSingleton.shared.mainColor.withAlphaComponent(0.4)
                    
                    if self.poll.answerID == self.poll.answers[index].id {
                        answerLabels[index].backgroundColor = UIColor.purple.withAlphaComponent(0.75)
                        answerLabels[index].textColor = .white
                        answerLabels[index].isEnabled = true
                    } else {
                        answerLabels[index].textColor = .white
                    }
                } else {
                    answerLabels[index].backgroundColor = vkSingleton.shared.mainColor.withAlphaComponent(0.8)
                    answerLabels[index].textColor = .white
                }
            }
        }
        
        if rateLabels.count > 0 {
            for index in 0...rateLabels.count-1 {
                rateLabels[index].text = "\(self.poll.answers[index].votes.rateAdder()) (\(self.poll.answers[index].rate) %)"
                
                if self.poll.answerID != 0 {
                    rateLabels[index].textColor = vkSingleton.shared.secondaryLabelColor
                } else {
                    rateLabels[index].textColor = UIColor.clear
                }
            }
        }
        
        totalLabel.text = "Всего проголосовало: \(self.poll.votes)"
    }
    
    func setLikesButton(record: News) {
        likesButton.setTitle("\(record.countLikes)", for: UIControl.State.normal)
        likesButton.setTitle("\(record.countLikes)", for: UIControl.State.selected)
        
        var titleColor = vkSingleton.shared.secondaryLabelColor
        var tintColor = vkSingleton.shared.secondaryLabelColor
        
        if record.userLikes == 1 {
            titleColor = vkSingleton.shared.likeColor
            tintColor = vkSingleton.shared.likeColor
        }
        
        likesButton.setTitleColor(titleColor, for: .normal)
        likesButton.tintColor = tintColor
        likesButton.setImage(UIImage(named: "filled-like2"), for: .normal)
    }
    
    func setImageView(_ index: Int, _ topY: CGFloat, _ record: News, _ videos: [Videos], _ cell: UITableViewCell, _ indexPath: IndexPath, _ imageView: UIImageView, _ tableView: UITableView) -> CGFloat {
        
        var imageHeight: CGFloat = 0.0
        var imageWidth: CGFloat = 0.0
        var topNew = topY
        
        let subviews = imageView.subviews
        for subview in subviews {
            if subview is UIImageView {
                subview.removeFromSuperview()
            }
            if subview is UILabel {
                subview.removeFromSuperview()
            }
            if subview.tag == 1000 {
                subview.removeFromSuperview()
            }
        }
        
        imageView.layer.borderWidth = 0.0
        imageView.layer.cornerRadius = 0.0
        imageView.contentMode = .scaleAspectFill
        
        imageView.frame = CGRect(x: 5.0, y: topY, width: imageWidth, height: 0.0)
        imageView.backgroundColor = vkSingleton.shared.backColor
        imageView.image = nil
        
        if record.mediaType[index] == "doc" {
            if record.photoWidth[index] != 0 && record.photoHeight[index] != 0 {
                let width = CGFloat(record.photoWidth[index])
                let height = CGFloat(record.photoHeight[index])
                
                if width > height {
                    imageWidth = UIScreen.main.bounds.width - 20.0
                    imageHeight = imageWidth * CGFloat(record.photoHeight[index]) / CGFloat(record.photoWidth[index])
                } else {
                    imageHeight = UIScreen.main.bounds.width - 20.0
                    imageWidth = imageHeight * CGFloat(record.photoWidth[index]) / CGFloat(record.photoHeight[index])
                }
            }
            
            if imageHeight > 4 {
                imageView.frame = CGRect(x: 10, y: topY + 2, width: imageWidth, height: imageHeight - 4)
                if imageWidth < UIScreen.main.bounds.width - 20 {
                    imageView.frame = CGRect(x: (UIScreen.main.bounds.width - 20 - imageWidth) / 2, y: topY + 2, width: imageWidth, height: imageHeight - 4)
                }
                
                let getCacheImage = GetCacheImage(url: record.photoURL[index], lifeTime: .avatarImage)
                let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: imageView, indexPath: indexPath, tableView: tableView)
                setImageToRow.addDependency(getCacheImage)
                queue.addOperation(getCacheImage)
                OperationQueue.main.addOperation(setImageToRow)
                OperationQueue.main.addOperation {
                    imageView.clipsToBounds = true
                }
                
                if record.photoText[index] == "gif" {
                    let loadingView = UIView()
                    loadingView.tag = 1000
                    loadingView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
                    loadingView.center = CGPoint(x: imageView.frame.width/2, y: imageView.frame.height/2)
                    loadingView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
                    loadingView.clipsToBounds = true
                    loadingView.layer.cornerRadius = 6
                    imageView.addSubview(loadingView)
                    
                    let activityIndicator = UIActivityIndicatorView()
                    activityIndicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                    activityIndicator.style = .white
                    activityIndicator.center = CGPoint(x: loadingView.frame.width/2, y: loadingView.frame.height/2)
                    loadingView.addSubview(activityIndicator)
                    activityIndicator.startAnimating()
                    
                    let gifSizeLabel = UILabel()
                    gifSizeLabel.text = "GIF: \(record.size[index].getFileSizeToString())"
                    gifSizeLabel.numberOfLines = 1
                    gifSizeLabel.font = UIFont(name: "Verdana-Bold", size: 12.0)!
                    gifSizeLabel.textAlignment = .center
                    gifSizeLabel.contentMode = .center
                    gifSizeLabel.textColor = .white
                    gifSizeLabel.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
                    gifSizeLabel.layer.cornerRadius = 4
                    gifSizeLabel.clipsToBounds = true
                    let gifSizeWidth = gifSizeLabel.getTextWidth(maxWidth: 200)
                    gifSizeLabel.frame = CGRect(x: imageWidth - 10 - gifSizeWidth, y: imageHeight - 4 - 10 - 20, width: gifSizeWidth, height: 20)
                    imageView.addSubview(gifSizeLabel)
                    
                    if record.videoURL[index] != "" && record.size[index] < 150_000_000 {
                        queue.addOperation {
                            let url = URL(string: record.videoURL[index])
                            if let data = try? Data(contentsOf: url!) {
                                let setAnimatedImageToRow = SetAnimatedImageToRow.init(data: data, imageView: imageView, cell: cell, indexPath: indexPath, tableView: tableView)
                                OperationQueue.main.addOperation(setAnimatedImageToRow)
                                OperationQueue.main.addOperation {
                                    imageView.bringSubviewToFront(gifSizeLabel)
                                    activityIndicator.stopAnimating()
                                    loadingView.removeFromSuperview()
                                }
                            }
                        }
                    }
                }
                topNew = topY + imageHeight + 4.0
            }
        }
        
        if record.mediaType[index] == "video" {
            if record.photoURL[index] != "" {
                imageWidth = UIScreen.main.bounds.width - 20.0
                imageHeight = imageWidth * 240.0 / 320.0
            }
            
            if imageHeight > 4 {
                imageView.frame = CGRect(x: 10, y: topY + 2.0, width: imageWidth, height: imageHeight - 4.0)
                
                let getCacheImage = GetCacheImage(url: record.photoURL[index], lifeTime: .avatarImage)
                let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: imageView, indexPath: indexPath, tableView: tableView)
                setImageToRow.addDependency(getCacheImage)
                queue.addOperation(getCacheImage)
                OperationQueue.main.addOperation(setImageToRow)
                OperationQueue.main.addOperation {
                    imageView.clipsToBounds = true
                    imageView.layer.borderColor = UIColor.black.cgColor
                    imageView.layer.borderWidth = 1.0
                    imageView.layer.cornerRadius = 4.0
                }
                
                let durationLabel = UILabel()
                durationLabel.text = record.size[index].getVideoDurationToString()
                durationLabel.numberOfLines = 1
                durationLabel.font = UIFont(name: "Verdana-Bold", size: 11.0)!
                durationLabel.textAlignment = .right
                let durationLabelWidth = durationLabel.getTextWidth(maxWidth: 200)
                durationLabel.frame = CGRect(x: imageWidth - durationLabelWidth + 5, y: topY + imageHeight + 1, width: durationLabelWidth, height: 15)
                self.addSubview(durationLabel)
                
                let titleLabel = UILabel()
                titleLabel.text = record.photoText[index]
                titleLabel.numberOfLines = 1
                titleLabel.textAlignment = .left
                titleLabel.font = UIFont(name: "Verdana-Bold", size: 11.0)!
                titleLabel.textColor = titleLabel.tintColor
                titleLabel.frame = CGRect(x: 15, y: topY + imageHeight + 1, width: imageWidth - 15 - durationLabelWidth, height: 15)
                self.addSubview(titleLabel)
                
                durationLabel.textColor = vkSingleton.shared.secondaryLabelColor
                
                let videoTap = UITapGestureRecognizer()
                videoTap.add {
                    self.delegate.openVideoController(ownerID: "\(record.photoOwnerID[index])", vid: "\(record.photoID[index])", accessKey: record.photoAccessKey[index], title: "Видеозапись", scrollToComment: false)
                }
                titleLabel.isUserInteractionEnabled = true
                titleLabel.addGestureRecognizer(videoTap)
                
                var count = 0
                for index2 in 0...9 { if record.mediaType[index2] == "video" { count += 1 } }
                
                if let video = videos.filter({ $0.id == record.photoID[index] && $0.ownerID == record.photoOwnerID[index] }).first, count == 1 {
                    
                    let configuration = WKWebViewConfiguration()
                    configuration.allowsInlineMediaPlayback = true
                    configuration.mediaTypesRequiringUserActionForPlayback = []
                    let frame = CGRect(x: 10, y: topY + 2.0, width: imageWidth, height: imageHeight - 4.0)
                    
                    webView = WKWebView(frame: frame, configuration: configuration)
                    webView.navigationDelegate = self
                    webView.backgroundColor = vkSingleton.shared.backColor
                    webView.layer.backgroundColor = vkSingleton.shared.backColor.cgColor
                    webView.layer.cornerRadius = 4
                    webView.clipsToBounds = true
                    webView.isOpaque = false
                    self.addSubview(webView)
                    
                    if video.platform.contains("YouTube"), let str = video.player.components(separatedBy: "?").first, let newURL = URL(string: str) {
                        webView.loadHTMLString(embedVideoHtmlYoutube(videoID: newURL.lastPathComponent, autoplay: 0, playsinline: 1, muted: true), baseURL: nil)
                    } else if let url = URL(string: "\(video.player)&enablejsapi=1&&playsinline=0&autoplay=0") {
                        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
                        webView.load(request)
                    }
                } else {
                    let videoImage = UIImageView()
                    videoImage.image = UIImage(named: "video")
                    imageView.addSubview(videoImage)
                    videoImage.frame = CGRect(x: imageWidth / 2 - 30, y: (imageHeight - 4) / 2 - 30, width: 60, height: 60)
                    
                    imageView.isUserInteractionEnabled = true
                    imageView.addGestureRecognizer(videoTap)
                    
                    self.addSubview(imageView)
                }
                
                topNew = topY + imageHeight + 24.0
            }
        }
        
        return topNew
    }
    
    func setLinkLabel(_ index: Int, _ topY: CGFloat, _ record: News, _ cell: UITableViewCell, _ indexPath: IndexPath, _ imageView: UIImageView, _ linkLabel: UILabel, _ tableView: UITableView, _ viewController: UIViewController) -> CGFloat {
        
        imageView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        linkLabel.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        
        var imageWidth: CGFloat = 0
        var imageHeight: CGFloat = 0
        
        if record.photoURL[index] != "" {
            if record.photoWidth[index] > record.photoHeight[index] {
                imageWidth = linkImageSize
                imageHeight = linkImageSize * CGFloat(240) / CGFloat(320)
                
                if imageHeight < linkImageSize * 0.75 {
                    imageHeight = linkImageSize * 0.75
                }
            } else if record.photoWidth[index] < record.photoHeight[index] {
                imageWidth = linkImageSize * CGFloat(240) / CGFloat(320)
                imageHeight = linkImageSize
            } else {
                imageWidth = linkImageSize
                imageHeight = linkImageSize
            }
            
            let getCacheImage = GetCacheImage(url: record.photoURL[index], lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    imageView.image = getCacheImage.outputImage
                }
            }
            queue.addOperation(getCacheImage)
        } else if record.linkURL[index].containsIgnoringCase(find: "itunes.apple.com") {
            imageWidth = linkImageSize * 0.7
            imageHeight = linkImageSize * 0.7
            imageView.image = UIImage(named: "itunes")
        } else {
            imageWidth = linkImageSize * 0.8
            imageHeight = linkImageSize * 0.8
            imageView.image = UIImage(named: "url")
        }
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = linkLabel.tintColor.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.clipsToBounds = true
        
        imageView.frame = CGRect(x: leftInsets, y: topY + topLinkInsets, width: imageWidth, height: imageHeight)
        
        self.addSubview(imageView)
        
        var linkText = record.linkURL[index]
        if record.linkText[index] != "" {
            linkText = "\(record.linkText[index])\n\(record.linkURL[index])"
            if record.linkText[index].length > 100 {
                linkText = "\(record.linkText[index].prefix(100))...\n\(record.linkURL[index])"
            }
        }
        
        linkLabel.text = linkText
        linkLabel.prepareTextForPublish2(viewController)
        linkLabel.font = linkFont
        linkLabel.adjustsFontSizeToFitWidth = true
        linkLabel.minimumScaleFactor = 0.5
        linkLabel.contentMode = .center
        linkLabel.textAlignment = .center
        linkLabel.sizeToFit()
        linkLabel.numberOfLines = 0
        linkLabel.clipsToBounds = true
        linkLabel.layer.borderColor = linkLabel.tintColor.cgColor
        linkLabel.layer.borderWidth = 0.5
        
        linkLabel.frame = CGRect(x: imageWidth + 2 * leftInsets, y: topY + topLinkInsets, width: self.bounds.width - imageWidth - 3 * leftInsets, height: imageHeight)
        
        self.addSubview(linkLabel)
        
        return topY + 2 * topLinkInsets + imageHeight
    }
    
    func setAudioLabel(_ index: Int, _ topY: CGFloat, _ record: News, _ cell: UITableViewCell, _ indexPath: IndexPath, _ imageView: UIImageView, _ audioLabel: UILabel, _ audioNameLabel: UILabel, _ tableView: UITableView) -> CGFloat {
        
        var topNew = topY
        
        imageView.frame = CGRect(x: leftInsets, y: topY + topLinkInsets, width: audioImageSize, height: 0.0)
        audioNameLabel.frame = CGRect (x: 2 * leftInsets + audioImageSize, y: topY + 4, width: bounds.size.width - 3 * leftInsets - audioImageSize, height: 0)
        audioLabel.frame = CGRect (x: 2 * leftInsets + audioImageSize, y: topY + 4 + audioNameLabel.frame.height, width: bounds.size.width - 3 * leftInsets - audioImageSize, height: 0)
        
        if record.mediaType[index] == "audio" {
            if record.audioTitle[index] != "" {
                imageView.frame = CGRect(x: leftInsets, y: topY + topLinkInsets, width: audioImageSize, height: audioImageSize)
                
                audioNameLabel.frame = CGRect (x: 2 * leftInsets + audioImageSize, y: topY + 4, width: bounds.size.width - 3 * leftInsets - audioImageSize, height: 16)
                audioNameLabel.text = record.audioArtist[index]
                
                audioLabel.frame = CGRect (x: 2 * leftInsets + audioImageSize, y: topY + 20, width: bounds.size.width - 3 * leftInsets - audioImageSize, height: 16)
                audioLabel.text = record.audioTitle[index]
                audioLabel.textColor = audioLabel.tintColor
                
                imageView.isHidden = false
                audioNameLabel.isHidden = false
                audioLabel.isHidden = false
                
                topNew = topY + 2 * topLinkInsets + audioImageSize
            }
        }
        
        return topNew
    }
    
    func avatarImageViewFrame() {
        let avatarImageOrigin = CGPoint(x: leftInsets, y: topInsets)
        
        avatarImageView.frame = CGRect(origin: avatarImageOrigin, size: CGSize(width: avatarImageSize, height: avatarImageSize))
    }
    
    func repostAvatarImageViewFrame() {
        let repostAvatarImageY = topInsets + avatarImageSize + verticalSpacingElements + postTextLabel.frame.height + readMoreButton.frame.height + verticalSpacingElements
        
        let repostAvatarImageOrigin = CGPoint(x: leftInsets, y: repostAvatarImageY)
        
        var height = repostAvatarImageSize
        if repostAvatarImageView.isHidden == true {
            height = 0.0
        }
        repostAvatarImageView.frame = CGRect(origin: repostAvatarImageOrigin, size: CGSize(width: repostAvatarImageSize, height: height))
    }
    
    func nameLabelFrame() {
        
        let nameLabelOrigin = CGPoint(x: 2 * leftInsets + avatarImageSize, y: topNameLabelInsets)
        
        let nameLabelWidth = bounds.size.width - nameLabelOrigin.x - leftInsets
        
        nameLabel.frame = CGRect(origin: nameLabelOrigin, size: CGSize(width: nameLabelWidth, height: nameLabelHeight))
    }
    
    
    func datePostLabelFrame() {
        
        let dateLabelOrigin = CGPoint(x: 2 * leftInsets + avatarImageSize, y: topNameLabelInsets + nameLabelHeight + 1)
        
        let dateLabelWidth = bounds.size.width - dateLabelOrigin.x - leftInsets
        
        datePostLabel.frame = CGRect(origin: dateLabelOrigin, size: CGSize(width: dateLabelWidth, height: dateLabelHeight))
    }
    
    func repostNameLabelFrame() {
        
        let repostNameLabelOrigin = CGPoint(x: 2 * leftInsets + repostAvatarImageSize, y: topInsets + avatarImageSize + verticalSpacingElements + postTextLabel.frame.height + readMoreButton.frame.height + verticalSpacingElements + 6)
        
        let repostNameLabelWidth = bounds.size.width - repostNameLabelOrigin.x - leftInsets
        
        var height = dateLabelHeight
        if repostNameLabel.isHidden == true {
            height = 0.0
        }
        
        repostNameLabel.frame = CGRect(origin: repostNameLabelOrigin, size: CGSize(width: repostNameLabelWidth, height: height))
    }
    
    func repostDateLabelFrame() {
        
        let repostDateLabelOrigin = CGPoint(x: 2 * leftInsets + repostAvatarImageSize, y: topInsets + avatarImageSize + verticalSpacingElements + postTextLabel.frame.height + readMoreButton.frame.height + verticalSpacingElements + 6 + repostNameLabel.frame.height + 1)
        
        let repostDateLabelWidth = bounds.size.width - repostDateLabelOrigin.x - leftInsets
        
        var height = dateLabelHeight
        if repostDateLabel.isHidden == true {
            height = 0.0
        }
        
        repostDateLabel.frame = CGRect(origin: repostDateLabelOrigin, size: CGSize(width: repostDateLabelWidth, height: height))
    }
    
    func getTextSize(text: String, font: UIFont, readmore: Int) -> CGSize {
        let maxWidth = bounds.width - 2 * leftInsets
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let width = Double(rect.size.width)
        var height = Double(rect.size.height)
        
        if readmore == 1 {
            if rect.size.height > readMoreLevel {
                height = Double(readMoreLevel)
                readMoreButton.isHidden = false
            } else {
                readMoreButton.isHidden = true
            }
        } else {
            readMoreButton.isHidden = true
        }
        
        if text == "" {
            height = 5.0
        }
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func getPollLabelSize(text: String, font: UIFont) -> CGSize {
        let maxWidth = UIScreen.main.bounds.width - 2 * leftInsets
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let width = Double(maxWidth)
        let height = Double(rect.size.height)
        
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func textLabelFrame(readmore: Int) {
        let textLabelSize = getTextSize(text: postTextLabel.text!, font: textFont, readmore: readmore)
        
        postTextLabel.frame = CGRect(x: leftInsets, y: topInsets + avatarImageSize + verticalSpacingElements, width: textLabelSize.width, height: textLabelSize.height)
        
        self.addSubview(postTextLabel)
    }
    
    func getRepostTextSize(text: String, font: UIFont, readmore: Int) -> CGSize {
        let maxWidth = bounds.width - 2 * leftInsets
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let width = Double(rect.size.width)
        var height = Double(rect.size.height)
        
        if readmore == 1 {
            if rect.size.height > readMoreLevel {
                height = Double(readMoreLevel)
                repostReadMoreButton.isHidden = false
            } else {
                repostReadMoreButton.isHidden = true
            }
        } else {
            repostReadMoreButton.isHidden = true
        }
        
        if text == "" {
            height = 5.0
        }
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func repostTextLabelFrame(readmore: Int) {
        let repostTextLabelSize = getRepostTextSize(text: repostTextLabel.text!, font: textFont, readmore: readmore)
        
        repostTextLabel.frame = CGRect(x: leftInsets, y: topInsets + avatarImageSize + verticalSpacingElements + postTextLabel.frame.height + readMoreButton.frame.height + verticalSpacingElements + repostAvatarImageSize + verticalSpacingElements, width: repostTextLabelSize.width, height: repostTextLabelSize.height)
        
        self.addSubview(repostTextLabel)
    }
    
    func readMoreButtonFrame() {
        
        let readMoreButtonOrigin = CGPoint(x: leftInsets, y: topInsets + avatarImageSize + verticalSpacingElements + postTextLabel.frame.height + 1)
        
        let readMoreButtonWidth = bounds.size.width - 2 * leftInsets
        var readMoreButtonHeight: CGFloat = 20.0
        if readMoreButton.isHidden == true {
            readMoreButtonHeight = 0
        }
        
        readMoreButton.frame = CGRect(origin: readMoreButtonOrigin, size: CGSize(width: readMoreButtonWidth, height: readMoreButtonHeight))
    }
    
    func repostReadMoreButtonFrame() {
        
        let repostReadMoreButtonOrigin = CGPoint(x: leftInsets, y: topInsets + avatarImageSize + verticalSpacingElements + postTextLabel.frame.height + readMoreButton.frame.height + verticalSpacingElements + repostAvatarImageSize + verticalSpacingElements + repostTextLabel.frame.height)
        
        let repostReadMoreButtonWidth = bounds.size.width - 2 * leftInsets
        var repostReadMoreButtonHeight: CGFloat = 20.0
        if repostReadMoreButton.isHidden == true {
            repostReadMoreButtonHeight = 0
        }
        
        repostReadMoreButton.frame = CGRect(origin: repostReadMoreButtonOrigin, size: CGSize(width: repostReadMoreButtonWidth, height: repostReadMoreButtonHeight))
    }
    
    func getRowHeight(record: News) -> CGFloat {
        
        var height: CGFloat = 0.0
        let text = record.text.replacingOccurrences(of: "<br>", with: "\n", options: .regularExpression, range: nil)
        var textHeight = getTextSize(text: text, font: textFont, readmore: record.readMore1).height
        
        if text == "" {
            textHeight = 5.0
        } else {
            if readMoreButton.isHidden == false && record.readMore1 != 0 {
                textHeight = textHeight + 21
            }
        }
        
        height = topInsets + avatarImageSize + verticalSpacingElements + textHeight + 2 * verticalSpacingElements
        if record.repostOwnerID != 0 {
            height = height + verticalSpacingElements + repostAvatarImageSize + 2 * verticalSpacingElements
            
            let text2 = record.repostText.replacingOccurrences(of: "<br>", with: "\n", options: .regularExpression, range: nil)
            var textHeight2 = getRepostTextSize(text: text2, font: textFont, readmore: record.readMore2).height
            
            if text2 == "" {
                textHeight2 = 5.0
            } else {
                if repostReadMoreButton.isHidden == false && record.readMore2 != 0 {
                    textHeight2 = textHeight2 + 21
                }
            }
            
            height = height + verticalSpacingElements + textHeight2 + verticalSpacingElements
        }
        
        var photos: [Photos] = []
        let maxWidth = UIScreen.main.bounds.width - 20
        for index in 0...9 {
            if record.mediaType[index] == "photo" && record.photoID[index] != 0 {
                let photo = Photos(json: JSON.null)
                photo.width = record.photoWidth[index]
                photo.height = record.photoHeight[index]
                photo.text = record.photoText[index]
                photo.xxbigPhotoURL = record.photoURL[index]
                photo.xbigPhotoURL = record.photoURL[index]
                photo.bigPhotoURL = record.photoURL[index]
                photo.smallPhotoURL = record.photoURL[index]
                photo.pid = "\(record.photoID[index])"
                photo.uid = "\(record.photoOwnerID[index])"
                photo.ownerID = "\(record.photoOwnerID[index])"
                photo.createdTime = record.date
                photos.append(photo)
            }
        }
        
        let aView = AttachmentsView()
        aView.photos = photos
        let aHeight = aView.configureAttachView(maxSize: maxWidth, getRow: false)
        height += aHeight
        
        var imageWidth = [CGFloat] (repeating: 0, count: 10)
        var imageHeight = [CGFloat] (repeating: 0, count: 10)
        for index in 0...9 {
            if record.mediaType[index] == "doc" {
                if record.photoWidth[index] != 0 && record.photoHeight[index] != 0 {
                    if record.photoWidth[index] > record.photoHeight[index] {
                        imageWidth[index] = UIScreen.main.bounds.width - 20.0
                        imageHeight[index] = imageWidth[index] * CGFloat(record.photoHeight[index]) / CGFloat(record.photoWidth[index])
                    } else {
                        imageHeight[index] = UIScreen.main.bounds.width - 20.0
                        imageWidth[index] = imageHeight[index] * CGFloat(record.photoWidth[index]) / CGFloat(record.photoHeight[index])
                    }
                    
                    if imageHeight[index] > 0 {
                        height = height + imageHeight[index] + 4.0
                    }
                }
            }
            
            if record.mediaType[index] == "video" {
                if record.photoURL[index] != "" {
                    imageWidth[index] = UIScreen.main.bounds.width - 20
                    imageHeight[index] = imageWidth[index] * 240.0 / 320.0
                    
                    if imageHeight[index] > 0 {
                        height = height + imageHeight[index] + 24.0
                    }
                }
            }
        }
        
        for index in 0...9 {
            if record.mediaType[index] == "link" {
                var imageHeight = linkImageSize
                if record.photoURL[index] != "" {
                    if record.photoWidth[index] > record.photoHeight[index] {
                        imageHeight = linkImageSize * CGFloat(240) / CGFloat(320)
                    }
                } else {
                    imageHeight = linkImageSize * 0.8
                }
                
                height += 2 * topLinkInsets + imageHeight
            }
        }
        
        for index in 0...9 {
            if record.mediaType[index] == "audio" {
                if record.audioTitle[index] != "" {
                    height = height + 2 * topLinkInsets + audioImageSize
                }
            }
        }
        
        for index in 0...9 {
            if record.mediaType[index] == "poll" {
                if let poll = record.poll {
                    let qLabelSize = getPollLabelSize(text: "Опрос: \(poll.question)", font: qLabelFont)
                    var viewY: CGFloat = 5 + qLabelSize.height + 25
                    
                    for ind in 0...poll.answers.count-1 {
                        let aLabelSize = getPollLabelSize(text: "\(ind+1). \(poll.answers[ind].text)", font: aLabelFont)
                        viewY += aLabelSize.height + 25
                    }
                    
                    viewY += 20
                    height += viewY + verticalSpacingElements
                }
            }
        }
        
        if record.signerID != 0 {
            height += signerLabelHeight
        }
        
        if let vc = delegate as? Newsfeed2Controller, vc.filters == "post" {
            return height + likesButtonHeight
        }
        
        return height + topInsets
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            position = touch.location(in: self)
        }
    }
    
    func getActionOnClickPosition(touch: CGPoint, record: News) -> String {
        
        var res = "show_record"
        
        if touch.y >= avatarImageView.frame.minY && touch.y < avatarImageView.frame.maxX {
            res = "show_owner"
        }
        
        if record.repostOwnerID != 0 {
            if touch.y >= repostAvatarImageView.frame.minY && touch.y < repostAvatarImageView.frame.maxY {
                res = "show_repost_owner"
            }
            
            if touch.y >= repostTextLabel.frame.minY && touch.y < repostTextLabel.frame.maxY {
                res = "show_repost_record"
            }
        }
        
        for index in 0...9 {
            if record.mediaType[index] == "photo" {
                if index == 0 && touch.y >= imageView1.frame.minY && touch.y < imageView1.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
                if index == 1 && touch.y >= imageView2.frame.minY && touch.y < imageView2.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
                if index == 2 && touch.y >= imageView3.frame.minY && touch.y < imageView3.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
                if index == 3 && touch.y >= imageView4.frame.minY && touch.y < imageView4.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
                if index == 4 && touch.y >= imageView5.frame.minY && touch.y < imageView5.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
                if index == 5 && touch.y >= imageView6.frame.minY && touch.y < imageView6.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
                if index == 6 && touch.y >= imageView7.frame.minY && touch.y < imageView7.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
                if index == 7 && touch.y >= imageView8.frame.minY && touch.y < imageView8.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
                if index == 8 && touch.y >= imageView9.frame.minY && touch.y < imageView9.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
                if index == 9 && touch.y >= imageView10.frame.minY && touch.y < imageView10.frame.maxY {
                    res = "show_photo_\(index)"
                    
                }
            }
            
            if record.mediaType[index] == "video" {
                if record.photoURL[index] != "" {
                    if index == 0 && touch.y >= imageView1.frame.minY && touch.y < imageView1.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                    if index == 1 && touch.y >= imageView2.frame.minY && touch.y < imageView2.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                    if index == 2 && touch.y >= imageView3.frame.minY && touch.y < imageView3.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                    if index == 3 && touch.y >= imageView4.frame.minY && touch.y < imageView4.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                    if index == 4 && touch.y >= imageView5.frame.minY && touch.y < imageView5.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                    if index == 5 && touch.y >= imageView6.frame.minY && touch.y < imageView6.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                    if index == 6 && touch.y >= imageView7.frame.minY && touch.y < imageView7.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                    if index == 7 && touch.y >= imageView8.frame.minY && touch.y < imageView8.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                    if index == 8 && touch.y >= imageView9.frame.minY && touch.y < imageView9.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                    if index == 9 && touch.y >= imageView10.frame.minY && touch.y < imageView10.frame.maxY {
                        res = "show_video_\(index)"
                        
                    }
                }
            }
        
            if record.mediaType[index] == "audio" {
                if record.audioTitle[index] != "" {
                    if index == 0 && touch.y >= musicArtist1.frame.minY && touch.y < musicTitle1.frame.maxY {
                        res = "show_music_\(index)"
                    }
                    if index == 1 && touch.y >= musicArtist2.frame.minY && touch.y < musicTitle2.frame.maxY {
                        res = "show_music_\(index)"
                    }
                    if index == 2 && touch.y >= musicArtist3.frame.minY && touch.y < musicTitle3.frame.maxY {
                        res = "show_music_\(index)"
                    }
                    if index == 3 && touch.y >= musicArtist4.frame.minY && touch.y < musicTitle4.frame.maxY {
                        res = "show_music_\(index)"
                    }
                    if index == 4 && touch.y >= musicArtist5.frame.minY && touch.y < musicTitle5.frame.maxY {
                        res = "show_music_\(index)"
                    }
                    if index == 5 && touch.y >= musicArtist6.frame.minY && touch.y < musicTitle6.frame.maxY {
                        res = "show_music_\(index)"
                    }
                    if index == 6 && touch.y >= musicArtist7.frame.minY && touch.y < musicTitle7.frame.maxY {
                        res = "show_music_\(index)"
                    }
                    if index == 7 && touch.y >= musicArtist8.frame.minY && touch.y < musicTitle8.frame.maxY {
                        res = "show_music_\(index)"
                    }
                    if index == 8 && touch.y >= musicArtist9.frame.minY && touch.y < musicTitle9.frame.maxY {
                        res = "show_music_\(index)"
                    }
                    if index == 9 && touch.y >= musicArtist10.frame.minY && touch.y < musicTitle10.frame.maxY {
                        res = "show_music_\(index)"
                    }
                }
            }
        }
        
        if record.signerID != 0 {
            if touch.y >= signerLabel.frame.minY && touch.y < signerLabel.frame.maxY {
                res = "show_signer_profile"
            }
        }
        
        return res
    }
}

extension Newsfeed2Cell: WKNavigationDelegate {
    
}
