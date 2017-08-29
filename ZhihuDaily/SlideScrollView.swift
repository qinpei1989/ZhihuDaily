//
//  SlideScrollView.swift
//  ZhihuDaily
//
//  Created by Pei Qin on 08/26/2017.
//  Copyright © 2017 Columbia University. All rights reserved.
//

import UIKit
import SDWebImage

protocol SlideScrollViewDelegate: class {
    func slideScrollViewDidTouch(_ slideScrollView: SlideScrollView, imageViewIndex index: Int)
}

class SlideScrollView: UIView {

    var scrollView: UIScrollView!
    var imageViews = [UIImageView]()    //0:left, 1:center, 2:right
    var titleLabels = [UILabel]()       //0:left, 1:center, 2:right
    var shadowImageView: UIImageView!

    var pageControl: UIPageControl!
    var currentImageIndex = 0
    var numberOfImages = 0
    
    var titleArray = [String]()
    var imageArray = [String]()
    
    weak var timer: Timer?
    weak var delegate: SlideScrollViewDelegate?
    
    init(frame: CGRect, titles: [String], images: [String]) {
        super.init(frame: frame)

        numberOfImages = titles.count
        titleArray = titles
        imageArray = images
        
        /******* Add UIScrollView ********/
        scrollView = UIScrollView(frame: frame)
        scrollView.contentSize = CGSize(width: (CGFloat)(numberOfImages)*frame.width, height: frame.height)
        scrollView.setContentOffset(CGPoint(x: frame.width, y: 0), animated: true)
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.decelerationRate = 0.0
        self.addSubview(scrollView)
        
        /******* Add UIPageControl *******/
        pageControl = UIPageControl()
        let pageControlSize = pageControl.size(forNumberOfPages: numberOfImages)
        pageControl.bounds = CGRect(x: 0, y: 0, width: pageControlSize.width, height: pageControlSize.height)
        pageControl.center = CGPoint(x: frame.width/2, y: frame.height - 20)
        pageControl.numberOfPages = numberOfImages
        pageControl.currentPage = 0
        self.addSubview(pageControl)
    
        
        /******* Add UIImageView *********/
        for i in 0..<3 {
            let imageView = UIImageView(frame: CGRect(x: (CGFloat)(i)*frame.width, y: 0, width: frame.width, height: frame.height))
            imageView.contentMode = .scaleAspectFill
            imageViews.append(imageView)
            scrollView.addSubview(imageView)
        }
        
        /******* Add ShadowImageView *******/
        shadowImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 3 * frame.width, height: frame.height))
        shadowImageView.image = UIImage(named: "Shadow")
        shadowImageView.contentMode = .scaleAspectFill
        scrollView.addSubview(shadowImageView)
        
        /******* Add UILabel *********/
        for i in 0..<3 {
            let titleLabel = UILabel(frame: CGRect(x: (CGFloat)(i)*frame.width + 10, y: frame.height - 80, width: frame.width - 20, height: 60))
            titleLabel.textColor = UIColor.white
            titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
            titleLabel.numberOfLines = 0
            titleLabels.append(titleLabel)
            scrollView.addSubview(titleLabel)
            
            let index = (i + numberOfImages - 1) % numberOfImages
            imageViews[i].sd_setImage(with: URL(string: imageArray[index]))
            titleLabels[i].text = titles[index]
        }

        /******* Add TapGestureRecognizer *******/
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewTouched(_:)))
        scrollView.addGestureRecognizer(tapRecognizer)
    }
    
    func scrollViewTouched(_ gestureRecognizer: UIGestureRecognizer) {
        delegate?.slideScrollViewDidTouch(self, imageViewIndex: currentImageIndex)
    }
    
    func showNextImage() {
        UIView.animate(withDuration: 0.5) {
            self.scrollView.contentOffset.x = self.frame.width * 2
        }
        scrollViewDidEndDecelerating(scrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /* 使用三个UIImageView来达到循环播放多张图片的效果 */
    func reloadImages() {
        var leftImageIndex = 0
        var rightImageIndex = 0
        var indexArray = [Int]()
        
        let offset = scrollView.contentOffset
        
        if offset.x > frame.width {
            currentImageIndex = (currentImageIndex + 1) % numberOfImages
        } else if offset.x < frame.width {
            currentImageIndex = (currentImageIndex + numberOfImages - 1) % numberOfImages
        }
        
        leftImageIndex = (currentImageIndex + numberOfImages - 1) % numberOfImages
        rightImageIndex = (currentImageIndex + 1) % numberOfImages
        
        indexArray.append(leftImageIndex)
        indexArray.append(currentImageIndex)
        indexArray.append(rightImageIndex)
        
        for i in 0..<3 {
            imageViews[i].sd_setImage(with: URL(string: imageArray[indexArray[i]]))
            titleLabels[i].text = titleArray[indexArray[i]]
        }
    }
}

extension SlideScrollView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        reloadImages()
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.width, y: 0), animated: false)
        pageControl.currentPage = currentImageIndex
    }

}
