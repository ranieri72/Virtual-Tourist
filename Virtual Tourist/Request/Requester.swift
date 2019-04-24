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
                self.getImagesFlickr()
        },
            failure: { error in
                print(error.description)
        }
        )
    }
    
    func getImagesFlickr() {
        var url = Constants.url
        
        var parameters = [String : String]()
        parameters["lat"] = "40.763764"
        parameters["lon"] = "-73.975562"
        parameters["nojsoncallback"] = Constants.jsonCallback
        parameters["format"] = Constants.format
        parameters["method"] = Constants.photosForLocation
        parameters["accuracy"] = Constants.accuracy
        parameters["per_page"] = Constants.per_page
        
        for (offset: index, element: (key: key, value: value)) in parameters.enumerated() {
            url.append(key + "=" + value)
            if index < parameters.count - 1 {
                url.append("&")
            }
        }
        
        _ = Requester.oauthswift.client.get(
            url,
            success: { response in
                let dataString = response.dataString(encoding: .utf8)
                print(dataString as Any)
        },
            failure: { error in
                print(error)
        }
        )
    }
    
    func getURLHandler(_ view: UIViewController) -> OAuthSwiftURLHandlerType {
        
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
