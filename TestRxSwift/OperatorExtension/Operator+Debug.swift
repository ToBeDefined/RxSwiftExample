//
//  Operator+Debug.swift
//  TestRxSwift
//
//  Created by 邵伟男 on 2017/12/26.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxSwift

// Debug
extension Operator {
    
    // 打印所有的订阅，事件以及销毁信息
    @objc
    func debug() {
        // identifier: 描述， trimOutput: 是否截取最多四十个字符
        getFirstObservable()
            .debug("Test Debug", trimOutput: true)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // 当 Observable 产生某些事件时，执行某个操作
    // 当 Observable 的某些事件产生时，你可以使用 do 操作符来注册一些回调操作。
    // 这些回调会被单独调用，它们会和 Observable 原本的回调分离。
    @objc
    func `do`() {
        let observable = Observable<String>.create({ (observer) -> Disposable in
            delayTime(1, block: {
                observer.onNext("1️⃣")
            })
            
            delayTime(2, block: {
                observer.onNext("2️⃣")
            })
            
            delayTime(3, block: {
                observer.onNext("3️⃣")
            })
            return Disposables.create()
        })
        
        observable
            .do(onNext: { (str) in
                print("do --> " + str)
            }, onError: { (error) in
                print("do --> ")
                error.printLog()
            }, onCompleted: {
                print("do --> onCompleted")
            }, onSubscribe: {
                print("do --> onSubscribe")
            }, onSubscribed: {
                print("do --> onSubscribed")
            }, onDispose: {
                print("do --> onDispose")
            })
            .subscribe({ (e) in
                print("in subscribe --> \(e)")
            })
            .disposed(by: disposeBag)
    }
}
