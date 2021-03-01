//
//  ImageAttachment.swift
//  UnCloudNotes
//
//  Created by AlbertYuan on 2021/3/1.
//  Copyright © 2021 Ray Wenderlich. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ImageAttachment: Attachment {

    @NSManaged var image: UIImage?
  
    @NSManaged var width: Float

    @NSManaged var height: Float

    @NSManaged var caption: String

}

