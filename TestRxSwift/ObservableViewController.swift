
//  ObservableViewController.swift
//  TestRxSwift
//
//  Created by 邵伟男 on 2017/12/12.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SDWebImage

class ObservableViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    
    @IBAction func runTestClicked(_ sender: UIButton) {
        testObservable()
//        testSingle()
//        testDriver()
//        testControlEvent()
    }
}

extension ObservableViewController {
    func testObservable() {
        let baiduStr = "http://www.baidu.com/"
        let githubStr = "https://api.github.com/"
        
        func getObservable(with url: String) -> Observable<JSON> {
            return Observable<JSON>.create { (observer) -> Disposable in
                guard let url = URL.init(string: url) else {
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
//                    observer.onNext(1234)
                    observer.onNext(jsonObj)
                    observer.onCompleted()
                    // onCompleted之后不运行
                    observer.onNext(2222222)
                    observer.onCompleted()
                })
                task.resume()
                return Disposables.create {
                    task.cancel()
                }
            }
        }
        
        
        
// MARK: Observable
        
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
        
        
        
// MARK: asSingle
        
//        getObservable(with: githubStr).asSingle().subscribe(onSuccess: { (jsonObj) in
//            // 1*onNext + 1*onCompleted
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
//        }, onError: { (error) in
//            // n*onNext + 1*onCompleted || onError
//            if let error = error as? TError {
//                error.printLog()
//            } else {
//                print(error.localizedDescription)
//            }
//        }).disposed(by: disposeBag)
        
        
        
// MARK: asMaybe
        
//        getObservable(with: githubStr).asMaybe().subscribe(onSuccess: { (jsonObj) in
//            // 1*onNext + 1*onCompleted
//            print("Get JSON success")
//            if jsonObj is Int {
//                print(jsonObj)
//                return
//            }
//            guard JSONSerialization.isValidJSONObject(jsonObj) else { return }
//            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj, options: .prettyPrinted) {
//                let jsonStr = String.init(data: jsonData, encoding: String.Encoding.utf8)
//                print(jsonStr ?? "")
//            }
//        }, onError: { (error) in
//            // n*onNext + 1*onCompleted || onError
//            if let error = error as? TError {
//                error.printLog()
//            } else {
//                print(error.localizedDescription)
//            }
//        }, onCompleted: {
//            // 1*onCompleted
//            print("completed")
//        }).disposed(by: disposeBag)

    }
    
// MARK: Single
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
                    // 只会运行第一个single
                    single(.success(["1":2]))
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
    
    func testDriver() {
        let imageView = UIImageView.init(frame: CGRect.init(x: 100, y: 100, width: 100, height: 100))
        self.view.addSubview(imageView)
        func getImage() -> Observable<UIImage> {
            return Observable<UIImage>.create { (observer) -> Disposable in
                let downloadToken = SDWebImageDownloader.shared().downloadImage(
                    with: URL.init(string: "https://avatars1.githubusercontent.com/u/11990850"),
                    options: SDWebImageDownloaderOptions.highPriority,
                    progress: nil,
                    completed: { (image, data, error, finished) in
                        if let img = image {
                            observer.onNext(img)
                            observer.onCompleted()
                            return
                        }
                        if let err = error {
                            observer.onError(err)
                            return
                        }
                        observer.onError(TError.init(errorCode: 10, errorString: "UNKNOW ERROR", errorData: data))
                    }
                )
                return Disposables.create {
                    SDWebImageDownloader.shared().cancel(downloadToken)
                }
            }
        }
        
        
        getImage().asDriver(onErrorJustReturn: #imageLiteral(resourceName: "placeholderImg"))
            .drive(imageView.rx.image)
            .disposed(by: disposeBag)
    }
    
    func testControlEvent() {
        let btn = UIButton.init(frame: CGRect.init(x: 100, y: 250, width: 200, height: 60))
        btn.backgroundColor = UIColor.brown
        btn.setTitle("Control Event", for: UIControlState.normal)
        self.view.addSubview(btn)
        
        // extension Reactive where Base: UIButton {
        //
        //     /// Reactive wrapper for `TouchUpInside` control event.
        //     public var tap: ControlEvent<Void> {
        //         return controlEvent(.touchUpInside)
        //     }
        // }
        btn.rx.tap.subscribe(onNext: { [weak self] in
            let ac = UIAlertController.init(title: "TEST TAP(touchUpInside)", message: "testControlEvent", preferredStyle: UIAlertControllerStyle.alert)
            ac.addAction(UIAlertAction.init(title: "确定", style: UIAlertActionStyle.cancel, handler: nil))
            self?.present(ac, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        btn.rx.controlEvent(UIControlEvents.touchDragExit).subscribe(onNext: { [weak self] in
            let ac = UIAlertController.init(title: "TEST touchDragExit", message: "testControlEvent", preferredStyle: UIAlertControllerStyle.alert)
            ac.addAction(UIAlertAction.init(title: "确定", style: UIAlertActionStyle.cancel, handler: nil))
            self?.present(ac, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
}

