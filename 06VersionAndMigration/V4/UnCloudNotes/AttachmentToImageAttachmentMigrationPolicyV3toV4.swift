//
//  AttachmentToImageAttachmentMigrationPolicyV3toV4.swift
//  UnCloudNotes
//
//  Created by AlbertYuan on 2021/3/1.
//  Copyright © 2021 Ray Wenderlich. All rights reserved.
//

import UIKit
import CoreData

let errorDomain = "Migration"

//自定义迁移

// This method is an override of the default NSEntityMigrationPolicy implementation. It’s what the migration manager uses to create instances of destination entities.
class AttachmentToImageAttachmentMigrationPolicyV3toV4: NSEntityMigrationPolicy {

  override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {

    //1“ you create an instance of the new destination object”
    //注意使用目标托管对象上下文
    let description = NSEntityDescription.entity(forEntityName: "ImageAttachment", in: manager.destinationContext)

    //在这里使用这种初始化方式：而不是使用ImageAttachment(context: NSManagedObjectContext)，是为了防止目标模型还未迁移成功导致崩溃
    let newAttachment = ImageAttachment(entity: description!, insertInto: manager.destinationContext)


    //2属性映射操作
    func traversePropertyMappings(block: (NSPropertyMapping, String) -> ()) throws {
      if let attributeMappings = mapping.attributeMappings {
        //属性映射
        for propertyMapping in attributeMappings {
          if let destinationName = propertyMapping.name {
            block(propertyMapping, destinationName)
          } else {
            //3抛出错误
            let message = "Attribute destination not configured properly"
            let userInfo = [NSLocalizedFailureReasonErrorKey: message]
            throw NSError(domain: errorDomain, code: 0, userInfo: userInfo)
          }
        }
      } else {
        //没有需要映射的属性
        let message = "No Attribute Mappings found!"
        let userInfo = [NSLocalizedFailureReasonErrorKey: message]
        throw NSError(domain: errorDomain, code: 0, userInfo: userInfo)
      }
    }

    //4
    try traversePropertyMappings { propertyMapping, destinationName in

      guard let valueExpression = propertyMapping.valueExpression else { return }

      let context: NSMutableDictionary = ["source": sInstance]
      guard let destinationValue = valueExpression.expressionValue(with: sInstance, context: context) else { return }

      newAttachment.setValue(destinationValue, forKey: destinationName)
    }

    //5 得到图片实例
    if let image = sInstance.value(forKey: "image") as? UIImage {

      //赋值宽高
      newAttachment.setValue(image.size.width, forKey: "width")
      newAttachment.setValue(image.size.height, forKey: "height")
    }

    //6赋值标题
    let body = sInstance.value(forKeyPath: "note.body") as? NSString ?? ""
    newAttachment.setValue(body.substring(to: 80), forKey: "caption")

    //7数据关联
    manager.associate(sourceInstance: sInstance, withDestinationInstance: newAttachment, for: mapping)
  }

}
