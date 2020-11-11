//
//  PhotoSelectionCell.swift
//  LHPhotoPicker
//
//  Created by Igor Lukash on 09.11.2020.
//

import UIKit

class PhotoSelectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnSelector: UIButton!
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //btnSelector.backgroundColor = .yellow
        //print("initialize cell")
    }
}

