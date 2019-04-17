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
                
                print(credential.oauthToken)
                print(credential.oauthTokenSecret)
                print(parameters["user_id"] as Any)
                // Do your request
                
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
        parameters["method"] = Constants.photosForLocation
        parameters["api_key"] = Constants.key
        parameters["lat"] = "-8.057984"
        parameters["lon"] = "-34.872332"
        parameters["format"] = Constants.format
        parameters["nojsoncallback"] = Constants.jsonCallback
        parameters["auth_token"] = Constants.authToken
        parameters["api_sig"] = Constants.apiSig
        
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
                print(response)
                print(dataString)
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
