//
//  User+CoreDataProperties.swift
//  SD-IOS-Cartable
//
//  Created by Ashkan Ghaderi on 2/3/16.
//  Copyright © 2016 Ashkan Ghaderi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var personid: NSNumber?
    @NSManaged var userfullname: String?
    @NSManaged var guidtoken: String?
    @NSManaged var appversion: String?

}
