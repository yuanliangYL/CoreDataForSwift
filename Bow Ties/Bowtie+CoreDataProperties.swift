//
//  Bowtie+CoreDataProperties.swift
//  Bow Ties
//
//  Created by AlbertYuan on 2021/2/22.
//  Copyright © 2021 Razeware. All rights reserved.
//
//

import Foundation
import CoreData


extension Bowtie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bowtie> {
        return NSFetchRequest<Bowtie>(entityName: "Bowtie")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var lastWorn: Date?


    @NSManaged public var photoData: Data?
  /**
   Binary Data：
   “With the photoData attribute selected, open the Attributes Inspector and check the    **Allows External Storage**    option.”
   */


    @NSManaged public var rating: Double
    @NSManaged public var searchKey: String?
    @NSManaged public var timesWorn: Int32
    @NSManaged public var tintColor: NSObject?
    @NSManaged public var url: URL?
    @NSManaged public var name: String?

}
