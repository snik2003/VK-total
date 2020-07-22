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
        OperationQueue.main.addOperation {
            ViewControllerUtils.container.frame = uiView.frame
            ViewControllerUtils.container.center = uiView.center
            ViewControllerUtils.container.backgroundColor = UIColor.clear
            
            ViewControllerUtils.loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            ViewControllerUtils.loadingView.center = uiView.center
            ViewControllerUtils.loadingView.backgroundColor = self.colorFromHex(rgbValue: 0x444444, alpha: 0.7)
            ViewControllerUtils.loadingView.clipsToBounds = true
            ViewControllerUtils.loadingView.layer.cornerRadius = 10
            
            ViewControllerUtils.activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40);
            ViewControllerUtils.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
            //ViewControllerUtils.activityIndicator.color = UIColor.black
            ViewControllerUtils.activityIndicator.center = CGPoint(x: ViewControllerUtils.loadingView.frame.size.width / 2,
                                                                   y: ViewControllerUtils.loadingView.frame.size.height / 2);
            
            ViewControllerUtils.container.layer.borderColor = vkSingleton.shared.labelColor.cgColor
            ViewControllerUtils.container.layer.borderWidth = 0.5
            
            if #available(iOS 13.0, *) {
                if AppConfig.shared.autoMode && ViewControllerUtils.loadingView.traitCollection.userInterfaceStyle == .dark {
                    ViewControllerUtils.loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
                    ViewControllerUtils.activityIndicator.color = UIColor.white
                } else if AppConfig.shared.darkMode {
                    ViewControllerUtils.loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
                    ViewControllerUtils.activityIndicator.color = UIColor.white
                }
            } else if AppConfig.shared.darkMode {
                ViewControllerUtils.loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
                ViewControllerUtils.activityIndicator.color = UIColor.white
            }
            
            ViewControllerUtils.loadingView.addSubview(ViewControllerUtils.activityIndicator)
            ViewControllerUtils.container.addSubview(ViewControllerUtils.loadingView)
            uiView.addSubview(ViewControllerUtils.container)
            ViewControllerUtils.activityIndicator.startAnimating()
        }
    }
    
    func hideActivityIndicator() {
        OperationQueue.main.addOperation {
            ViewControllerUtils.activityIndicator.stopAnimating()
            ViewControllerUtils.container.removeFromSuperview()
        }
    }
    
    func colorFromHex(rgbValue: UInt32, alpha: Double=1.0) -> UIColor {
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
