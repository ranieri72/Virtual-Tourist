//
//  ViewControllerExtension.swift
//  Virtual Tourist
//
//  Created by Ranieri Aguiar on 26/04/19.
//  Copyright © 2019 Ranieri. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentAlertView(msg: String) {
        let alert = UIAlertController(title: "Alerta", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
