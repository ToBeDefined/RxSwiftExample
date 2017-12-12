//
//  ViewController.swift
//  TestRxSwift
//
//  Created by 邵伟男 on 2017/12/12.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    
    var subscription:Disposable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func beginBtnClicked(_ sender: UIButton) {
        self.subscription?.dispose()
        self.subscription = self.textField.rx.text.subscribe { event in
            switch event {
            case .next(let str):
                print(str ?? "")
            default:
                break
            }
        }
    }
    
    
    @IBAction func cancelBtnClicked(_ sender: UIButton) {
        self.subscription?.dispose()
    }
}

