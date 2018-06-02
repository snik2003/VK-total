//
//  ViewControllerUtils.swift
//  VK-total
//
//  Created by Сергей Никитин on 17.03.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class ViewControllerUtils {
    
    private static var container: UIView = UIView()
    private static var loadingView: UIView = UIView()
    private static var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    func showActivityIndicator(uiView: UIView) {
        ViewControllerUtils.container.frame = uiView.frame
        ViewControllerUtils.container.center = uiView.center
        ViewControllerUtils.container.backgroundColor = UIColor.clear
        
        ViewControllerUtils.loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        ViewControllerUtils.loadingView.center = uiView.center
        ViewControllerUtils.loadingView.backgroundColor = UIColorFromHex(rgbValue: 0x444444, alpha: 0.7)
        ViewControllerUtils.loadingView.clipsToBounds = true
        ViewControllerUtils.loadingView.layer.cornerRadius = 10
        
        ViewControllerUtils.activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40);
        ViewControllerUtils.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        //ViewControllerUtils.activityIndicator.color = UIColor.black
        ViewControllerUtils.activityIndicator.center = CGPoint(x: ViewControllerUtils.loadingView.frame.size.width / 2, y: ViewControllerUtils.loadingView.frame.size.height / 2);
        
        ViewControllerUtils.loadingView.addSubview(ViewControllerUtils.activityIndicator)
        ViewControllerUtils.container.addSubview(ViewControllerUtils.loadingView)
        uiView.addSubview(ViewControllerUtils.container)
        ViewControllerUtils.activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        ViewControllerUtils.activityIndicator.stopAnimating()
        ViewControllerUtils.container.removeFromSuperview()
    }
    
    func UIColorFromHex(rgbValue: UInt32, alpha: Double=1.0) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red: red, green: green, blue: blue, alpha: CGFloat(alpha))
    }
}

extension UIView {
    var visibleRect: CGRect {
        guard let superview = superview else { return frame }
        print(superview.bounds)
        print(frame)
        print(frame.intersection(superview.bounds))
        return frame.intersection(superview.bounds)
    }
}
