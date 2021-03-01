//
//  Attachment.swift
//  UnCloudNotes
//
//  Created by AlbertYuan on 2021/2/26.
//  Copyright © 2021 Ray Wenderlich. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Attachment: NSManagedObject {

  @NSManaged var dateCreated:Date?

  //deleted from the code
  //@NSManaged var image:UIImage?

  @NSManaged var note:Note?

}
