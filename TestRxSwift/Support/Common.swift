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
}

extension Error {
    func printLog() {
        if let err = self as? TError {
            print(err.errorCode)
            print(err.errorString)
            if let data = err.errorData as? Data {
                let str = String.init(data: data, encoding: String.Encoding.utf8)
                print(str ?? "NULL Error Data")
            }
        } else {
            print(self.localizedDescription)
        }
    }
}

class TViewController: UIViewController {
    let disposeBag = DisposeBag()
    deinit {
        print("Deinit:" + self.debugDescription)
    }
}

class TTableViewController: UITableViewController {
    let disposeBag = DisposeBag()
    deinit {
        print("Deinit:" + self.debugDescription)
    }
}

func delayTime(_ delayTime: TimeInterval, block: (() -> ())? ) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {
        block?()
    }
}

// getCurrentQueueName() -> String
func getCurrentQueueName() -> String {
    let name = __dispatch_queue_get_label(nil)
    return String.init(cString: name, encoding: .utf8) ?? ""
}

