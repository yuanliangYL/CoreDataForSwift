/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import CoreData

class ViewController: UIViewController {

  // MARK: - Properties
  private let filterViewControllerSegueIdentifier = "toFilterViewController"
  private let venueCellIdentifier = "VenueCell"

  var coreDataStack: CoreDataStack!

  // MARK: - IBOutlets
  @IBOutlet weak var tableView: UITableView!

  var fetchRequest: NSFetchRequest<Venue>?
  var venues :[Venue] = []

  //异步查询
  var asyncFetchRequest: NSAsynchronousFetchRequest<Venue>?



  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    //Stored fetch requests ：第四种查询方式：存储器查询请求。  GUI-based tool ✨
    ////////attention：“. It turns out if you use that technique, the fetch request becomes immutable.”这种方式获取的fetch是不可变的
//    guard let model = coreDataStack.managedContext.persistentStoreCoordinator?.managedObjectModel,
//          let fetchRequest = model.fetchRequestTemplate(forName: "FetchRequest") as? NSFetchRequest<Venue> else { return  }
//    self.fetchRequest = fetchRequest


    //这种方式设置的fetch 可以实现fetch的动态可变
    let venensFetch: NSFetchRequest<Venue> = Venue.fetchRequest()
    fetchRequest = venensFetch


    ////异步查询请求 a plain old NSFetchRequest and a completion handler.:异步请求只是对不同请求的一次封装操作
    asyncFetchRequest  = NSAsynchronousFetchRequest<Venue>(fetchRequest: venensFetch){ [unowned self] (results :NSAsynchronousFetchResult) in



      guard let venues = results.finalResult else{
        return
      }
      self.venues = venues
      self.tableView .reloadData()
    }
    do {
      guard let asyncFetchRequest = asyncFetchRequest else {
        return
      }
      //it’s execute(_:) instead of the usual fetch(_:).
      try coreDataStack.managedContext.execute(asyncFetchRequest)
      // Returns immediately, cancel here if you want
      //results.cancel() you can cancel the fetch request with NSAsynchronousFetchResult’s cancel() method.

    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }

    //    fetchAndReload()



    // MARK: -- //批量更新 NSBatchUpdateRequest NSBatchUpdateResult
    //You create an instance of NSBatchUpdateRequest”
    let batchUpdates = NSBatchUpdateRequest(entityName: "Venue")

    //更新属性设置
    batchUpdates.propertiesToUpdate = [#keyPath(Venue.favorite):true]
    //设置所需要更新的数据空间
    batchUpdates.affectedStores = coreDataStack.managedContext.persistentStoreCoordinator?.persistentStores
    batchUpdates.resultType = .updatedObjectsCountResultType
    //设置更新条件
    //    batchUpdates.predicate = ....

    do{
    

      let batchResult = try coreDataStack.managedContext.execute(batchUpdates) as! NSBatchUpdateResult
       print("Records updated \(batchResult.result!)")
      } catch let error as NSError {
        print("Could not update \(error), \(error.userInfo)")
      }


    // MARK: -- //批量删除 NSBatchDeleteRequest

    /*
     由于您正在回避NSManagedObjectContext，所以如果使用批处理更新请求或批处理删除请求，您将不会得到任何验证。您的更改也不会反映在托管上下文中。
     在使用持久存储请求之前，请确保正确地清理和验证数据!
     */

  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    guard  segue.identifier == filterViewControllerSegueIdentifier,
      let navi = segue.destination as? UINavigationController,
          let filterVc = navi.topViewController as? FilterViewController else{
      return
    }

    //传递 coreDataStack
    filterVc.coreDataStack = coreDataStack

    filterVc.delegate = self

  }
}

// MARK: - IBActions
extension ViewController {

  ////反向过渡
  /*
   Before you can begin adding unwind segues in Interface Builder, you must define at least one unwind action.

   An unwind action is an instance method with a UIStoryboardSegue as its only parameter and whose return type is IBAction.
   
   Like IBActions and IBOutlets, unwind actions do not need to be declared in your class header file.

   @IBAction  unwindToVenueListViewController(_ segue: UIStoryboardSegue)  {   }

   */
  
  @IBAction
  func unwindToVenueListViewController(_ segue: UIStoryboardSegue) {
    print("反向过渡操作中.....")
  }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return venues.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: venueCellIdentifier, for: indexPath)

    let venes = venues[indexPath.row]

    cell.textLabel?.text = venes.name
    cell.detailTextLabel?.text = venes.priceInfo?.priceCategory

    return cell
  }
}

// MARK: - Helper methods
extension ViewController{

  func fetchAndReload(){
    guard let fetchrequest = fetchRequest else { return  }

    do{

      venues = try coreDataStack.managedContext.fetch(fetchrequest)
      tableView.reloadData()

    }catch let error as NSError{

      print("Could not fetch \(error), \(error.userInfo)")
    }
  }
}


extension ViewController: FilterViewControllerDelegate{

  func filterViewController(filter: FilterViewController, didSelectedPredicate predicate: NSPredicate?, sortDesCription: NSSortDescriptor?) {


    guard let fetchRequest = fetchRequest else {
      return
    }

    //清空旧值
    fetchRequest.predicate = nil
    fetchRequest.sortDescriptors = nil

    if let pre = predicate {
      fetchRequest.predicate = pre
    }

    if let sr = sortDesCription {
      fetchRequest.sortDescriptors = [sr]
    }

    fetchAndReload()
  }

}
