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
    
    func setupCell(photo: Photo) {
        if let imageData = photo.image {
            imgPhoto.image = UIImage(data: imageData)
        }
    }
}
