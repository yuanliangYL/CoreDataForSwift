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
  fileprivate let teamCellIdentifier = "teamCellReuseIdentifier"
  var coreDataStack: CoreDataStack!

  // MARK: - IBOutlets
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var addButton: UIBarButtonItem!


  //第一步：使用NSFetchRequest声明指定的NSFetchedResultsController（查询请求控制器变量）
  lazy var fetchRequestController :NSFetchedResultsController<Team> = {
    //1
    let fetchRequest :NSFetchRequest<Team> = Team.fetchRequest()
    //第五步：补全fetchRequestController需要排序的要求
    let sort = NSSortDescriptor(key: #keyPath(Team.teamName), ascending: true)
    //第七步：补全全部排序
    let zoneSort = NSSortDescriptor(key: #keyPath(Team.qualifyingZone), ascending: true)
    let scoreSort = NSSortDescriptor(key: #keyPath(Team.wins), ascending: false)


    //添加多个排序规则，确保数据准确性
    //you added three sort descriptors: first sort by qualifying zone, then by number of wins, then finally by name.:排序参数顺序有影响
    fetchRequest.sortDescriptors = [zoneSort ,scoreSort,sort]
    //2
    /*
     first up, the fetch request you just created.
     The second parameter is an instance of NSManagedObjectContext
     sectionNameKeyPath:分区设置字段(optional可选字段)
     cacheName:缓存数据
     */
    let fetchRequestController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                            managedObjectContext: coreDataStack.managedContext,
                                                            sectionNameKeyPath: #keyPath(Team.qualifyingZone), //第六步：实现分区
                                                            cacheName: "worldCup")
    fetchRequestController.delegate = self

    return fetchRequestController
  }()


  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    //第二步：使用fetchRequestController进行查询操作
    do {
      //“NSFetchedResultsController is both a wrapper around a fetch request and a container for its fetched results. dosen't return result
      try fetchRequestController.performFetch()
    }catch let  error as NSError {
      print("Fetching error: \(error), \(error.userInfo)")
    }
  }



  //重写系统事件方法
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    //系统事件
    if motion == .motionShake {
      addButton.isEnabled = true
    }

  }

}

// MARK: - Internal
extension ViewController {

  func configure(cell: UITableViewCell, for indexPath: IndexPath) {
    guard let cell = cell as? TeamCell else {
      return
    }

//    cell.flagImageView.backgroundColor = .blue
//    cell.teamLabel.text = "Team Name"
//    cell.scoreLabel.text = "Wins: 0"

    //第四步：通过fetchRequestController.object获取指定数据，没有使用额外的数组来存储查询结果
    let team = fetchRequestController.object(at: indexPath)

    cell.teamLabel.text = team.teamName
    cell.scoreLabel.text = "Wins: \(team.wins)"

    if let imageName = team.imageName{
      cell.flagImageView.image = UIImage(named: imageName)
    }else{
      cell.flagImageView.backgroundColor = .blue
    }
  }

}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
//    return 1

    //第三步：将fetchRequestController与tableview的datasource进行绑定
    return fetchRequestController.sections?.count ?? 0
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return 20

    //第三步：........
    guard let sectionInfo = fetchRequestController.sections?[section] else {
      return 0
    }
    return sectionInfo.numberOfObjects
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: teamCellIdentifier, for: indexPath)
    configure(cell: cell, for: indexPath)
    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //return "section \(section)"

    let  sectionInfo = fetchRequestController.sections?[section]

    return sectionInfo?.name
  }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    //第六步：数据变更
    let team = fetchRequestController.object(at: indexPath)
    team.wins = team.wins + 1
    coreDataStack.saveContext()

    //tableView.reloadData()
  }
}


//监听变动
// MARK: - NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {


  //“This delegate method notifies you that changes are about to occur. ”
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }


  //for raw
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                  didChange anObject: Any,
                  at indexPath: IndexPath?,
                  for type: NSFetchedResultsChangeType,
                  newIndexPath: IndexPath?) {

    switch type {
    case .insert:
      tableView.insertRows(at: [newIndexPath!], with: .automatic)
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .automatic)
    case .update:
      let cell = tableView.cellForRow(at: indexPath!) as! TeamCell
      configure(cell: cell, for: indexPath!)
    case .move:
      tableView.deleteRows(at: [indexPath!], with: .automatic)
      tableView.insertRows(at: [newIndexPath!], with: .automatic)
    }
  }


  //for section
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    let  indexset = IndexSet(integer: sectionIndex)

    switch type {
    case .insert:
      tableView.insertSections(indexset, with: .automatic)

    case .delete:
      tableView.deleteSections(indexset, with: .automatic)
    default:
      break
    }

  }


  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//    tableView.reloadData()
    tableView.endUpdates()
  }



}

// MARK: - IBActions
extension ViewController {
    @IBAction func addTeam(_ sender: UIBarButtonItem) {

        let alertController = UIAlertController(title: "Add Team", message: "Secret Team is coming", preferredStyle: .alert)

        alertController.addTextField{ textFiled in
            textFiled.placeholder = "team name"
        }

        alertController.addTextField { (textField) in
            textField.placeholder = "qualifying Zone"
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in

            guard let name = alertController.textFields?.first,
            let zoen = alertController.textFields?.last else{
                return
            }

            let team = Team(context: self.coreDataStack.managedContext)

            team.teamName = name.text
            team.qualifyingZone = zoen.text
            team.wins = 0
            team.imageName = "wenderland-flag"

          self.coreDataStack.saveContext()

        }

      alertController.addAction(saveAction)
      alertController.addAction(UIAlertAction(title: "cancle", style: .cancel, handler: nil))
      present(alertController, animated: true, completion: nil)
    }
}


