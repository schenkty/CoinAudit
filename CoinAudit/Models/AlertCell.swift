//
//  AlertCell.swift
//  CoinAudit
//
//  Created by Ty Schenk on 1/6/18.
//  Copyright © 2018 Ty Schenk. All rights reserved.
//

import UIKit

class AlertCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var aboveLabel: UILabel!
    @IBOutlet var belowLabel: UILabel!
    
    var action: AlertActions = .False
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
