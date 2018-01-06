//
//  AlertTableViewCell.swift
//  CoinAudit
//
//  Created by Ty Schenk on 1/6/18.
//  Copyright © 2018 Ty Schenk. All rights reserved.
//

import UIKit

class AlertTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!
    
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