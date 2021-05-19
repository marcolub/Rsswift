//
//  customCellTableViewCell.swift
//  Rsswift
//
//  Created by marco luberto on 10/12/2019.
//  Copyright © 2019 ArledKola. All rights reserved.
//

import UIKit

class customCellTableViewCell: UITableViewCell {

    var urlString : String = ""
    
    override func layoutSubviews(){
        super.layoutSubviews()
        self.imageView?.frame = CGRect(x:0.0,y:0.0,width:80,height:80)
        self.textLabel?.frame = CGRect(x:85,y:0,width: 300,height:80)
        self.detailTextLabel?.frame = CGRect(x:85,y:80,width: 300,height:25)
        DispatchQueue.main.async {
            self.setNeedsLayout()
             
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
