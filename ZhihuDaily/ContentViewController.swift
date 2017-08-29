//
//  ContentViewController.swift
//  ZhihuDaily
//
//  Created by Pei Qin on 08/26/2017.
//  Copyright © 2017 Columbia University. All rights reserved.
//

import UIKit
import WebKit
import SDWebImage

let contentURL = "https://news-at.zhihu.com/api/4/news/"

class ContentViewController: UIViewController {
    var webView: WKWebView!
    var imageView: UIImageView!
    var shadowView: UIImageView!
    var titleLabel: UILabel!
    var imageSourceLabel: UILabel!
    
    var storyId: Int!
    var currentOffsetY: CGFloat = 0.0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.scrollView.delegate = self
        view = webView
    }
    
    func fetchStoryContent() {
        let url = contentURL + String(storyId)
        
        Utils.processHttpRequest(withURLString: url) { (jsonData) in
            let jsonDict = jsonData as! [String: Any]
            var htmlBody = jsonDict["body"] as! String
            let imageUrl = jsonDict["image"] as! String
            let title = jsonDict["title"] as! String
            let imageSource = jsonDict["image_source"] as? String
            let css = jsonDict["css"] as! [String]
        
            self.imageView.sd_setImage(with: URL(string: imageUrl))
            htmlBody = "<link href='\(css.first!)' rel='stylesheet' type='text/css' />" +
                "<meta name=\"viewport\" content=\"initial-scale=1.0\" />" + htmlBody
            self.webView.loadHTMLString(htmlBody, baseURL: nil)
            self.titleLabel.text = title
            
            if let imageSource = imageSource {
                self.imageSourceLabel.text = "图片：\(imageSource)"
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.alpha = 0.75
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.alpha = 1.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight/3))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        webView.scrollView.addSubview(imageView)
        
        shadowView = UIImageView(frame: imageView.frame)
        shadowView.image = UIImage(named: "Shadow")
        shadowView.contentMode = .scaleAspectFill
        webView.scrollView.addSubview(shadowView)
        
        titleLabel = UILabel(frame: CGRect(x: 10, y: shadowView.frame.height - 60, width: shadowView.frame.width - 20, height: 60))
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.numberOfLines = 0
        shadowView.addSubview(titleLabel)

        imageSourceLabel = UILabel(frame: CGRect(x: 10, y: imageView.frame.height - 15, width: screenWidth - 20, height: 10))
        imageSourceLabel.textColor = UIColor.lightGray
        imageSourceLabel.font = UIFont(name: "Arial", size: 10)
        imageSourceLabel.textAlignment = .right
        imageView.addSubview(imageSourceLabel)
        
        fetchStoryContent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ContentViewController: WKUIDelegate {
    
}

extension ContentViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        
        if offsetY > currentOffsetY {
            self.navigationController?.navigationBar.isHidden = true
        } else {
            self.navigationController?.navigationBar.isHidden = false
        }
        
        currentOffsetY = offsetY
        
        var imageViewFrame = imageView.frame
        imageViewFrame.origin.y = offsetY
        imageViewFrame.size.height = screenHeight/3 - offsetY
        imageView.frame = imageViewFrame
        
        var imageSourceLabelFrame = imageSourceLabel.frame
        imageSourceLabelFrame.origin.y = imageView.frame.height - 15
        imageSourceLabel.frame = imageSourceLabelFrame
 
    }
}
