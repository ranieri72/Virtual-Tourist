//
//  Requester.swift
//  Virtual Tourist
//
//  Created by Ranieri Aguiar on 11/04/19.
//  Copyright © 2019 Ranieri. All rights reserved.
//

import UIKit
import OAuthSwift
import CoreData
import SafariServices

class Requester {
    
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getImagesFlickr(pin: Pin, page: Int, sucess: @escaping () -> Void, fail: @escaping (_ msg: String) -> Void) {
        let url = getSearchUrl(pin, page)
        
        _ = Requester.oauthswift.client.get(
            url,
            success: { response in
                let json1 =  try! JSONSerialization.jsonObject(with: response.data, options: []) as? [String:AnyObject]
                let json2 = json1?["photos"] as! [String:AnyObject]
                let json3 = json2["photo"] as! [[String:AnyObject]]
                
                DispatchQueue.global().async {
                    for photoJson in json3 {
                        self.savePhoto(photoJson, pin, self.context)
                    }
                }
                sucess()
        },
            failure: { error in
                print(error)
                fail(error.localizedDescription)
        }
        )
    }
    
    private func savePhoto(_ json: [String: AnyObject], _ pin: Pin, _ context: NSManagedObjectContext) {
        let photo = Photo(json: json, context: context)
        photo.url = self.getPhotoUrl(photo)
        photo.image = self.downloadImages(photo: photo)
        photo.pin = pin
        
        context.perform {
            try? context.save()
        }
    }
    
    private func downloadImages(photo: Photo) -> Data {
        if let url = URL(string: photo.url ?? "") {
            if let data = try? Data(contentsOf: url) {
                return data
            }
        }
        return Data()
    }
    
    private func getSearchUrl(_ pin: Pin, _ page: Int) -> String {
        var url = Constants.url
        
        var parameters = [String : String]()
        parameters["lat"] = String(pin.lat)
        parameters["lon"] = String(pin.long)
        parameters["nojsoncallback"] = Constants.jsonCallback
        parameters["format"] = Constants.format
        parameters["method"] = Constants.photosSearch
        parameters["accuracy"] = Constants.accuracy
        parameters["per_page"] = Constants.per_page
        parameters["api_key"] = Constants.key
        parameters["page"] = String(page)
        
        for (offset: index, element: (key: key, value: value)) in parameters.enumerated() {
            url.append(key + "=" + value)
            if index < parameters.count - 1 {
                url.append("&")
            }
        }
        return url
    }
    
    private func getPhotoUrl(_ photo: Photo) -> String {
        return String(format: Constants.urlPhoto, photo.farm, photo.server!, photo.id!, photo.secret!, Constants.size)
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
