//
//  CommonType.swift
//  TestRxSwift
//
//  Created by 邵伟男 on 2017/12/14.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SDWebImage

typealias JSON = Any

struct TError: Error {
    var errorCode: Int = 0
    var errorString: String = ""
    var errorData: Any?
    
    func printLog() {
        print(errorCode)
        print(errorString)
        if let data = errorData as? Data {
            let str = String.init(data: data, encoding: String.Encoding.utf8)
            print(str ?? "NULL Error Data")
        }
    }
}

class TViewController: UIViewController {
    deinit {
        print("Deinit:" + self.debugDescription)
    }
}

