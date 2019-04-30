//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Ranieri Aguiar on 25/04/19.
//  Copyright © 2019 Ranieri. All rights reserved.
//

class FlickrPhoto {
    
    init(json: [String:AnyObject]) {
        id = json["id"] as? String ?? ""
        owner = json["owner"] as? String ?? ""
        secret = json["secret"] as? String ?? ""
        server = json["server"] as? String ?? ""
        farm = json["farm"] as? Int ?? 0
    }
    
    var id: String
    var owner: String
    var secret: String
    var server: String
    var farm: Int
    
    var url: String?
    var lat: String?
    var long: String?
}
