//
//  BriefPersonTableViewCell.swift
//  SD-IOS-Cartable
//
//  Created by Ashkan Ghaderi on 2/23/16.
//  Copyright © 2016 Ashkan Ghaderi. All rights reserved.
//

import UIKit

class BriefPersonTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceNameLable: UILabel!
    @IBOutlet weak var serialLable: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configuration(personDevice : PersonDevicesModel){
        self.deviceNameLable.text = personDevice.deviceAliasName
        self.serialLable.text = personDevice.qcSerial
    }

}
