//
//  WalletValueCell.swift
//  CoinAudit
//
//  Created by Ty Schenk on 1/6/18.
//  Copyright © 2018 Ty Schenk. All rights reserved.
//

import UIKit

class WalletValueCell: UITableViewCell {

    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var percentLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
    }

}
