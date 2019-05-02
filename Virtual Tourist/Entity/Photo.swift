//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Ranieri Aguiar on 02/05/19.
//  Copyright © 2019 Ranieri. All rights reserved.
//

import CoreData

extension Photo {
    
    convenience init(json: [String:AnyObject], context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = json["id"] as? String ?? ""
        self.owner = json["owner"] as? String ?? ""
        secret = json["secret"] as? String ?? ""
        server = json["server"] as? String ?? ""
        farm = json["farm"] as? Int32 ?? 0
    }
}
