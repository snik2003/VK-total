//
//  WallRecordCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 11.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import FLAnimatedImage

class WallRecordCell: UITableViewCell {

    @IBOutlet weak var repostsButton: UIButton! {
        didSet { repostsButton.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var commentsButton: UIButton! {
        didSet { commentsButton.translatesAutoresizingMaskIntoConstraints = false } }
    @IBOutlet weak var likesButton: UIButton! {
        didSet { likesButton.translatesAutoresizingMaskIntoConstraints = false } }
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
    
    let postTextLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    let repostTextLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    
    let linkLabel10 = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    let linkLabel9 = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    let linkLabel8 = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    let linkLabel7 = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    let linkLabel6 = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    let linkLabel5 = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    let linkLabel4 = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    let linkLabel3 = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    let linkLabel2 = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
    var linkLabel1 = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
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
    
    var position: CGPoint = CGPoint.zero
    
    var readMoreButtonTapped = false
    var readMoreButtonTapped2 = false
    
    let avatarImageSize: CGFloat = 60.0
    let repostAvatarImageSize: CGFloat = 44.0
    
    let textFont: UIFont = UIFont(name: "Verdana", size: 15.0)!
    let linkFont: UIFont = UIFont(name: "Verdana", size: 12.0)!
    
    let audioImageSize: CGFloat = 30.0
    let linkImageSize: CGFloat = 30.0
    let topLinkInsets: CGFloat = 5.0
    
    let leftInsets: CGFloat = 10.0
    let topInsets: CGFloat = 10.0
    
    let topNameLabelInsets: CGFloat = 20.0
    let nameLabelHeight: CGFloat = 21.0
    
    let dateLabelHeight: CGFloat = 18.0
    
    let verticalSpacingElements: CGFloat = 5.0
    
    let readMoreLevel: CGFloat = 190.0
    
    let likesButtonWight: CGFloat = 80.0
    let likesButtonHeight: CGFloat = 40.0
    
    let signerLabelHeight: CGFloat = 22.0
    let signerFont = UIFont.boldSystemFont(ofSize: 15) //UIFont(name: "Verdana-Bold", size: 13)!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImageViewFrame()
        nameLabelFrame()
        datePostLabelFrame()
        readMoreButtonFrame()
    }
    
    func configureCell(record: Wall, profiles: [WallProfiles], groups: [WallGroups], indexPath: IndexPath, tableView: UITableView, cell: UITableViewCell, viewController: UIViewController) {
        
        var url = ""
        var name = ""
        
        signerLabel.text = ""
        postTextLabel.text = ""
        repostTextLabel.text = ""
        
        if record.fromID > 0 {
            let users = profiles.filter( { $0.uid == record.fromID } )
            if users.count > 0 {
                url = users[0].photoURL
                name = "\(users[0].firstName) \(users[0].lastName)"
                if record.isPinned == 1 {
                    name = "📌 \(users[0].firstName) \(users[0].lastName)"
                }
                if record.postType == "postpone" {
                    name = "⏱ \(users[0].firstName) \(users[0].lastName)"
                }
            }
        } else {
            let groups = groups.filter( { $0.gid == abs(record.fromID) } )
            if groups.count > 0 {
                url = groups[0].photoURL
                name = groups[0].name
                if record.isPinned == 1 {
                    name = "📌 \(groups[0].name)"
                }
                if record.postType == "postpone" {
                    name = "⏱ \(groups[0].name)"
                }
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
        
        nameLabel.text = name
        datePostLabel.text = record.date.toStringLastTime()
        
        readMoreButton.isHidden = true
        repostReadMoreButton.isHidden = true
        
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
            repostDateLabel.text = record.repostDate.toStringLastTime()
            
            if record.readMore2 == 0 {
                readMoreButtonTapped2 = true
            }
            repostTextLabel.text = record.repostText //.prepareTextForPublic()
            //repostTextLabel.prepareTextForPublish2(viewController)
            
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
        
        topY = setImageView(0, topY, record, cell, indexPath, imageView1, tableView)
        topY = setImageView(1, topY, record, cell, indexPath, imageView2, tableView)
        topY = setImageView(2, topY, record, cell, indexPath, imageView3, tableView)
        topY = setImageView(3, topY, record, cell, indexPath, imageView4, tableView)
        topY = setImageView(4, topY, record, cell, indexPath, imageView5, tableView)
        topY = setImageView(5, topY, record, cell, indexPath, imageView6, tableView)
        topY = setImageView(6, topY, record, cell, indexPath, imageView7, tableView)
        topY = setImageView(7, topY, record, cell, indexPath, imageView8, tableView)
        topY = setImageView(8, topY, record, cell, indexPath, imageView9, tableView)
        topY = setImageView(9, topY, record, cell, indexPath, imageView10, tableView)
        
        topY = setLinkLabel(0, topY, record, cell, indexPath, linkImage1, linkLabel1, linkNameLabel1, tableView, viewController)
        topY = setLinkLabel(1, topY, record, cell, indexPath, linkImage2, linkLabel2, linkNameLabel2, tableView, viewController)
        topY = setLinkLabel(2, topY, record, cell, indexPath, linkImage3, linkLabel3, linkNameLabel3, tableView, viewController)
        topY = setLinkLabel(3, topY, record, cell, indexPath, linkImage4, linkLabel4, linkNameLabel4, tableView, viewController)
        topY = setLinkLabel(4, topY, record, cell, indexPath, linkImage5, linkLabel5, linkNameLabel5, tableView, viewController)
        topY = setLinkLabel(5, topY, record, cell, indexPath, linkImage6, linkLabel6, linkNameLabel6, tableView, viewController)
        topY = setLinkLabel(6, topY, record, cell, indexPath, linkImage7, linkLabel7, linkNameLabel7, tableView, viewController)
        topY = setLinkLabel(7, topY, record, cell, indexPath, linkImage8, linkLabel8, linkNameLabel8, tableView, viewController)
        topY = setLinkLabel(8, topY, record, cell, indexPath, linkImage9, linkLabel9, linkNameLabel9, tableView, viewController)
        topY = setLinkLabel(9, topY, record, cell, indexPath, linkImage10, linkLabel10, linkNameLabel10, tableView, viewController)
        
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
        
        likesButton.frame = CGRect(x: leftInsets, y: topY, width: likesButtonWight, height: likesButtonHeight)
        
        setLikesButton(record: record)
        
        repostsButton.frame = CGRect(x: bounds.size.width - likesButtonWight - leftInsets, y: topY, width: likesButtonWight, height: likesButtonHeight)
        
        repostsButton.setTitle("\(record.countReposts)", for: UIControl.State.normal)
        repostsButton.setTitle("\(record.countReposts)", for: UIControl.State.selected)
        
        commentsButton.frame = CGRect(x: (bounds.size.width - likesButtonWight) / 2.0, y: topY, width: likesButtonWight, height: likesButtonHeight)
        
        commentsButton.setTitle("\(record.countComments)", for: UIControl.State.normal)
        commentsButton.setTitle("\(record.countComments)", for: UIControl.State.selected)
        
    }
    
    func setLikesButton(record: Wall) {
        likesButton.setTitle("\(record.countLikes)", for: UIControl.State.normal)
        likesButton.setTitle("\(record.countLikes)", for: UIControl.State.selected)
        
        if record.userLikes == 1 {
            likesButton.setTitleColor(UIColor.purple, for: .normal)
            likesButton.setImage(UIImage(named: "filled-like2")?.tint(tintColor:  UIColor.purple), for: .normal)
        } else {
            likesButton.setTitleColor(UIColor.darkGray, for: .normal)
            likesButton.setImage(UIImage(named: "filled-like2")?.tint(tintColor:  UIColor.darkGray), for: .normal)
        }
    }
    
    func setImageView(_ index: Int, _ topY: CGFloat, _ record: Wall, _ cell: UITableViewCell, _ indexPath: IndexPath, _ imageView: UIImageView, _ tableView: UITableView) -> CGFloat {
        
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
        }
        imageView.layer.borderWidth = 0.0
        imageView.layer.cornerRadius = 0.0
        imageView.contentMode = .scaleAspectFill
        
        imageView.frame = CGRect(x: 5.0, y: topY, width: imageWidth, height: 0.0)
        imageView.image = nil
        
        if record.mediaType[index] == "photo" || record.mediaType[index] == "doc" {
            if record.photoWidth[index] != 0 {
                imageWidth = UIScreen.main.bounds.width - 10.0
                imageHeight = imageWidth * CGFloat(record.photoHeight[index]) / CGFloat(record.photoWidth[index])
            }
            
            if imageHeight > 4 {
                imageView.frame = CGRect(x: 5.0, y: topY + 2.0, width: imageWidth, height: imageHeight - 4.0)
                
                let getCacheImage = GetCacheImage(url: record.photoURL[index], lifeTime: .avatarImage)
                let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: imageView, indexPath: indexPath, tableView: tableView)
                setImageToRow.addDependency(getCacheImage)
                queue.addOperation(getCacheImage)
                OperationQueue.main.addOperation(setImageToRow)
                OperationQueue.main.addOperation {
                    imageView.clipsToBounds = true
                }
                
                if record.mediaType[index] == "doc" && record.photoText[index] == "gif" {
                    let gifImage = UIImageView()
                    gifImage.image = UIImage(named: "gif")
                    gifImage.backgroundColor = UIColor.lightText.withAlphaComponent(0.5)
                    gifImage.layer.cornerRadius = 10
                    gifImage.clipsToBounds = true
                    gifImage.frame = CGRect(x: imageWidth / 2 - 50, y: (imageHeight - 4) / 2 - 50, width: 100, height: 100)
                    imageView.addSubview(gifImage)
                    
                    let gifSizeLabel = UILabel()
                    gifSizeLabel.text = "Размер: \(record.size[index].getFileSizeToString())"
                    gifSizeLabel.numberOfLines = 1
                    gifSizeLabel.font = UIFont(name: "Verdana-Bold", size: 12.0)!
                    gifSizeLabel.textAlignment = .center
                    gifSizeLabel.contentMode = .center
                    gifSizeLabel.textColor = UIColor.black
                    gifSizeLabel.backgroundColor = UIColor.lightText.withAlphaComponent(0.5)
                    gifSizeLabel.layer.cornerRadius = 10
                    gifSizeLabel.clipsToBounds = true
                    gifSizeLabel.frame = CGRect(x: imageWidth - 10 - 120, y: imageHeight - 4 - 10 - 20, width: 120, height: 20)
                    imageView.addSubview(gifSizeLabel)
                    
                    if record.videoURL[index] != "" && record.size[index] < 50_000_000 {
                        queue.addOperation {
                            let url = URL(string: record.videoURL[index])
                            if let data = try? Data(contentsOf: url!) {
                                let setAnimatedImageToRow = SetAnimatedImageToRow.init(data: data, imageView: imageView, cell: cell, indexPath: indexPath, tableView: tableView)
                                OperationQueue.main.addOperation(setAnimatedImageToRow)
                                OperationQueue.main.addOperation {
                                    imageView.bringSubviewToFront(gifSizeLabel)
                                    gifImage.removeFromSuperview()
                                }
                            }
                        }
                    }
                }
                topNew = topY + imageHeight + 4.0
            }
        }
        
        if record.mediaType[index] == "link" {
            if record.photoURL[index] != "" {
                if CGFloat(record.photoWidth[index]) < UIScreen.main.bounds.width {
                    imageWidth = UIScreen.main.bounds.width - 10.0
                    imageHeight = CGFloat(record.photoHeight[index])
                    imageView.contentMode = .scaleAspectFit
                } else {
                    imageWidth = UIScreen.main.bounds.width - 10.0
                    imageHeight = imageWidth * CGFloat(record.photoHeight[index]) / CGFloat(record.photoWidth[index])
                }
                
                if imageHeight > 4 {
                    imageView.frame = CGRect(x: 5.0, y: topY + 2.0, width: imageWidth, height: imageHeight - 4.0)
                    
                    let getCacheImage = GetCacheImage(url: record.photoURL[index], lifeTime: .avatarImage)
                    let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: imageView, indexPath: indexPath, tableView: tableView)
                    setImageToRow.addDependency(getCacheImage)
                    queue.addOperation(getCacheImage)
                    OperationQueue.main.addOperation(setImageToRow)
                    OperationQueue.main.addOperation {
                        imageView.clipsToBounds = true
                    }
                    topNew = topY + imageHeight + 4.0
                }
            }
        }
        
        if record.mediaType[index] == "video" {
            if record.photoURL[index] != "" {
                imageWidth = UIScreen.main.bounds.width - 10.0
                imageHeight = imageWidth * 240.0 / 320.0
            }
            
            if imageHeight > 4 {
                imageView.frame = CGRect(x: 5.0, y: topY + 2.0, width: imageWidth, height: imageHeight - 4.0)
                
                let getCacheImage = GetCacheImage(url: record.photoURL[index], lifeTime: .avatarImage)
                let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: imageView, indexPath: indexPath, tableView: tableView)
                setImageToRow.addDependency(getCacheImage)
                queue.addOperation(getCacheImage)
                OperationQueue.main.addOperation(setImageToRow)
                OperationQueue.main.addOperation {
                    imageView.clipsToBounds = true
                    imageView.layer.borderColor = UIColor.black.cgColor
                    imageView.layer.borderWidth = 1.0
                    imageView.layer.cornerRadius = 10.0
                }
                
                let videoImage = UIImageView()
                videoImage.image = UIImage(named: "video")
                imageView.addSubview(videoImage)
                videoImage.frame = CGRect(x: imageWidth / 2 - 30, y: (imageHeight - 4) / 2 - 30, width: 60, height: 60)
                
                let durationLabel = UILabel()
                durationLabel.text = record.size[index].getVideoDurationToString()
                durationLabel.numberOfLines = 1
                durationLabel.font = UIFont(name: "Verdana-Bold", size: 12.0)!
                durationLabel.textAlignment = .center
                durationLabel.contentMode = .center
                if #available(iOS 13.0, *) {
                    durationLabel.textColor = .label
                    durationLabel.backgroundColor = .secondarySystemBackground
                } else {
                    durationLabel.textColor = UIColor.black
                    durationLabel.backgroundColor = UIColor.lightText.withAlphaComponent(0.5)
                }
                durationLabel.layer.cornerRadius = 10
                durationLabel.clipsToBounds = true
                if let length = durationLabel.text?.length, length > 5 {
                    durationLabel.frame = CGRect(x: imageWidth - 10 - 90, y: imageHeight - 4 - 10 - 20, width: 90, height: 20)
                } else {
                    durationLabel.frame = CGRect(x: imageWidth - 10 - 60, y: imageHeight - 4 - 10 - 20, width: 60, height: 20)
                }
                imageView.addSubview(durationLabel)
                
                topNew = topY + imageHeight + 4.0
            }
        }
        
        return topNew
    }
    
    func setLinkLabel(_ index: Int, _ topY: CGFloat, _ record: Wall, _ cell: UITableViewCell, _ indexPath: IndexPath, _ imageView: UIImageView, _ linkLabel: UILabel, _ linkNameLabel: UILabel, _ tableView: UITableView, _ viewController: UIViewController) -> CGFloat {
        
        var topNew = topY
        
        imageView.frame = CGRect(x: leftInsets, y: topY + topLinkInsets, width: linkImageSize, height: 0.0)
        linkNameLabel.frame = CGRect (x: 2 * leftInsets + linkImageSize, y: topY + 4, width: bounds.size.width - 3 * leftInsets - linkImageSize, height: 0)
        linkLabel.frame = CGRect (x: 2 * leftInsets + linkImageSize, y: topY + 4 + linkNameLabel.frame.height, width: bounds.size.width - 3 * leftInsets - linkImageSize, height: 0)
        
        linkLabel.contentMode = .top
        
        linkNameLabel.font = UIFont(name: "Verdana-Bold", size: 13)!
        linkNameLabel.font = UIFont(name: "Verdana-Bold", size: 13)!
        linkNameLabel.adjustsFontSizeToFitWidth = true
        linkNameLabel.minimumScaleFactor = 0.5
        linkNameLabel.numberOfLines = 2
        
        if record.mediaType[index] == "link" {
            if record.linkURL[index] != "" {
                imageView.frame = CGRect(x: leftInsets, y: topY + topLinkInsets, width: linkImageSize, height: linkImageSize)
                
                
                if record.linkText[index] != "" {
                    linkNameLabel.frame = CGRect (x: 2 * leftInsets + linkImageSize, y: topY, width: bounds.size.width - 3 * leftInsets - linkImageSize, height: 20)
                    
                    self.addSubview(linkNameLabel)
                    
                    linkLabel.frame = CGRect (x: 2 * leftInsets + linkImageSize, y: topY + 18, width: 100, height: 16)
                } else {
                    linkNameLabel.frame = CGRect (x: 2 * leftInsets + linkImageSize, y: topY + 1, width: bounds.size.width - 3 * leftInsets - linkImageSize, height: 0)
                    
                    linkLabel.frame = CGRect (x: 2 * leftInsets + linkImageSize, y: topY + 10, width: bounds.size.width - 3 * leftInsets - linkImageSize, height: 16)
                }
                
                
                linkLabel.text = record.linkURL[index]
                //linkLabel.prepareTextForPublish2(viewController)
                linkLabel.font = linkFont
                linkLabel.contentMode = .top
                linkLabel.sizeToFit()
                linkLabel.numberOfLines = 1
                
                linkNameLabel.text = record.linkText[index]
                
                imageView.isHidden = false
                linkNameLabel.isHidden = false
                linkLabel.isHidden = false
                
                self.addSubview(linkLabel)
                
                topNew = topY + 2 * topLinkInsets + linkImageSize
            }
        }
        
        return topNew
    }
    
    func setAudioLabel(_ index: Int, _ topY: CGFloat, _ record: Wall, _ cell: UITableViewCell, _ indexPath: IndexPath, _ imageView: UIImageView, _ audioLabel: UILabel, _ audioNameLabel: UILabel, _ tableView: UITableView) -> CGFloat {
        
        var topNew = topY
        
        imageView.frame = CGRect(x: leftInsets, y: topY + topLinkInsets, width: linkImageSize, height: 0.0)
        audioNameLabel.frame = CGRect (x: 2 * leftInsets + linkImageSize, y: topY + 4, width: bounds.size.width - 3 * leftInsets - linkImageSize, height: 0)
        audioLabel.frame = CGRect (x: 2 * leftInsets + linkImageSize, y: topY + 4 + audioNameLabel.frame.height, width: bounds.size.width - 3 * leftInsets - linkImageSize, height: 0)
        
        if record.mediaType[index] == "audio" {
            if record.audioTitle[index] != "" {
                imageView.frame = CGRect(x: leftInsets, y: topY + topLinkInsets, width: linkImageSize, height: linkImageSize)
                
                audioNameLabel.frame = CGRect (x: 2 * leftInsets + linkImageSize, y: topY + 4, width: bounds.size.width - 3 * leftInsets - linkImageSize, height: 16)
                audioNameLabel.text = record.audioArtist[index]
                
                audioLabel.frame = CGRect (x: 2 * leftInsets + linkImageSize, y: topY + 20, width: bounds.size.width - 3 * leftInsets - linkImageSize, height: 16)
                audioLabel.text = record.audioTitle[index]
                audioLabel.textColor = audioLabel.tintColor
                
                imageView.isHidden = false
                audioNameLabel.isHidden = false
                audioLabel.isHidden = false
                
                topNew = topY + 2 * topLinkInsets + linkImageSize
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
    
    func getRowHeight(record: Wall) -> CGFloat {
        
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
        
        height = topInsets + avatarImageSize + verticalSpacingElements + textHeight
        if record.repostOwnerID != 0 {
            height = height + verticalSpacingElements + repostAvatarImageSize
            
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
        
        
        var imageWidth = [CGFloat] (repeating: 0, count: 10)
        var imageHeight = [CGFloat] (repeating: 0, count: 10)
        for index in 0...9 {
            if record.mediaType[index] == "photo" || record.mediaType[index] == "doc" {
                if record.photoWidth[index] != 0 {
                    imageWidth[index] = UIScreen.main.bounds.width - 10
                    imageHeight[index] = imageWidth[index] * CGFloat(record.photoHeight[index]) / CGFloat(record.photoWidth[index])
                    
                    if imageHeight[index] > 0 {
                        height = height + imageHeight[index] + 4.0
                    }
                }
            }
            
            if record.mediaType[index] == "link" {
                if record.photoURL[index] != "" {
                    if CGFloat(record.photoWidth[index]) < UIScreen.main.bounds.width {
                        imageWidth[index] = UIScreen.main.bounds.width - 10.0
                        imageHeight[index] = CGFloat(record.photoHeight[index])
                    } else {
                        imageWidth[index] = UIScreen.main.bounds.width - 10
                        imageHeight[index] = imageWidth[index] * CGFloat(record.photoHeight[index]) / CGFloat(record.photoWidth[index])
                    }
                    
                    if imageHeight[index] > 0 {
                        height = height + imageHeight[index] + 4.0
                    }
                }
            }
            
            if record.mediaType[index] == "video" {
                if record.photoURL[index] != "" {
                    imageWidth[index] = UIScreen.main.bounds.width - 10
                    imageHeight[index] = imageWidth[index] * 240.0 / 320.0
                    
                    if imageHeight[index] > 0 {
                        height = height + imageHeight[index] + 4.0
                    }
                }
            }
        }
        
        for index in 0...9 {
            if record.mediaType[index] == "link" {
                if record.linkURL[index] != "" {
                    height = height + 2 * topLinkInsets + linkImageSize
                }
            }
        }
        
        for index in 0...9 {
            if record.mediaType[index] == "audio" {
                if record.audioTitle[index] != "" {
                    height = height + 2 * topLinkInsets + linkImageSize
                }
            }
        }
        
        if record.signerID != 0 {
            height += signerLabelHeight
        }
        
        height = height + likesButtonHeight + topInsets
        
        return height
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            position = touch.location(in: self)
        }
    }
    
    func getActionOnClickPosition(touch: CGPoint, record: Wall) -> String {
        
        var res = "show_record"
        
        // определяем позицию для перехода на профиль владельца записи
        let avatarPosition = topInsets + avatarImageSize + verticalSpacingElements
        if touch.y > 0 && touch.y < avatarPosition {
            res = "show_owner"
        }
        
        // определяем позицию для перехода на профиль владельца репоста записи
        let text = record.text.replacingOccurrences(of: "<br>", with: "\n", options: .regularExpression, range: nil)
        var textHeight = getTextSize(text: text, font: textFont, readmore: record.readMore1).height
        
        if text == "" {
            textHeight = 5.0
        } else {
            if readMoreButton.isHidden == false && record.readMore1 != 0 {
                textHeight = textHeight + 21
            }
        }
        
        var position1 = avatarPosition + textHeight
        var position2 = avatarPosition + textHeight
        if record.repostOwnerID != 0 {
            position2 = position1 + verticalSpacingElements + repostAvatarImageSize + verticalSpacingElements
            
            if touch.y > position1 && touch.y < position2 {
                res = "show_repost_owner"
            }
            
            let text2 = record.repostText.replacingOccurrences(of: "<br>", with: "\n", options: .regularExpression, range: nil)
            var textHeight2 = getRepostTextSize(text: text2, font: textFont, readmore: record.readMore2).height
            
            if text2 == "" {
                textHeight2 = 5.0
            } else {
                if repostReadMoreButton.isHidden == false && record.readMore2 != 0 {
                    textHeight2 = textHeight2 + 21
                }
            }
            
            if touch.y >= position2 && touch.y < position2 + textHeight2 {
                res = "show_repost_record"
            }
            position2 += textHeight2
        }
        
        var imageWidth = [CGFloat] (repeating: 0, count: 10)
        var imageHeight = [CGFloat] (repeating: 0, count: 10)
        for index in 0...9 {
            if record.mediaType[index] == "photo" {
                if record.photoWidth[index] != 0 {
                    imageWidth[index] = UIScreen.main.bounds.width - 10
                    imageHeight[index] = imageWidth[index] * CGFloat(record.photoHeight[index]) / CGFloat(record.photoWidth[index])
                    
                }
                
                position1 = position2
                position2 += imageHeight[index] + 4
                if touch.y >= position1 && touch.y < position2 {
                    res = "show_photo_\(index)"
                }
            }
            
            if record.mediaType[index] == "link" {
                if record.photoURL[index] != "" {
                    if CGFloat(record.photoWidth[index]) < UIScreen.main.bounds.width {
                        imageWidth[index] = UIScreen.main.bounds.width - 10.0
                        imageHeight[index] = CGFloat(record.photoHeight[index])
                    } else {
                        imageWidth[index] = UIScreen.main.bounds.width - 10
                        imageHeight[index] = imageWidth[index] * CGFloat(record.photoHeight[index]) / CGFloat(record.photoWidth[index])
                    }
                    
                    position1 = position2
                    position2 += imageHeight[index] + 4
                    /*if touch.y >= position1 && touch.y < position2 {
                     res = "open_link"
                     }*/
                }
            }
            
            if record.mediaType[index] == "video" {
                if record.photoURL[index] != "" {
                    imageWidth[index] = UIScreen.main.bounds.width - 10.0
                    imageHeight[index] = imageWidth[index] * 240.0 / 320.0
                
                    position1 = position2
                    position2 += imageHeight[index] + 4
                    if touch.y >= position1 && touch.y < position2 {
                        res = "show_video_\(index)"
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
