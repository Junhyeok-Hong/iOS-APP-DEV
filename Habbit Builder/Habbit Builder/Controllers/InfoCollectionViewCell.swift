//
//  InfoCollectionViewCell.swift
//  Habbit Builder
//
//  Created by Michael Hong on 2020-07-14.
//  Copyright © 2020 Junhyeok Hong. All rights reserved.
//

import UIKit

class InfoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configure(dataIs data: String, descriptionIs description: String) {
        dataLabel.text = data
        descriptionLabel.text = description
    }
}
