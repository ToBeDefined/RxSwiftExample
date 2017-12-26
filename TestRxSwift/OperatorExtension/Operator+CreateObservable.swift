//
//  Operator+CreateObservable.swift
//  TestRxSwift
//
//  Created by 邵伟男 on 2017/12/26.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxSwift

extension Operator {
    
    // create 操作符将创建一个 Observable，你需要提供一个构建函数，在构建函数里面描述事件（next，error，completed）的产生过程。
    // 通常情况下一个有限的序列，只会调用一次观察者的 onCompleted 或者 onError 方法。并且在调用它们后，不会再去调用观察者的其他方法。
    @objc
    func create() {
        _ = Observable<String>.create { (observer) -> Disposable in
            observer.onNext("1")
            observer.onNext("2")
            observer.onNext("3")
            observer.onNext("4")
            observer.onNext("5")
            observer.onNext("6")
            observer.onNext("7")
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    
    // 创建一个永远不会发出元素的 Observable
    // never 操作符将创建一个 Observable，这个 Observable 不会产生任何事件。
    @objc
    func never() {
        let observable = Observable<Int>.never()
        observable
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
    
    
    // 创建一个空 Observable
    // empty 操作符将创建一个 Observable，这个 Observable 只有一个完成事件。
    @objc
    func empty() {
        let observable = Observable<String>.empty()
        // 相当于以下代码
        // let observable = Observable<String>.create { observer in
        //     observer.onCompleted()
        //     return Disposables.create()
        // }
        observable
            .debug("Empty")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // 创建 Observable 发出唯一的一个元素
    // just 操作符将某一个元素转换为 Observable。
    @objc
    func just() {
        let justObservable = Observable<String>.just("A String")
        // 相当于：
        // let justObservable = Observable<String>.create { observer in
        //     observer.onNext("A String")
        //     observer.onCompleted()
        //     return Disposables.create()
        // }
        
        justObservable
            .subscribe({ (e) in
                print("just => \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    
    // 创建一个只有 error 事件的 Observable
    // error 操作符将创建一个 Observable，这个 Observable 只会产生一个 error 事件。
    @objc
    func error() {
        let err = TError.init(errorCode: 10, errorString: "test error", errorData: nil)
        let observable = Observable<String>.error(err)
        // 相当于以下代码
        // let err = TError.init(errorCode: 10, errorString: "test error", errorData: nil)
        // let id = Observable<Int>.create { observer in
        //     observer.onError(err)
        //     return Disposables.create()
        // }
        observable
            .subscribe({ (e) in
                print("Error --> \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    
    // 将其他类型或者数据结构转换为 Observable
    // 当你在使用 Observable 时，如果能够直接将其他类型转换为 Observable，这将是非常省事的。from 操作符就提供了这种功能。
    // 将一个数组转换为 Observable
    @objc
    func from() {
        let array = [34, 2, 44, 21, 54]
        let observable = Observable<Int>.from(array)
        // 相当于
        // let observable = Observable<Int>.create { (observer) -> Disposable in
        //     observer.onNext(34)
        //     observer.onNext(2)
        //     observer.onNext(44)
        //     observer.onNext(21)
        //     observer.onNext(54)
        //     observer.onCompleted()
        //     return Disposables.create()
        // }
        observable
            .subscribe({ (e) in
                print("From Array => \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
        
        
        // 将一个可选值转换为 Observable：
        let optionalInt: Int? = 12
        let observableOptional = Observable<Int>.from(optional: optionalInt)
        // 相当于
        // let optionalInt: Int? = 12
        // let observableOptional = Observable<Int>.create { observer in
        //     if let value = optionalInt {
        //         observer.onNext(value)
        //     }
        //     observer.onCompleted()
        //     return Disposables.create()
        // }
        observableOptional
            .subscribe({ (e) in
                print("From Optional => \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    
    // of 操作符将某一个元素或多个元素转换为 Observable。
    @objc
    func of() {
        let ofObservable = Observable.of(1, 2, 3)
        // let ofObservable = Observable.of(1, 2, 3, scheduler: MainScheduler.instance)
        // 相当于:
        // let ofObservable = Observable<Int>.create { observer in
        //     observer.onNext(1)
        //     observer.onNext(2)
        //     observer.onNext(3)
        //     observer.onCompleted()
        //     return Disposables.create()
        // }
        ofObservable
            .subscribe({ (e) in
                print("Of => \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    
    // 创建一个发射特定范围的顺序整数的Observable
    @objc
    func range() {
        let rangeObservable = Observable<Int>.range(start: 10, count: 30, scheduler: MainScheduler.instance)
        rangeObservable
            .debug("range")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // repeatElement 操作符将创建一个 Observable，这个 Observable 将无止尽的发出同一个元素。
    @objc
    func repeatElement() {
        let observable = Observable.repeatElement(10, scheduler: MainScheduler.instance)
        // 相当于：
        // let observable = Observable<Int>.create { observer in
        //     DispatchQueue.global().async {
        //         while true {
        //             DispatchQueue.main.async {
        //                 observer.onNext(0)
        //             }
        //             // 防止阻塞主线程
        //             Thread.sleep(forTimeInterval: 0.001)
        //         }
        //     }
        //     return Disposables.create()
        // }
        observable
            .debug("repeatElement")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // 直到订阅发生，才创建 Observable，并且为每位订阅者创建全新的 Observable
    // > ⚠️注意：是延迟创建 Observable ，而不是延迟订阅或者延迟元素的发出时间
    // defer 操作符将等待观察者订阅它，才创建一个 Observable，它会通过一个构建函数为每一位订阅者创建新的 Observable。
    // > ⚠️注意：看上去每位订阅者都是对同一个 Observable 产生订阅，实际上它们都获得了独立的序列。
    // 并不是像以前一样订阅同一个 Observable，实际为每个订阅者都创建了一个Observable
    // 在一些情况下，直到订阅时才创建 Observable 是可以保证拿到的数据都是最新的。
    @objc
    func `defer`() {
        let observable = Observable<String>.deferred { [unowned self] () -> Observable<String> in
            print("Observable is Create Now")
            return self.getSecondObservable()
        }
        
        delayTime(2) {
            print("First Subscribe Now")
            observable
                .debug("Test Defer: First Subscribe")
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // 测试是否为每位订阅者都创建了 Observable
        delayTime(5) {
            print("Second Subscribe Now")
            observable
                .debug("Test Defer: Second Subscribe")
                .subscribe()
                .disposed(by: self.disposeBag)
        }
    }
    
    
    // 创建一个 Observable 每隔一段时间，发出一个索引数
    // interval 操作符将创建一个 Observable，它每隔一段设定的时间，发出一个索引数的元素。它将发出无数个元素。
    @objc
    func interval() {
        let intervalQueue = DispatchQueue.init(label: "ink.tbd.test.interval")
        Observable<Int>
            .interval(1, scheduler: ConcurrentDispatchQueueScheduler.init(queue: intervalQueue))
            .subscribe({ (e) in
                print("interval => \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    
    // 创建一个 Observable 在一段延时后，产生唯一的一个元素
    // timer 操作符将创建一个 Observable，它在经过设定的一段时间后，产生唯一的一个元素。
    // 这里存在其他版本的 timer 操作符。
    // 
    // > ⚠️注意：timer(_:period:scheduler:) 与 interval(_:scheduler:) 的区别
    // timer(_:period:scheduler:) 的实现
    // public static func timer(_ dueTime: RxTimeInterval, period: RxTimeInterval? = nil, scheduler: SchedulerType)
    //     -> Observable<E> {
    //         return Timer(
    //             dueTime: dueTime,
    //             period: period,
    //             scheduler: scheduler
    //         )
    // }
    //
    // interval(_:scheduler:) 的实现
    // public static func interval(_ period: RxTimeInterval, scheduler: SchedulerType)
    //     -> Observable<E> {
    //         return Timer(dueTime: period,
    //                      period: period,
    //                      scheduler: scheduler
    //         )
    // }
    @objc
    func timer() {
        // dueTime: 初始延时, period: 时间间隔, scheduler: 队列
        let timerObservable = Observable<Int>.timer(5.0, period: 1, scheduler: MainScheduler.instance)
        timerObservable
            .debug("timer")
            .subscribe()
            .disposed(by: disposeBag)
    }
}
