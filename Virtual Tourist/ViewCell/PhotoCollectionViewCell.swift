//
//  PhotoCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Ranieri Aguiar on 26/04/19.
//  Copyright © 2019 Ranieri. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imgPhoto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(photo: Photo) {
        if let image = photo.image as? UIImage {
            imgPhoto.image = image
        }
    }
}
