//
//  ListCell.swift
//  Drag&DropList
//
//  Created by Sachin on 07/12/17.
//  Copyright © 2017 Pixelpoint. All rights reserved.
//

import UIKit

class ListCell: UITableViewCell {
    
    @IBOutlet var dragBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
