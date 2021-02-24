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


//“This protocol defines a delegate method that will notify the delegate when the user selects a new sort/filter combination.”
//通过协议反向传递筛选条件
protocol FilterViewControllerDelegate: class {

  func filterViewController(filter:FilterViewController, didSelectedPredicate predicate: NSPredicate?, sortDesCription:NSSortDescriptor?)

}

class FilterViewController: UITableViewController {

  @IBOutlet weak var firstPriceCategoryLabel: UILabel!
  @IBOutlet weak var secondPriceCategoryLabel: UILabel!
  @IBOutlet weak var thirdPriceCategoryLabel: UILabel!
  @IBOutlet weak var numDealsLabel: UILabel!

  // MARK: - Price section
  @IBOutlet weak var cheapVenueCell: UITableViewCell!
  @IBOutlet weak var moderateVenueCell: UITableViewCell!
  @IBOutlet weak var expensiveVenueCell: UITableViewCell!

  // MARK: - Most popular section
  @IBOutlet weak var offeringDealCell: UITableViewCell!
  @IBOutlet weak var walkingDistanceCell: UITableViewCell!
  @IBOutlet weak var userTipsCell: UITableViewCell!
  
  // MARK: - Sort section
  @IBOutlet weak var nameAZSortCell: UITableViewCell!
  @IBOutlet weak var nameZASortCell: UITableViewCell!
  @IBOutlet weak var distanceSortCell: UITableViewCell!
  @IBOutlet weak var priceSortCell: UITableViewCell!


  var coreDataStack:CoreDataStack!

  weak var delegate: FilterViewControllerDelegate?
  var selectedSortDescription :NSSortDescriptor?
  var selectedPredicate:NSPredicate?


  //懒加载计算属性
  //描述：价格
  lazy var cheapVenuePredicate: NSPredicate = {
    return NSPredicate(format: "%K = %@", #keyPath(Venue.priceInfo.priceCategory),"$")
  }()

  lazy var moderateVenuePredicate: NSPredicate = {
    return NSPredicate(format: "%K = %@", #keyPath(Venue.priceInfo.priceCategory),"$$")
  }()
  lazy var expensiveVenuePredicate: NSPredicate = {
    return NSPredicate(format: "%K = %@", #keyPath(Venue.priceInfo.priceCategory),"$$$")
  }()

  //about popular
  lazy var offeringDealPredicate: NSPredicate = {
    return NSPredicate(format: "%K > 0",#keyPath(Venue.specialCount))
  }()
  lazy var walkingDistancelPredicate: NSPredicate = {
    return NSPredicate(format: "%K < 500",#keyPath(Venue.location.distance))
  }()
  lazy var hasUserTipsPredicate: NSPredicate = {
    return NSPredicate(format: "%K > 0",#keyPath(Venue.stats.tipCount))
  }()

  //sorting
  lazy var nameSortedDescription: NSSortDescriptor = {

    let compareSelector = #selector(NSString.localizedStandardCompare(_:)) //本地化字符比较排序

    return NSSortDescriptor(key: #keyPath(Venue.name),
                            ascending: true,
                            selector: compareSelector)
  }()
  lazy var distanceSortedDescription: NSSortDescriptor = {
    return NSSortDescriptor(key: #keyPath(Venue.location.distance),
                            ascending: true)
  }()

  lazy var priceeSortedDescription: NSSortDescriptor = {
    return NSSortDescriptor(key: #keyPath(Venue.priceInfo.priceCategory),
                            ascending: true)
  }()


  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    populateCheapVenueCountLabel()

    populateModerateVenueCountLabel()

    populateexpensiveVenueCountLabel()

    populateDealsCountLabel()
    
  }
}

// MARK: - IBActions
extension FilterViewController {

  @IBAction func search(_ sender: UIBarButtonItem) {

    delegate?.filterViewController(filter: self, didSelectedPredicate: selectedPredicate, sortDesCription: selectedSortDescription)

    dismiss(animated: true, completion: nil)

  }
}

// MARK - UITableViewDelegate
extension FilterViewController {

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else {
      return
    }


    switch cell {

    // Price section
    case cheapVenueCell:
      selectedPredicate = cheapVenuePredicate
    case moderateVenueCell:
      selectedPredicate = moderateVenuePredicate
    case expensiveVenueCell:
      selectedPredicate = expensiveVenuePredicate

    // Most Popular section
    case offeringDealCell:
      selectedPredicate = offeringDealPredicate
    case walkingDistanceCell:
      selectedPredicate = walkingDistancelPredicate
    case userTipsCell:
      selectedPredicate = hasUserTipsPredicate

    //Sort By section
    case nameAZSortCell:
      selectedSortDescription = nameSortedDescription
    case nameZASortCell:
      selectedSortDescription = nameSortedDescription.reversedSortDescriptor as? NSSortDescriptor //reversedSortDescriptor 之后为any ,需要转换回来
    case distanceSortCell:
      selectedSortDescription = distanceSortedDescription
    case priceSortCell:
      selectedSortDescription = priceeSortedDescription
    default: break

    }

    cell.accessoryType = .checkmark
  }

}


// MARK: - Helper methods

//Fetching different result types
extension FilterViewController {

  func populateCheapVenueCountLabel(){

    //Fetching different result types
    let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")
    /***resultType
     default value:managedObjectResultType
     countResultType:“ Returns the count of the objects matching the fetch request.”
     dictionaryResultType:“This is a catch-all return type for returning the results of different calculations.”
     managedObjectIDResultType:“ Returns unique identifiers instead of full-fledged managed objects.”
     */
    //返回结果数量
    fetchRequest.resultType = .countResultType
    fetchRequest.predicate = cheapVenuePredicate

    do{

      let countResult = try coreDataStack.managedContext.fetch(fetchRequest)

      let count = countResult.first?.intValue
      let pluralized = count == 1 ? "只有" : "有"

      if let finacount = count{
        firstPriceCategoryLabel.text = "\(pluralized) \(finacount) 家10元奶茶店"
      }

    }catch let error as NSError {
      print("Count not fetch \(error), \(error.userInfo)")
    }
  }

  func populateModerateVenueCountLabel(){

    let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")

    fetchRequest.resultType = .countResultType
    fetchRequest.predicate = moderateVenuePredicate

    do{

      let countResult = try coreDataStack.managedContext.fetch(fetchRequest)

      let count = countResult.first?.intValue
      let pluralized = count == 1 ? "place" : "places"

      if let finacount = count{
        secondPriceCategoryLabel.text = "\(finacount) bubble tea \(pluralized)"
      }

    }catch let error as NSError {
      print("Count not fetch \(error), \(error.userInfo)")
    }
  }

  func populateexpensiveVenueCountLabel(){

    let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")

    fetchRequest.resultType = .countResultType
    fetchRequest.predicate = expensiveVenuePredicate

    do{

      //方式一： coreDataStack.managedContext.fetch(fetchRequest)
//      let countResult = try coreDataStack.managedContext.fetch(fetchRequest)
//
//      let count = countResult.first?.intValue
//      let pluralized = count == 1 ? "place" : "places"
//
//      if let finacount = count{
//       thirdPriceCategoryLabel.text = "\(finacount) bubble tea \(pluralized)"
//      }



      //方式二： coreDataStack.managedContext.count(for: fetchRequest) 直接调用count
      let countResult = try coreDataStack.managedContext.count(for: fetchRequest)
      if countResult == NSNotFound {
        print("no data to show")
      }else{
        let pluralized = countResult == 1 ? "place" : "places"
        thirdPriceCategoryLabel.text = "\(countResult) bubble tea \(pluralized)"
      }



    }catch let error as NSError {
      print("Count not fetch \(error), \(error.userInfo)")
    }
  }
}

// MARK: -- Performing calculations with fetch requests
extension FilterViewController {
  func populateDealsCountLabel() {

    //1 创建查询请求，并设置结果类型为dictionaryResultType
    let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Venue")
    fetchRequest.resultType = .dictionaryResultType


    //统计：表达式的应用
    //2初始化一个名为sumDeals的表达式描述类实例
    let sumExpensiveDesc = NSExpressionDescription()
    sumExpensiveDesc.name = "sumDeals" //作为返回字典的key


    //3给表达式描述实例设置其他表达参数：
    /**
     指定那个属性需要执行计算；
     指定需要计算总和：
     设置计算结果返回类型
     */
    let specialCountExp = NSExpression(forKeyPath: #keyPath(Venue.specialCount))
    sumExpensiveDesc.expression = NSExpression(forFunction: "sum:", arguments: [specialCountExp]) //方法名带冒号
    //更多方法使用count, min, max, average, median, mode, absolute value and many more. For a comprehensive list, check out Apple’s documentation for NSExpression.

    //设置计算结果类型
    sumExpensiveDesc.expressionResultType = .integer32AttributeType

    //4 通过设置propertiesToFetch 属性，执行设置好的表达式描述类实例（可以认定为一种函数式查询条件）
    fetchRequest.propertiesToFetch = [sumExpensiveDesc]


    //5 执行查询
    do{

      //“The result type is an NSDictionary array,”返回类型是一个字典数组
      let results = try coreDataStack.managedContext.fetch(fetchRequest)

      let resultDic = results.first!

      //通过设置的名称得到计算结果
      let numDeals = resultDic["sumDeals"] as! Int

      let pluralized = numDeals == 1 ? "deal" : "deals"

      numDealsLabel.text = "所有店家共卖出 \(numDeals) \(pluralized)"

    }catch let error as NSError {
      print("Count not fetch \(error), \(error.userInfo)")
    }

  }
}
