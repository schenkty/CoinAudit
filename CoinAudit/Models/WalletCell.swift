//
//  WalletCell.swift
//  CoinAudit
//
//  Created by Ty Schenk on 12/28/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit

class WalletCell: UITableViewCell {

    @IBOutlet var symbolLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var percentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
