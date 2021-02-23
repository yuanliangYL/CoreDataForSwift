//
//  CoreDataStack.swift
//  Dog Walk
//
//  Created by AlbertYuan on 2021/2/23.
//  Copyright © 2021 Razeware. All rights reserved.
/***
 1、创建Core Data Stack
 2、创建托管对象模型：1对多、1对1关系
 3、生成托管对象子类
 */

import Foundation
import CoreData

class CoreDataStack {

  private let modelName: String

  init(modelName:String) {
    self.modelName = modelName
  }

  // MARK: - Core Data stack
  //持久化容器 As of iOS 10, there's a new class to orchestrate all four Core Data stack classes: the managed model, the store coordinator, the persistent store and the managed context.
  private lazy var storeContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: self.modelName)
    container.loadPersistentStores { (storeDescription, error) in
      if let error = error as NSError?{
        print("Unresolved error \(error), \(error.userInfo)")
      }
    }
    return container
  }()

  //托管对象上下文
  lazy var managedContext:NSManagedObjectContext = {
    return self.storeContainer.viewContext
  }()


  // MARK: - Core Data Saving support
  func saveContext(){
    //上下文有变动则更新
    guard managedContext.hasChanges else {
      return
    }
    do{
      try managedContext.save()
    }catch let error as NSError{
      print("Unresolved error \(error), \(error.userInfo)")
    }
  }

}
