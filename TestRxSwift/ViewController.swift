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
    
    @IBAction func runTestClicked(_ sender: UIButton) {
        self.test()
    }
}


extension ViewController {
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
    func test() {
        testObservable()
    }
}

extension ViewController {
    func testObservable() {
        let baiduStr = "http://www.baidu.com/"
        let githubStr = "https://api.github.com/"
        
        func getObservable(with url: String) -> Observable<JSON> {
            return Observable<JSON>.create { (observer) -> Disposable in
                guard let url = URL.init(string: githubStr) else {
                    let err = TError.init(errorCode: 10, errorString: "url error", errorData: nil)
                    observer.onError(err)
                    return Disposables.create()
                }
                let request = URLRequest.init(url: url)
                let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                    if let err = error {
                        observer.onError(err)
                        return
                    }
                    
                    guard let jsonData = data, let jsonObj = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) else {
                        let err = TError.init(errorCode: 11, errorString: "json error", errorData: data)
                        observer.onError(err)
                        return
                    }
                    // 测试多个事件
                    observer.onNext(1234)
                    observer.onNext(jsonObj)
                    observer.onCompleted()
                })
                task.resume()
                return Disposables.create {
                    task.cancel()
                }
            }
        }
        
        getObservable(with: githubStr).subscribe(onNext: { (jsonObj) in
            print("Get JSON success")
            if jsonObj is Int {
                print(jsonObj)
                return
            }
            guard JSONSerialization.isValidJSONObject(jsonObj) else { return }
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj, options: .prettyPrinted) {
                let jsonStr = String.init(data: jsonData, encoding: String.Encoding.utf8)
                print(jsonStr ?? "")
            }
        }, onError: { (error) in
            if let error = error as? TError {
                error.printLog()
            } else {
                print(error.localizedDescription)
            }
        }, onCompleted: {
            print("completed")
        }).disposed(by: disposeBag)
        
//        getObservable(with: githubStr).asSingle().subscribe(onSuccess: { (jsonObj) in
//            print("Get JSON success")
//            if jsonObj is Int {
//                print(jsonObj)
//                return
//            }
//            guard JSONSerialization.isValidJSONObject(jsonObj) else {
//                return
//            }
//            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj, options: .prettyPrinted) {
//                let jsonStr = String.init(data: jsonData, encoding: String.Encoding.utf8)
//                print(jsonStr ?? "")
//            }
//        }, onError: nil).disposed(by: disposeBag)

    }
    
    func testSingle() {
        func getRepo(_ repo: String) -> Single<[String: Any]> {
            return Single<[String: Any]>.create { (single) -> Disposable in
                guard let url = URL.init(string: "https://api.github.com/repos/\(repo)") else {
                    let err = TError.init(errorCode: 10, errorString: "url error", errorData: nil)
                    single(.error(err))
                    return Disposables.create()
                }
                let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    if error != nil {
                        let err = TError.init(errorCode: 20, errorString: "request error", errorData: data)
                        single(.error(err))
                        return
                    }
                    guard let jsonData = data,
                        let jsonObj = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves),
                        let result = jsonObj as? [String: Any] else {
                            let err = TError.init(errorCode: 30, errorString: "json error", errorData: data)
                            single(.error(err))
                            return
                    }
                    single(.success(result))
                })
                task.resume()
                return Disposables.create {
                    task.cancel()
                }
            }
        }
        
        getRepo("ReactiveX/RxSwift").subscribe(onSuccess: { (dict) in
            print(dict)
        }, onError: { (error) in
            guard let err = error as? TError else {
                print(error.localizedDescription)
                return
            }
            err.printLog()
        }).disposed(by: disposeBag)
    }
}

