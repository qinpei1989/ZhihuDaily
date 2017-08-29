//
//  HomeViewCell.swift
//  ZhihuDaily
//
//  Created by Pei Qin on 08/26/2017.
//  Copyright © 2017 Columbia University. All rights reserved.
//

import UIKit

class HomeViewCell: UITableViewCell {
    @IBOutlet weak var storyTitle: UITextView!
    @IBOutlet weak var storyImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        storyTitle.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
