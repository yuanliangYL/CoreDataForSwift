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

  // MARK: - IBOutlets
  @IBOutlet weak var segmentedControl: UISegmentedControl!

  @IBOutlet weak var imageView: UIImageView!

  @IBOutlet weak var nameLabel: UILabel!

  @IBOutlet weak var ratingLabel: UILabel!

  @IBOutlet weak var timesWornLabel: UILabel!

  @IBOutlet weak var lastWornLabel: UILabel!

  @IBOutlet weak var favoriteLabel: UILabel!

  // MARK: - Properties
  var managedContext: NSManagedObjectContext!

  var currentBowtie: Bowtie!
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    //1:插入数据
    insertSameData()

    featchSpecificData(selectedTitle: "R")

  }

  func featchSpecificData(selectedTitle: String){
    //2查询数据
    let request: NSFetchRequest<Bowtie> = Bowtie.fetchRequest()
    //let firstTitle = segmentedControl.titleForSegment(at: index)!

    //在oc里，kvc的key和key path都是字符串，那么就难免出现写错的情况。
    //swift中可以使用#keyPath来指定key和keypath，能够在编译时就检查出错误。
    //过滤查询：谓词匹配，查询符合条件的k_v
    request.predicate = NSPredicate(format: "%K=%@", argumentArray: [#keyPath(Bowtie.searchKey),selectedTitle])
    //    request.predicate = NSPredicate(format: "searchKey == %@", firstTitle)

    do{
      //3执行查询
      let results = try managedContext.fetch(request)

      //4得到结果
      currentBowtie = results.first
      populate(bowtie:  results.first!)

    }catch let error as NSError{
      print("Could not fetch \(error), \(error.userInfo)")
    }
  }

  func populate(bowtie: Bowtie){

    guard let iamgeData = bowtie.photoData  as Data?,
          let lastWorn = bowtie.lastWorn,
          let tintColor = bowtie.tintColor as? UIColor
    else {
      return
    }

    imageView.image = UIImage(data: iamgeData)
    nameLabel.text = bowtie.name
    ratingLabel.text = "Rating: \(bowtie.rating)/5"

    timesWornLabel.text = "#Times Worm :\(bowtie.timesWorn)"

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none
    dateFormatter.timeZone = .current

    lastWornLabel.text = "last worm :" + dateFormatter.string(from: lastWorn)

    favoriteLabel.isHidden = !bowtie.isFavorite

    view.tintColor = tintColor
    segmentedControl.backgroundColor = tintColor
    nameLabel.textColor = tintColor
    ratingLabel.textColor = tintColor
    timesWornLabel.textColor = tintColor
    lastWornLabel.textColor = tintColor
    favoriteLabel.textColor = tintColor

  }

  // MARK: - IBActions
  @IBAction func segmentedControl(_ sender: Any) {

    guard let control = sender as? UISegmentedControl,
          let selectedValue = control.titleForSegment(at: control.selectedSegmentIndex) else {
      return
    }

    featchSpecificData(selectedTitle: selectedValue)
  }


  @IBAction func wear(_ sender: Any) {

    let times = currentBowtie.timesWorn
    currentBowtie.timesWorn = times + 1
    currentBowtie.lastWorn = Date()

    do{
      try managedContext.save()
      populate(bowtie: currentBowtie)
    }catch let err as NSError{
      print("Could not save \(err), \(err.userInfo)")
    }
  }


  @IBAction func rate(_ sender: Any) {

    let alert = UIAlertController(title: "New Rating", message: "Rate this bow tie", preferredStyle: .alert)

    alert.addTextField { (textfiled) in
      textfiled.keyboardType = .decimalPad
    }

    let cancle = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)

    let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
      if let textFiled = alert.textFields?.first{
        self.update(Rating:textFiled.text)
      }
    }

    alert.addAction(cancle)
    alert.addAction(saveAction)

    present(alert, animated: true, completion: nil)

  }

  func update(Rating:String?){

    guard let ratingString = Rating,
          let rating = Double(ratingString)
    else {
      return
    }


    //方式一：通过代码逻辑控制数据有效性
//    if rating > 5 {
//      print("rating number is too large!")
//      return
//    }

    //方式二：设置数据类型值的取值范围来控制数据的有效性
    //Minnimum
    //Maxnimun

    do{
      currentBowtie.rating = rating
      currentBowtie.lastWorn = Date()

      try managedContext.save()
      populate(bowtie: currentBowtie)

    }catch let error as NSError{

      if error.domain == NSCocoaErrorDomain &&
            (error.code == NSValidationNumberTooLargeError ||
              error.code == NSValidationNumberTooSmallError) {

            rate(currentBowtie)

          } else {
            print("Could not save \(error), \(error.userInfo)")
          }

    }

  }

  func insertSameData(){

    //数据查询
    let fetch :NSFetchRequest<Bowtie> = Bowtie.fetchRequest()
    fetch.predicate = NSPredicate(format: "searchKey != nil")
    let count = try! managedContext.count(for: fetch)
    if count > 0 {
      print("have data already: SampleData.plist data already in Core Data")
      return
    }

    //读取数据
    let path = Bundle.main.path(forResource: "SampleData", ofType: "plist")

    let dataArr = NSArray(contentsOfFile: path!)!

    for dict in dataArr{

      //初始化实体
      let entity = NSEntityDescription.entity(forEntityName: "Bowtie", in: managedContext)!

      //通过实体初始化托管对象
      let bowtie = Bowtie(entity: entity, insertInto: managedContext)

      //类型转换
      let btDict = dict as! [String :Any]

      bowtie.id = UUID(uuidString: btDict["id"] as! String)
      bowtie.name = btDict["name"] as? String
      bowtie.searchKey = btDict["searchKey"] as? String
      bowtie.rating = btDict["rating"] as! Double

      let colorDict = btDict["tintColor"] as! [String :Any]
      //自定义方法
      bowtie.tintColor = UIColor.color(dict: colorDict)

      let imageName  = btDict["imageName"] as? String
      let image = UIImage(named: imageName!)
      let photoData = UIImagePNGRepresentation(image!)
      bowtie.photoData = NSData(data: photoData!) as Data
      bowtie.lastWorn = btDict["lastWorn"] as? Date


      let timesNumber = btDict["timesWorn"] as! NSNumber
      bowtie.timesWorn = timesNumber.int32Value
      bowtie.isFavorite = btDict["isFavorite"] as! Bool
      bowtie.url = URL(string: btDict["url"] as! String)

    }

    do {

      //执行数据存储
      try managedContext.save()
      print("save successed !")

    } catch let error as NSError {
      print("could not save.\(error),\(error.userInfo)")
    }
  }

}


