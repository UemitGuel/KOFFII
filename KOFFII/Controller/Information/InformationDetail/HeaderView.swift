//
//  HeaderView.swift
//  KOFFII
//
//  Created by Ümit Gül on 06.07.19.
//  Copyright © 2019 Ümit Gül. All rights reserved.
//

import UIKit

class HeaderView: UITableViewCell {

    @IBOutlet weak var quanLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
