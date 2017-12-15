
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

class ObservableViewController: TViewController {
    private let disposeBag = DisposeBag()
    
    let baiduStr = "http://www.baidu.com/"
    let githubStr = "https://api.github.com/"
    
    lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.frame = CGRect.init(x: 100, y: 250, width: 100, height: 100)
        self.view.addSubview(imgView)
        return imgView
    }()
    
    lazy var btn: UIButton = {
        let btn = UIButton.init(frame: CGRect.init(x: 100, y: 250, width: 200, height: 60))
        btn.backgroundColor = UIColor.brown
        btn.setTitle("Control Event", for: UIControlState.normal)
        self.view.addSubview(btn)
        return btn
    }()
}

extension ObservableViewController {
    // MARK: getObservable(with:) -> Observable<JSON>
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
                // observer.onNext(1234)
                observer.onNext(jsonObj)
                observer.onCompleted()
                // onCompleted之后不发送
                observer.onNext(2222222)
                observer.onCompleted()
            })
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    // MARK: getRepo(_:) -> Single<[String: Any]>
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
    
    // MARK: getCompletable() -> Completable
    func getCompletable() -> Completable {
        return Completable.create { (completable) -> Disposable in
            guard let url = URL.init(string: "http://www.baidu.com/") else {
                completable(.error(TError.init(errorCode: 10, errorString: "url error", errorData: nil)))
                return Disposables.create()
            }
            let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if let errInfo = error {
                    completable(.error(errInfo))
                } else {
                    completable(.completed)
                }
            })
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func getMaybe() -> Maybe<Data> {
        return Maybe.create { (maybe) -> Disposable in
            guard let url = URL.init(string: "http://www.baidu.com/") else {
                maybe(.error(TError.init(errorCode: 10, errorString: "url error", errorData: nil)))
                return Disposables.create()
            }
            let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if let errInfo = error {
                    maybe(.error(errInfo))
                    return
                }
                if let data = data {
                    maybe(.success(data))
                    return
                }
                // 无错误也无数据返回
                maybe(.completed)
            })
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

// MARK: Test
extension ObservableViewController {
    // MARK: Observable
    @IBAction func testObservable() {
        getObservable(with: githubStr)
            .subscribe(onNext: { (jsonObj) in
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
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Single
    @IBAction func testSingle() {
        getRepo("ReactiveX/RxSwift")
            .subscribe(onSuccess: { (dict) in
                print(dict)
            }, onError: { (error) in
                guard let err = error as? TError else {
                    print(error.localizedDescription)
                    return
                }
                err.printLog()
            })
            .disposed(by: disposeBag)
    }
        
    // MARK: asSingle
    @IBAction func testObservableAsSingle() {
        getObservable(with: githubStr)
            .asSingle()
            .subscribe(onSuccess: { (jsonObj) in
                // 1*onNext + 1*onCompleted
                print("Get JSON success")
                if jsonObj is Int {
                    print(jsonObj)
                    return
                }
                guard JSONSerialization.isValidJSONObject(jsonObj) else {
                    return
                }
                if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj, options: .prettyPrinted) {
                    let jsonStr = String.init(data: jsonData, encoding: String.Encoding.utf8)
                    print(jsonStr ?? "")
                }
            }, onError: { (error) in
                // n*onNext + 1*onCompleted || onError
                if let error = error as? TError {
                    error.printLog()
                } else {
                    print(error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Completable
    @IBAction func testCompletable() {
        getCompletable()
            .subscribe(onCompleted: {
                print("Completable onCompleted")
            }, onError: { (error) in
                if let err = error as? TError {
                    err.printLog()
                    return
                }
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Maybe
    @IBAction func testMaybe() {
        getMaybe()
            .subscribe(onSuccess: { (data) in
                print(data.debugDescription)
            }, onError: { (err) in
                if let err = err as? TError {
                    err.printLog()
                    return
                }
                print(err.localizedDescription)
            }, onCompleted: {
                print("Completed With No Data")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: asMaybe
    @IBAction func testObservableAsMaybe() {
        getObservable(with: githubStr)
            .asMaybe()
            .subscribe(onSuccess: { (jsonObj) in
                // 1*onNext + 1*onCompleted
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
                // n*onNext + 1*onCompleted || onError
                if let error = error as? TError {
                    error.printLog()
                } else {
                    print(error.localizedDescription)
                }
            }, onCompleted: {
                // 1*onCompleted
                print("completed")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Driver
    @IBAction func testObservableAsDriver() {
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
        
        getImage()
            .asDriver(onErrorJustReturn: #imageLiteral(resourceName: "placeholderImg"))
            .drive(self.imageView.rx.image)
            .disposed(by: disposeBag)
    }
    
    // MARK: ControlEvent
    @IBAction func testControlEvent() {
        // extension Reactive where Base: UIButton {
        //
        //     /// Reactive wrapper for `TouchUpInside` control event.
        //     public var tap: ControlEvent<Void> {
        //         return controlEvent(.touchUpInside)
        //     }
        // }
        self.btn.rx.tap
            .subscribe(onNext: { [weak self] in
                let ac = UIAlertController.init(title: "TEST TAP(touchUpInside)", message: "testControlEvent", preferredStyle: UIAlertControllerStyle.alert)
                ac.addAction(UIAlertAction.init(title: "确定", style: UIAlertActionStyle.cancel, handler: nil))
                self?.present(ac, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        self.btn.rx.controlEvent(UIControlEvents.touchDragExit)
            .subscribe(onNext: { [weak self] in
                let ac = UIAlertController.init(title: "TEST touchDragExit", message: "testControlEvent", preferredStyle: UIAlertControllerStyle.alert)
                ac.addAction(UIAlertAction.init(title: "确定", style: UIAlertActionStyle.cancel, handler: nil))
                self?.present(ac, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

