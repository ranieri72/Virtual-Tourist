//
//  Requester.swift
//  Virtual Tourist
//
//  Created by Ranieri Aguiar on 11/04/19.
//  Copyright © 2019 Ranieri. All rights reserved.
//

import UIKit
import OAuthSwift
import SafariServices

class Requester {
    
    func getImagesFlickr(_ lat: String, _ long: String, sucess: @escaping (_ photos: [Photo]) -> Void, fail: @escaping (_ msg: String) -> Void) {
        let url = getSearchUrl(lat, long)
        
        _ = Requester.oauthswift.client.get(
            url,
            success: { response in
                let json1 =  try! JSONSerialization.jsonObject(with: response.data, options: []) as? [String:AnyObject]
                let json2 = json1?["photos"] as! [String:AnyObject]
                let json3 = json2["photo"] as! [[String:AnyObject]]
                var photos = [Photo]()
                
                for photoJson in json3 {
                    let photo = Photo(json: photoJson)
                    photo.url = self.getPhotoUrl(photo)
                    photo.lat = lat
                    photo.long = long
                    photos.append(photo)
                }
                sucess(photos)
        },
            failure: { error in
                print(error)
        }
        )
    }
    
    func downloadImages(urlString: String, sucess: @escaping (_ image: UIImage?) -> Void, fail: @escaping (_ msg: String) -> Void) {
        let url = URL(string: urlString)
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                sucess(UIImage(data: data!))
            }
        }
    }
    
    private func getSearchUrl(_ lat: String, _ long: String) -> String {
        var url = Constants.url
        
        var parameters = [String : String]()
        parameters["lat"] = lat
        parameters["lon"] = long
        parameters["nojsoncallback"] = Constants.jsonCallback
        parameters["format"] = Constants.format
        parameters["method"] = Constants.photosSearch
        parameters["accuracy"] = Constants.accuracy
        parameters["per_page"] = Constants.per_page
        
        for (offset: index, element: (key: key, value: value)) in parameters.enumerated() {
            url.append(key + "=" + value)
            if index < parameters.count - 1 {
                url.append("&")
            }
        }
        return url
    }
    
    private func getPhotoUrl(_ photo: Photo) -> String {
        return String(format: Constants.urlPhoto, photo.farm, photo.server, photo.id, photo.secret, Constants.size)
    }
    
    // MARK: OAuth Flickr
    
    private static var oauthswift: OAuth1Swift = {
        print("oauthswift foi instanciado")
        return OAuth1Swift(
            consumerKey: Constants.key,
            consumerSecret: Constants.pass,
            requestTokenUrl: Constants.requestTokenUrl,
            authorizeUrl: Constants.authorizeUrl,
            accessTokenUrl: Constants.accessTokenUrl
        )
    }()
    
    func doOAuthFlickr(view: UIViewController) {
        Requester.oauthswift.authorizeURLHandler = getURLHandler(view)
        Requester.oauthswift.authorize(
            withCallbackURL: URL(string: "virtual-tourist://oauth-callback/flickr")!,
            success: { credential, response, parameters in
                
                let user = User()
                user.oauthVerifier = credential.oauthVerifier
                user.oauthToken = credential.oauthToken
                user.oauthTokenSecret = credential.oauthTokenSecret
                user.consumerKey = credential.consumerKey
                user.consumerSecret = credential.consumerSecret
                user.userNsid = parameters["user_nsid"] as! String
                user.username = parameters["username"] as! String
                user.fullname = parameters["fullname"] as! String
                UserSession.user = user
        },
            failure: { error in
                print(error.description)
        }
        )
    }
    
    private func getURLHandler(_ view: UIViewController) -> OAuthSwiftURLHandlerType {
        
        let handler = SafariURLHandler(viewController: view, oauthSwift: Requester.oauthswift)
        handler.presentCompletion = {
            print("Safari presented")
        }
        handler.dismissCompletion = {
            print("Safari dismissed")
        }
        handler.factory = { url in
            let controller = SFSafariViewController(url: url)
            // Customize it, for instance
            if #available(iOS 10.0, *) {
                //  controller.preferredBarTintColor = UIColor.red
            }
            return controller
        }
        return handler
    }
}
