//
//  Walk+CoreDataProperties.swift
//  Dog Walk
//
//  Created by AlbertYuan on 2021/2/23.
//  Copyright © 2021 Razeware. All rights reserved.
//
//

import Foundation
import CoreData


extension Walk {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Walk> {
        return NSFetchRequest<Walk>(entityName: "Walk")
    }

    @NSManaged public var date: Date?
    @NSManaged public var dog: Dog?

}
