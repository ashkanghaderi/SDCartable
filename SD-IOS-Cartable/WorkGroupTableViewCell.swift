//
//  WorkGroupTableViewCell.swift
//  SD-IOS-Cartable
//
//  Created by Ashkan Ghaderi on 2/24/16.
//  Copyright © 2016 Ashkan Ghaderi. All rights reserved.
//

import UIKit

class WorkGroupTableViewCell: UITableViewCell {

    @IBOutlet weak var workGroupTitleLable: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func Configuration(workGroup : WorkGroupModel){
        self.workGroupTitleLable.text = workGroup.workGroupTitle
    }

}
