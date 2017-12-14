//
//  Observer&ObservableViewController.swift
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

class Observer_ObservableViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.frame = CGRect.init(x: 100, y: 250, width: 100, height: 100)
        self.view.addSubview(imgView)
        return imgView
    }()
}

// MARK: getImage() -> Observable<UIImage>
extension Observer_ObservableViewController {
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
}

// MARK: Test
extension Observer_ObservableViewController {
    // MARK: AsyncSubject
    @IBAction func testAsyncSubject() {
        let subject = AsyncSubject<String>()
        
        subject.subscribe({ (e) in
            print("Subscription: 1 Event:", e)
        }).disposed(by: disposeBag)
        // 1
        subject.onNext("🐶")
        subject.onNext("🐱")
        // 只发送 onCompleted前面最后一个
        subject.onNext("🐹")
        subject.onCompleted()
    }
    
    // MARK: PublishSubject
    @IBAction func testPublishSubject() {
        let disposeBag = DisposeBag()
        let subject = PublishSubject<String>()
        
        subject.subscribe({ (e) in
            print("Subscription: 1 Event:", e)
        }).disposed(by: disposeBag)
        
        subject.onNext("🐶")
        subject.onNext("🐱")
        
        subject.subscribe({ (e) in
            print("Subscription: 2 Event:", e)
        }).disposed(by: disposeBag)
        
        subject.onNext("🅰️")
        subject.onNext("🅱️")
        subject.onCompleted()
    }
    
    // MARK: ReplaySubject
    @IBAction func testReplaySubject() {
        // let subject = ReplaySubject<String>.createUnbounded()
        let subject = ReplaySubject<String>.create(bufferSize: 1)
        
        subject
            .subscribe { print("Subscription: 1 Event:", $0) }
            .disposed(by: disposeBag)
        
        subject.onNext("🐶")
        subject.onNext("🐱")
        
        subject
            .subscribe { print("Subscription: 2 Event:", $0) }
            .disposed(by: disposeBag)
        
        subject.onNext("🅰️")
        subject.onNext("🅱️")
    }
    
    // MARK: BehaviorSubject
    @IBAction func testBehaviorSubject() {
        let subject = BehaviorSubject(value: "🔴")
        
        subject
            .subscribe { print("Subscription: 1 Event:", $0) }
            .disposed(by: disposeBag)
        
        subject.onNext("🐶")
        subject.onNext("🐱")
        
        subject
            .subscribe { print("Subscription: 2 Event:", $0) }
            .disposed(by: disposeBag)
        
        subject.onNext("🅰️")
        subject.onNext("🅱️")
        
        subject
            .subscribe { print("Subscription: 3 Event:", $0) }
            .disposed(by: disposeBag)
        
        subject.onNext("🍐")
        subject.onNext("🍊")
    }
    
    // MARK: Variable
    @IBAction func testVariable() {
        struct Model {
            var text: String?
            var image: UIImage?
        }
        
        func updateView(with model: Model?) {
            guard let m = model else { return }
            DispatchQueue.main.async {
                self.imageView.image = m.image
                print(m.text ?? "none")
            }
        }
        
        let model: Variable<Model?> = Variable.init(nil)
        
        model
            .asObservable()
            .subscribe(onNext: { (m) in
                updateView(with: m)
            })
            .disposed(by: disposeBag)
        
        getImage()
            .subscribe(onNext: { (image) in
                model.value = Model.init(text: image.description, image: image)
            }, onError: { (err) in
                if let err = err as? TError {
                    err.printLog()
                    return
                }
                print(err.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: ControlProperty
    @IBAction func testControlProperty() {
        // 仅仅用于测试，主要用于UI控件，例如 textField.rx.text
        
        // Creat:
        var c_value: String = ""
        let c_observable = Observable<String>.create({ (observer) -> Disposable in
            observer.onNext(c_value)
            observer.onCompleted()
            return Disposables.create()
        })
        let c_observer = AnyObserver<String>.init { (e) in
            switch e {
            case .next(let el):
                c_value = el
            default:
                break
            }
            print("controlProperty is Changed: " + e.debugDescription)
        }
        let controlProperty = ControlProperty<String>.init(values: c_observable, valueSink: c_observer)
        
        
        // USE:
        
        let observable = Observable<String>.create({ (observer) -> Disposable in
            observer.onNext("测试1")
            observer.onNext("测试2")
            observer.onCompleted()
            return Disposables.create()
        })
        
        let observer = AnyObserver<String>.init { (e) in
            print("controlProperty Value Is: " + e.debugDescription)
        }
        
        
        observable.bind(to: controlProperty).disposed(by: disposeBag)
        
        controlProperty.bind(to: observer).disposed(by: disposeBag)
    }
}








