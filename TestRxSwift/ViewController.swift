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
    let _val: String = ""
    let val: String = "1"
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textField2: UITextField!
    
    var subscription:Disposable?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
// MARK: 3
        class TestClass: ReactiveCompatible {
            var name: String?
        }
        
        func creatMyObservable(_ obj: AnyObject) -> Observable<String?> {
            return Observable.create({ (obs) -> Disposable in
                obs.onNext(obj.description)
                obs.onCompleted()
                return Disposables.create()
            })
        }
        _ = creatMyObservable(TestClass()).subscribe({ (event) in
            switch event{
            case .next(let e):
                print(e ?? "NULL")
            case .completed:
                print("Completed")
            case .error(let error):
                print(error)
            }
        })
        
    }
    
    @IBAction func beginBtnClicked(_ sender: UIButton) {
        self.subscription?.dispose()
// MARK: 1
//        self.subscription = self.textField.rx.text.map({$0}).subscribe { event in
//            switch event {
//            case .next(let str):
//                print(str ?? "")
//            default:
//                break
//            }
//        }
        
// MARK: 2
        if let t1 = self.textField, let t2 = self.textField2 {
            let o1 = t1.rx.text.map({ ($0 ?? "") })
            let o2 = t2.rx.text.map({ ($0 ?? "") }).filter({ $0.count >= 3})
            self.subscription = Observable.combineLatest(o1, o2, resultSelector: { (os1, os2) -> (String, Int, Int) in
                return ("F: " + os1 + "  S: " + os2, os1.count, os2.count)
            }).subscribe({ e in
                switch e {
                case .next(let el):
                    print(el)
                default:
                    break
                }
            })
        }
    }
    
    
    
    @IBAction func cancelBtnClicked(_ sender: UIButton) {
        self.subscription?.dispose()
    }
}

