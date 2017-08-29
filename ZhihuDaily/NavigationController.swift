//
//  NavigationController.swift
//  ZhihuDaily
//
//  Created by Pei Qin on 08/27/2017.
//  Copyright © 2017 Columbia University. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    /* 使status bar文字变白 */
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.topViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
