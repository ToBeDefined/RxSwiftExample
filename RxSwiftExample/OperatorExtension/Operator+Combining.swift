//
//  Operator+Combining.swift
//  RxSwiftExample
//
//  Created by 邵伟男 on 2017/12/26.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxSwift

extension Operator {
    
    // 将一些元素插入到序列的头部
    // startWith 操作符会在 Observable 头部插入一些元素。
    // （如果你想在尾部加入一些元素可以用concat）
    @objc
    func startWith() {
        Observable.of("🐶", "🐱", "🐭", "🐹")
            .startWith("First")
            .startWith("Second")
            .startWith("Third")
            .startWith("1", "2", "3")
            .debug("startWith")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // combineLatest 操作符将多个 Observables 中最新的元素通过一个函数组合起来，然后将这个组合的结果发出来。
    // 这些源 Observables 中任何一个发出一个元素，他都会发出一个元素（前提是，这些 Observables 曾经发出过元素）。
    @objc
    func combineLatest() {
        Observable<String>
            .combineLatest(getFirstObservable(), getSecondObservable(), resultSelector: { (fstr, sstr) -> String in
                return fstr + " | " + sstr
            })
            .debug("combineLatest")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // 通过一个函数将多个 Observables 的元素组合起来，然后将每一个组合的结果发出来
    // zip 操作符将多个(最多不超过8个) Observables 的元素通过一个函数组合起来，然后将这个组合的结果发出来。它会严格的按照序列的索引数进行组合。
    // 例如，返回的 Observable 的第一个元素，是由每一个源 Observables 的第一个元素组合出来的。
    // 它的第二个元素 ，是由每一个源 Observables 的第二个元素组合出来的。
    // 它的第三个元素 ，是由每一个源 Observables 的第三个元素组合出来的，以此类推。
    // 它的元素数量等于源 Observables 中元素数量最少的那个。
    @objc
    func zip()  {
        let disposeBag = DisposeBag()
        let first = PublishSubject<String>()
        let second = PublishSubject<String>()
        
        Observable
            .zip(first, second) { $0 + $1 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        first.onNext("1")
        second.onNext("A")
        
        first.onNext("2")
        second.onNext("B")
        
        second.onNext("C")
        second.onNext("D")
        first.onNext("3")
        first.onNext("4")
        first.onNext("5")
    }
    
    
    // 将两 Observables 最新的元素通过一个函数组合以来，当第一个 Observable 发出一个元素，就将组合后的元素发送出来
    // withLatestFrom 操作符将两个 Observables 中最新的元素通过一个函数组合起来，然后将这个组合的结果发出来。
    // 当第一个 Observable 发出一个元素时，就立即取出第二个 Observable 中最新的元素，通过一个组合函数将两个最新的元素合并后发送出去。
    @objc
    func withLatestFrom() {
        // 当第一个 Observable 发出一个元素时，就立即取出第二个 Observable 中最新的元素，
        // 然后把第二个 Observable 中最新的元素发送出去。
        print("============================First============================")
        getFirstObservable()
            .withLatestFrom(getSecondObservable())
            .debug("withLatestFrom")
            .subscribe()
            .disposed(by: disposeBag)
        
        // 当第一个 Observable 发出一个元素时，就立即取出第二个 Observable 中最新的元素，
        // 然后把第一个 Observable 中最新的元素first和然后把第二个 Observable 中最新的元素second组合first+second发送出去。
        delayTime(10) {
            print("============================Second============================")
            self.getFirstObservable()
                .withLatestFrom(self.getSecondObservable(), resultSelector: { (first, second) -> String in
                    return first + " <====> " + second
                })
                .debug("withLatestFrom & Function")
                .subscribe()
                .disposed(by: self.disposeBag)
        }
    }
    
    
    // 将多个 Observables 合并成一个
    // 通过使用 merge 操作符你可以将多个 Observables 合并成一个，当某一个 Observable 发出一个元素时，他就将这个元素发出。
    // 如果，某一个 Observable 发出一个 onError 事件，那么被合并的 Observable 也会将它发出，并且立即终止序列。
    @objc
    func merge() {
        let subject1 = PublishSubject<String>()
        let subject2 = PublishSubject<String>()
        
        Observable.of(subject1, subject2)
            .merge()
            .debug("merge")
            .subscribe()
            .disposed(by: disposeBag)
        subject1.onNext("🅰️")
        subject1.onNext("🅱️")
        subject2.onNext("1️⃣")
        subject2.onNext("2️⃣")
        subject1.onNext("🆎")
        subject2.onNext("3️⃣")
        let err = TError.init(errorCode: 0, errorString: "Test Error", errorData: nil)
        subject1.onError(err)
        subject2.onNext("4️⃣")
        subject2.onNext("5️⃣")
    }
    
    
    // 当你的事件序列是一个事件序列的序列 (Observable<Observable<T>>) 的时候，（可以理解成二维序列）
    // 可以使用 switch 将序列的序列平铺成一维，并且在出现新的序列的时候，自动切换到最新的那个序列上。
    // 和 merge 相似的是，它也是起到了将多个序列『拍平』成一条序列的作用。
    // > ⚠️注意：当源 Observable 发出一个新的 Observable 时，而不是当新的 Observable 发出一个项目时，它将从之前发出的 Observable 中取消订阅。
    // 这意味着在后面的 Observable 被发射的时间和随后的 Observable 本身开始发射的时间之间，前一个 Observable 发射的物体将被丢弃。
    @objc
    func switchLatest() {
        // 第一个： 发送3个元素
        let innerObservable_1 = Observable<String>.of("innerObservable_1: 1",
                                                      "innerObservable_1: 2",
                                                      "innerObservable_1: 3")
        // 持续1秒发出一个元素，递增
        let innerObservable_2 = Observable<Int>.interval(1, scheduler: MainScheduler.instance).map { (value) -> String in
            print("innerObservable_2 => Send \(value)")
            return "innerObservable_2: \(value)"
        }
        // 持续1秒发出一个元素，递增
        let innerObservable_3 = Observable<Int>.interval(1, scheduler: MainScheduler.instance).map { (value) -> String in
            print("innerObservable_3 => Send \(value)")
            return "innerObservable_3: \(value)"
        }
        
        let externalObservable = Observable<Observable<String>>.create({ (observer) -> Disposable in
            observer.onNext(innerObservable_1)
            delayTime(2, block: {
                observer.onNext(innerObservable_2)
            })
            
            delayTime(6, block: {
                observer.onNext(innerObservable_3)
            })
            delayTime(12, block: {
                // 不加 observer.onNext(Observable<String>.never()) 的话，innerObservable_3会持续不断的发送
                print("observer.onNext(Observable<String>.never())")
                print("observer.onCompleted()")
                observer.onNext(Observable<String>.never())
                observer.onCompleted()
            })
            return Disposables.create()
        })
        
        externalObservable
            .switchLatest()
            .debug("switchLatest")
            .subscribe()
            .disposed(by: disposeBag)
    }
}
