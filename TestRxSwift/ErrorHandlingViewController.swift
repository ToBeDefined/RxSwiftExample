//
//  ErrorHandlingViewController.swift
//  TestRxSwift
//
//  Created by 邵伟男 on 2017/12/15.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class ErrorHandlingViewController: TViewController {
    // MARK: retry
    @IBAction func testRetry() {
        getDictObservable()
            .retry(3)   // 总共调用3次包括第一次
            .subscribe({ (e) in
                print("in the end: \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: retryWhen
    @IBAction func testRetryWhen() {
        let retryDelay: RxTimeInterval = 1.0
        getDictObservable()
            .retryWhen({ (rxError) -> Observable<Int> in
                return rxError.flatMap({ (e) -> Observable<Int> in
                    return Observable.timer(retryDelay, scheduler: MainScheduler.instance)
                })
            })
            .subscribe({ (e) in
                print("in the end: \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: retryWhen + MaxRetry
    @IBAction func testRetryWhenAndMaxRetry() {
        let retryDelay: RxTimeInterval = 1.0
        let maxRetryCount: Int = 4
        getDictObservable()
            .retryWhen({ (rxError) -> Observable<Int> in
                return rxError.enumerated().flatMap({ (index, element) -> Observable<Int> in
                    if index >= maxRetryCount {
                        let err = TError.init(errorCode: 0, errorString: "Retry Too Many Times", errorData: nil)
                        return Observable.error(err)
                    }
                    return Observable.timer(retryDelay, scheduler: MainScheduler.instance)
                })
            })
            .subscribe({ (e) in
                print("in the end: \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: catchError
    @IBAction func testCatchError() {
        let defaultDict = ["isSuccess": false]
        getDictObservable()
            .catchErrorJustReturn(defaultDict)
            .subscribe ({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
}

extension ErrorHandlingViewController {
    // MARK: getJSONObservable() -> Observable<[AnyHashable: Any]>
    func getDictObservable() -> Observable<[AnyHashable: Any]> {
        return Observable<[AnyHashable: Any]>.create({ (observer) -> Disposable in
            let randomValue = Int(arc4random() % 6)
            if randomValue == 0 {
                print("on Next")
                observer.on(.next(["isSuccess": true]))
            } else {
                print("on Error")
                let err = TError.init(errorCode: 0, errorString: "random value is \(randomValue)", errorData: nil)
                observer.on(.error(err))
            }
            return Disposables.create()
        })
    }
}







