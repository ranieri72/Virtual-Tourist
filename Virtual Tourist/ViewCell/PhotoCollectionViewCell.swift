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
        func sucess(image: UIImage?) {
            imgPhoto.image = image
        }
        func fail(msg: String) {
            
        }
        Requester().downloadImages(urlString: photo.url!, sucess: sucess, fail: fail)
    
    }

}
