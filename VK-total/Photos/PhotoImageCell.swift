//
//  PhotoImageCell.swift
//  VK-total
//
//  Created by Сергей Никитин on 13.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class PhotoImageCell: UITableViewCell, UIScrollViewDelegate {

    var delegate: PhotoViewController!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photoImage: UIImageView!
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.photoImage
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        delegate.navigationController?.setNavigationBarHidden(true, animated: false)
        delegate.tabBarController?.tabBar.isHidden = true
        delegate.tableView.reloadData()
    }
    
    @objc func doubleTapAction(sender: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            self.scrollView.setZoomScale(3, animated: true)
        } else {
            self.scrollView.setZoomScale(1, animated: true)
        }
    }
}
