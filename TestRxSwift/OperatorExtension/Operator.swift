//
//  Operator.swift
//  TestRxSwift
//
//  Created by TBD on 2017/12/26.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxSwift

// Create Observable
class Operator: NSObject {
    let disposeBag = DisposeBag()
    deinit {
        print("Deinit: Operator")
    }
    
    func getFirstObservable() -> Observable<String> {
        return Observable<String>.create({ (observer) -> Disposable in
            // section 1
            delayTime(1, block: {
                observer.onNext("First -> 1|A")
                observer.onNext("First -> 1|B")
                observer.onNext("First -> 1|C")
            })
            
            // section 2
            delayTime(5, block: {
                observer.onNext("First -> 2|A")
                observer.onNext("First -> 2|B")
                observer.onNext("First -> 2|C")
            })
            
            // section 3
            delayTime(9, block: {
                observer.onNext("First -> 3|A")
                observer.onNext("First -> 3|B")
                observer.onNext("First -> 3|C")
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    func getSecondObservable() -> Observable<String> {
        return Observable<String>.create({ (observer) -> Disposable in
            delayTime(0.1, block: {
                observer.onNext("Second -> 1")
                
                delayTime(4, block: {
                    observer.onNext("Second -> 2")
                })
                
                delayTime(8, block: {
                    observer.onNext("Second -> 3")
                    observer.onCompleted()
                })
            })
            return Disposables.create()
        })
    }
    
    func getThirdObservable() -> Observable<String> {
        return Observable<String>.create({ (observer) -> Disposable in
            delayTime(0.1, block: {
                observer.onNext("Third -> 1")
                observer.onNext("Third -> 2")
                observer.onNext("Third -> 3")
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    func getFourthObservable() -> Observable<String> {
        let observable = Observable<String>.create({ (observer) -> Disposable in
            print("> Send onNext(\"0️⃣\")")
            observer.onNext("0️⃣")
            
            delayTime(1, block: {
                print("> Send onNext(\"1️⃣\")")
                observer.onNext("1️⃣")
            })
            
            delayTime(2, block: {
                print("> Send onNext(\"2️⃣\")")
                observer.onNext("2️⃣")
            })
            return Disposables.create()
        })
        return observable
    }
    
    func getErrorObservable() -> Observable<String> {
        return Observable<String>.create({ (observer) -> Disposable in
            delayTime(1, block: {
                observer.onNext("1️⃣")
            })
            delayTime(2, block: {
                observer.onNext("2️⃣")
            })
            delayTime(3, block: {
                let err = TError.init(errorCode: 10, errorString: "Test", errorData: nil)
                observer.onError(err)
            })
            return Disposables.create()
        })
    }
}
