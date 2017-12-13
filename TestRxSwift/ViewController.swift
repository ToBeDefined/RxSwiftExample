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
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
// MARK: 3
        class TestClass: NSObject {
            @objc var name: String?
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
//        if let t1 = self.textField, let t2 = self.textField2 {
//            let o1 = t1.rx.text.map({ ($0 ?? "") })
//            let o2 = t2.rx.text.map({ ($0 ?? "") }).filter({ $0.count >= 3})
//            self.subscription = Observable.combineLatest(o1, o2, resultSelector: { (os1, os2) -> (String, Int, Int) in
//                return ("F: " + os1 + "  S: " + os2, os1.count, os2.count)
//            }).subscribe({ e in
//                switch e {
//                case .next(let el):
//                    print(el)
//                default:
//                    break
//                }
//            })
//        }
        self.test()
    }
    
    
    
    @IBAction func cancelBtnClicked(_ sender: UIButton) {
        self.subscription?.dispose()
    }
}


extension ViewController {
    func test() {
//        >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        
        typealias JSON = Any
        
        struct MyError: Error {
            var errorCode: Int?
            var errorString: String?
            var errorData: Any?
        }
        
        let json = Observable<JSON>.create { (observer) -> Disposable in
            guard let url = URL.init(string: "http://www.baidu.com/") else {
                observer.onError(MyError.init(errorCode: 10, errorString: "url error", errorData: nil))
                return Disposables.create()
            }
            let request = URLRequest.init(url: url)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if error != nil {
                    observer.onError(error!)
                    return
                }
                
                guard let jsonData = data, let jsonObj = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) else {
                    observer.onError(MyError.init(errorCode: 11, errorString: "json error", errorData: data))
                    return
                }
                observer.onNext(jsonObj)
                observer.onCompleted()
            })
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
        
        json.subscribe(onNext: { (json) in
            print("Json success")
        }, onError: { (error) in
            if let error = error as? MyError {
                print(error.errorCode)
                print(error.errorString)
                print(error.errorData)
            } else {
                print(error.localizedDescription)
            }
        }, onCompleted: {
            print("completed")
        }).disposed(by: disposeBag)
        
        
        
        
//        >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    }
}

