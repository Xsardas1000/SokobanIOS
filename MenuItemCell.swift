//
//  MenuItemCell.swift
//  Sokoban
//
//  Created by Максим on 23.12.16.
//  Copyright © 2016 Максим. All rights reserved.
//

import UIKit

class MenuItemCell: UITableViewCell {
    

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var numPlayer: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
