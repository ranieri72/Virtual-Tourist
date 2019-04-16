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
    
    static let key = "13b803f43deaf6283141e04946398b20"
    static let pass = "2d8857aa559c1b17"
    
    static let url = " https://api.flickr.com/services/rest/?"
    
    static let photosForLocation = "method=flickr.photos.geo.photosForLocation&"
    static let apiKey = "api_key=13b803f43deaf6283141e04946398b20&"
    static let lat = "lat=-8.057984&"
    static let long = "lon=-34.872332&"
    static let format = "format=json&"
    static let jsonCallback = "nojsoncallback=1&"
    static let authToken = "auth_token=72157690855891693-1ff37d4d86973846&"
    static let api = "api_sig=eecc5c506dd8d33527c7fd61eca2dcee"
}
