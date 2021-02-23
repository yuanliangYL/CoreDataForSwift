/// Copyright (c) 2018 Razeware LLC

import UIKit
import CoreData

class ViewController: UIViewController {

  var managedContext : NSManagedObjectContext!

  var currentDog: Dog?


  // MARK: - Properties
  lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    //日期格式
    formatter.dateStyle = .full
    //时间格式
    formatter.timeStyle = .medium
    //本地化地区
    formatter.locale = NSLocale(localeIdentifier: "zh_cn") as Locale //zh_tw, ja_jp
    
    return formatter
  }()

  var walks: [Date] = []

  // MARK: - IBOutlets
  @IBOutlet var tableView: UITableView!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")


    let dogName = "Spark"

    //fetch all Dog entities with names of "Spark" from Core Data
    //设置请求
    let dogFetch: NSFetchRequest<Dog> = Dog.fetchRequest()
    //添加谓词
    dogFetch.predicate = NSPredicate(format: "%K = %@", #keyPath(Dog.name),dogName)

    do{

      //执行查询✨
      let result = try managedContext.fetch(dogFetch)

      if result.count > 0 {

        currentDog = result.first

      }else{

        //If the fetch request comes back with zero results, this probably means it’s the user’s first time opening the app. If this is the case, you insert a new dog, name it “Spark”, and set it as the currently selected dog.
        //新增✨
        currentDog = Dog(context: managedContext)
        currentDog?.name = dogName
        try managedContext.save()
      }

    }catch let error as NSError{
      print("Fetch error: \(error) description: \(error.userInfo)")
    }
  }
}

// MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return walks.count
    return currentDog?.walks?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    //let date = walks[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

    guard let walk = currentDog?.walks?[indexPath.row] as? Walk,
          let walkDate = walk.date as Date?
          else {
      return cell
    }

    cell.textLabel?.text = dateFormatter.string(from: walkDate)
    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "List of Walks"
  }

  //开启cell可编辑
  func tableView(_ tableView: UITableView,
                 canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

    //1
    guard let walkToMoved = currentDog?.walks?[indexPath.row] as? Walk,
          editingStyle == .delete else {
      return
    }
    //2 删除数据 ✨
    managedContext.delete(walkToMoved)

    do{
      //3 保存操作
      try managedContext.save()

      //4 刷新页面
      tableView.deleteRows(at: [indexPath], with: .automatic)

    }catch let error as NSError{
       print("Saving error: \(error),description: \(error.userInfo)")
    }
  }
}



// MARK: - IBActions
extension ViewController {

  @IBAction func add(_ sender: UIBarButtonItem) {
    //walks.append(Date())

    //1. Insert a new Walk entity into Core Data
    let walk = Walk(context: managedContext)
    walk.date = Date()

    //2. Insert the new Walk into the Dog's walks set”
    if let dog = currentDog,
       let walks = dog.walks?.mutableCopy() as? NSMutableOrderedSet //you first have to create a mutable copy (NSMutableOrderedSet)
    {
      walks.add(walk)
      dog.walks = walks
    }

    //3. Save the managed object context
    do{

      try managedContext.save()

    }catch let error as NSError{

      print("Save error: \(error),description: \(error.userInfo)")
    }
    
    //reload
    tableView.reloadData()
  }
}
