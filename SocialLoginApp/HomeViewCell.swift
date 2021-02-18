//
//  TableViewCell.swift
//  SocialLoginApp
//
//  Created by Gianmarco Cotellessa on 18/02/21.
//

import UIKit

class HomeViewCell: UITableViewCell {
    
    static let identifier = "HomeViewCell"
    
    var cellLabel: UILabel = {
        var label = UILabel()
        label.textColor = .white
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func makeUI() {
        self.contentView.addSubview(cellLabel)
        cellLabel.snp.makeConstraints { maker in
            maker.center.equalTo(contentView)
        }
    }

}
