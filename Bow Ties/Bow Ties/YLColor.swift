//
//  YLColor.swift
//  Bow Ties
//
//  Created by AlbertYuan on 2021/2/22.
//  Copyright © 2021 Razeware. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

  static func color(dict: [String : Any]) -> UIColor? {

    guard let red = dict["red"] as? NSNumber,
      let green = dict["green"] as? NSNumber,
      let blue = dict["blue"] as? NSNumber else {
        return nil
    }

    return UIColor(red: CGFloat(truncating: red) / 255.0,
                   green: CGFloat(truncating: green) / 255.0,
                   blue: CGFloat(truncating: blue) / 255.0,
                   alpha: 1)
  }

}
