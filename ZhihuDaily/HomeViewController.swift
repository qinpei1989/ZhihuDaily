//
//  HomeViewController.swift
//  ZhihuDaily
//
//  Created by Pei Qin on 08/26/2017.
//  Copyright © 2017 Columbia University. All rights reserved.
//

import UIKit
import SDWebImage

let homeViewCellIdentifier = "HomeViewCell"
let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height
let tableRowHeight: CGFloat = 80
let tableSectionHeaderHeight: CGFloat = 30

let latestURL = "http://news-at.zhihu.com/api/4/news/latest"
let pastURL = "http://news-at.zhihu.com/api/4/stories/before/"

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var titleView: UIView!
    var titleLabel: UILabel!
    var tableHeaderView: UIView!
    var slideScrollView: SlideScrollView!
    var activityIndicator: UIActivityIndicatorView!
    
    var topStoryTitles = [String]()
    var topStoryImages = [String]()
    var topStoryIds = [Int]()
    
    var dates = [String]()
    var allStoryData = [String: [[String: Any]]]()  //key: date, value: story data
    
    var sectionHeights = [CGFloat]()
    var currentSectionIndex = 0
    
    var isLoadingData = false
    var loadNewData = false
    var dateString = String()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func fireTimer() {
        if slideScrollView != nil {
            stopTimer()
            slideScrollView.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: { (_) in
                self.slideScrollView.showNextImage()
            })
        }
    }
    
    func stopTimer() {
        slideScrollView.timer?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    
        fireTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.subviews[0].alpha = 1.0
        
        stopTimer()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        /***** tableHeaderView用来在顶部滚动展示图片 *************/
        tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight/3))
        tableView.tableHeaderView = self.tableHeaderView
        tableView.scrollsToTop = true
        tableView.rowHeight = tableRowHeight
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.subviews[0].alpha = 0.0 // 完全隐藏navigationBar，包括title与barButton
        self.automaticallyAdjustsScrollViewInsets = false   // 使tableView充满屏幕，不在navgigationBar下方
        
        titleView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        titleLabel = UILabel(frame: CGRect(x: 30, y: 0, width: 140, height: 40))
        titleLabel.text = "今日热闻"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        self.title = "今日热闻"
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 40))
        titleView.addSubview(activityIndicator)
        titleView.addSubview(titleLabel)
        self.navigationItem.titleView = titleView
        
        fetchData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchData() {
        if isLoadingData {
            return
        }
        isLoadingData = true
        activityIndicator.startAnimating()
        
        /* 第一次会下载当日的数据，之后每一次都会下载之前一天的数据 */
        var url = latestURL
        if !dateString.isEmpty {
            url = pastURL + dateString
        }
        
        Utils.processHttpRequest(withURLString: url) { (jsonData) in
            self.isLoadingData = false
            
            let jsonDict = jsonData as! [String: Any]

            let storyArray = jsonDict["stories"] as! [[String: Any]]
            let topStoryArray = jsonDict["top_stories"] as? [[String: Any]]
            let date = jsonDict["date"] as! String

            if self.dateString.isEmpty {
                self.sectionHeights.removeAll()
                self.sectionHeights.append(contentsOf: [CGFloat(Int.min), CGFloat(Int.max)])
            }
            
            self.dateString = date
            self.dates.append(date)
            self.allStoryData[date] = storyArray

            /* 只有当天的数据会有top stories */
            if let topStoryArray = topStoryArray {
                self.topStoryImages.removeAll()
                self.topStoryTitles.removeAll()
                self.topStoryIds.removeAll()
                for topStory in topStoryArray {
                    let title = topStory["title"] as! String
                    let imageUrl = topStory["image"] as! String
                    let id = topStory["id"] as! Int
                    
                    self.topStoryTitles.append(title)
                    self.topStoryImages.append(imageUrl)
                    self.topStoryIds.append(id)
                }
            }
            
            /* 更新当天的top stories时用，目前意义不大，因为当天的数据只会在第一次时加载 */
            if self.slideScrollView != nil {
                self.slideScrollView.timer?.invalidate()
                self.slideScrollView.removeFromSuperview()
                self.slideScrollView = nil
            }
    
            self.slideScrollView = SlideScrollView(frame: self.tableHeaderView.frame, titles: self.topStoryTitles, images: self.topStoryImages)
            self.slideScrollView.delegate = self
            self.tableHeaderView.addSubview(self.slideScrollView)
            self.tableView.tableHeaderView = self.tableHeaderView
            self.fireTimer()
            /**************************************/
            
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.sectionHeights.insert(self.tableView.contentSize.height, at: self.sectionHeights.count - 1)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowContent" {
            let contentVC = segue.destination as! ContentViewController
            let storyId = sender as! Int
            contentVC.storyId = storyId
        }
    }
    

    func fetchStoryInfo(from storyDataArray: [[String: Any]], with index: Int, for info: String) -> Any?{
        if index < 0 || index >= storyDataArray.count {
            return nil
        }
        
        let storyDict = storyDataArray[index]
        switch info {
        case "title":
            return storyDict["title"]
        case "images":
            let imageArray = storyDict["images"] as? [String]
            return imageArray?.first
        case "id":
            return storyDict["id"]
        default:
            return nil
        }
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dateKey = dates[section]
        return allStoryData[dateKey]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeViewCell", for: indexPath) as! HomeViewCell
        
        let date = dates[indexPath.section]
        let storyForDate = allStoryData[date]
        if let story = storyForDate {
            cell.storyTitle?.text = fetchStoryInfo(from: story, with: indexPath.row, for: "title") as! String
            cell.storyImageView.sd_setImage(with: URL(string: fetchStoryInfo(from: story, with: indexPath.row, for: "images")! as! String))
        }
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else {
            /* 除了当天的数据，以往的内容都在顶部显示日期 */
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
            label.backgroundColor = UIColor(red: 65/255, green: 182/255, blue: 255/255, alpha: 1.0)
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.text = Utils.constructCustomDateString(fromString: dates[section])
            return label
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            return tableSectionHeaderHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let date = dates[indexPath.section]
        let storyForDate = allStoryData[date]
        if let story = storyForDate {
            let storyId = fetchStoryInfo(from: story, with: indexPath.row, for: "id")!
            performSegue(withIdentifier: "ShowContent", sender: storyId)
        }
    }
    
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let tableHeaderViewHeight = tableHeaderView.bounds.size.height
        var navigationBarAlpha: CGFloat = 0.0
        
        if offsetY < 0 {
            /* 显示最顶部数据时，隐藏navigationBar */
            navigationBarAlpha = 0.0
           
            /* 下拉略微放大顶部图片 */
            var slideScrollViewFrame = slideScrollView.frame
            let slideScrollViewHeight = screenHeight / 3
            slideScrollViewFrame.origin.y = offsetY
            slideScrollViewFrame.size.height = slideScrollViewHeight - offsetY
            slideScrollView.frame = slideScrollViewFrame
 
            var scrollViewFrame = slideScrollView.scrollView.frame
            let scrollViewHeight = screenHeight / 3
            scrollViewFrame.size.height = scrollViewHeight - offsetY
            slideScrollView.scrollView.frame = scrollViewFrame

            let imageView = slideScrollView.imageViews[1]
            var imageFrame = imageView.frame
            let imageHeight = screenHeight / 3
            imageFrame.size.height = imageHeight - offsetY
            imageView.frame = imageFrame
            
            var shadowViewFrame = slideScrollView.shadowImageView.frame
            let shadowViewHeight = screenHeight / 3
            shadowViewFrame.size.height = shadowViewHeight - offsetY
            slideScrollView.shadowImageView.frame = shadowViewFrame

            let titleLabel = slideScrollView.titleLabels[1]
            var titleFrame = titleLabel.frame
            titleFrame.origin.y = imageView.frame.height - 80
            titleLabel.frame = titleFrame
            
            var pageControlCenter = slideScrollView.pageControl.center
            pageControlCenter.y = imageView.frame.height - 20
            slideScrollView.pageControl.center = pageControlCenter
            
        } else if offsetY < tableHeaderViewHeight {
            /* 显示下面的数据时，开始逐渐显示navigationBar */
            navigationBarAlpha = offsetY / tableHeaderViewHeight
            fireTimer()
        } else {
            navigationBarAlpha = 1.0
            stopTimer()
        }
        
        if offsetY + screenHeight * 0.9 > tableView.contentSize.height {
            /* 拉到底部时准备加载前一天的数据 */
            loadNewData = true
        }
        
        /* 拉到以前的数据时需要更新navigationBar中的日期
         * 每次更新tableView中的数据后都会用数组记录每个section的高度，数组的头尾插入Int.min与Int.max，方便计算
         */
        if offsetY < sectionHeights[currentSectionIndex] {
            currentSectionIndex -= 1
            updateNavigationBar(withDateIndex: currentSectionIndex)
        } else if offsetY > sectionHeights[currentSectionIndex + 1] {
            currentSectionIndex += 1
            updateNavigationBar(withDateIndex: currentSectionIndex)
        }
     
        self.navigationController?.navigationBar.subviews[0].alpha = navigationBarAlpha
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if loadNewData {
            loadNewData = false
            fetchData()
        }
    }
    
    func updateNavigationBar(withDateIndex index: Int) {
        if index == 0 {
            titleLabel.text = "今日热闻"
        } else {
            titleLabel.text = Utils.constructCustomDateString(fromString: dates[index])
        }
        self.title = titleLabel.text
    }
}

extension HomeViewController: SlideScrollViewDelegate {
    func slideScrollViewDidTouch(_ slideScrollView: SlideScrollView, imageViewIndex index: Int) {
        let storyId = topStoryIds[index]
        performSegue(withIdentifier: "ShowContent", sender: storyId)
    }
}
