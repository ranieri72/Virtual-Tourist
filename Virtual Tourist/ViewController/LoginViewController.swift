//
//  LoginViewController.swift
//  Virtual Tourist
//
//  Created by Ranieri Aguiar on 16/04/19.
//  Copyright © 2019 Ranieri. All rights reserved.
//

import UIKit
import OAuthSwift

class LoginViewController: OAuthViewController {
    
    @IBOutlet var btnLogin: UIButton!
    
    //var foto:UIImage = #imageLiteral(resourceName: )
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func login(_ sender: UIButton) {
        //Requester().doOAuthFlickr(view: self)
    }
}
