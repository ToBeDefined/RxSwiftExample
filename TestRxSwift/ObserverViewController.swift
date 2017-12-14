//
//  ObserverViewController.swift
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

class ObserverViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.frame = CGRect.init(x: 100, y: 250, width: 100, height: 100)
        self.view.addSubview(imgView)
        return imgView
    }()
}

// MARK: `getObservable(with:) -> Observable<JSON>` & `getImage() -> Observable<UIImage>`
extension ObserverViewController {
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
                observer.onNext(jsonObj)
                observer.onCompleted()
            })
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
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
extension ObserverViewController {
    
    // MARK: theGeneralPractice
    @IBAction func theGeneralPractice() {
        getObservable(with: "https://api.github.com/")
            .subscribe(onNext: { (jsonObj) in
                print("Get JSON success")
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
    
    // MARK: CreateObserver
    @IBAction func testCreateObserver() {
        let observer: AnyObserver<JSON>  = AnyObserver.init { (event) in
            switch event {
            case .next(let jsonObj):
                print("Get JSON success")
                guard JSONSerialization.isValidJSONObject(jsonObj) else { return }
                if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj, options: .prettyPrinted) {
                    let jsonStr = String.init(data: jsonData, encoding: String.Encoding.utf8)
                    print(jsonStr ?? "")
                }
            case .error(let error):
                if let err = error as? TError {
                    err.printLog()
                } else {
                    print(error.localizedDescription)
                }
            case .completed:
                print("completed")
            }
        }
        getObservable(with: "https://api.github.com/")
            .subscribe(observer)
            .disposed(by: disposeBag)
    }
    
    // MARK: CreateImageViewBinderObserver
    @IBAction func testCreateImageViewBinderObserver() {
        let observer: Binder<UIImage> = Binder.init(imageView) { (imageView, image) in
            imageView.image = image
        }
        
        getImage()
            .asDriver(onErrorJustReturn: #imageLiteral(resourceName: "placeholderImg"))
            .drive(observer)
            .disposed(by: disposeBag)
        // getImage()
        //     .observeOn(MainScheduler.instance)
        //     .bind(to: observer)
        //     .disposed(by: disposeBag)
    }
}









