//
//  Constants.swift
//  Virtual Tourist
//
//  Created by Ranieri Aguiar on 16/04/19.
//  Copyright © 2019 Ranieri. All rights reserved.
//

class Constants {
    static let requestTokenUrl = "https://www.flickr.com/services/oauth/request_token"
    static let authorizeUrl = "https://www.flickr.com/services/oauth/authorize"
    static let accessTokenUrl = "https://www.flickr.com/services/oauth/access_token"
    
    static let urlPhoto = "https://farm%d.staticflickr.com/%@/%@_%@_%@.jpg"
    
    static let key = "13b803f43deaf6283141e04946398b20"
    static let pass = "2d8857aa559c1b17"
    
    static let url = "https://api.flickr.com/services/rest/?"
    static let photosSearch = "flickr.photos.search"
    static let accuracy = "11"
    static let per_page = "15"
    static let format = "json"
    static let jsonCallback = "1"
    static let size = "m"
}
