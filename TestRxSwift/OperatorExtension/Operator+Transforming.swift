//
//  Operator+Transforming.swift
//  TestRxSwift
//
//  Created by 邵伟男 on 2017/12/26.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxSwift

extension Operator {
    
    // 将 Observable 中的单个元素转换成 Array 的数据结构的 Observable 进行发送
    @objc
    func toArray() {
        let observable = Observable.of(1, 2, 3, 4, 5, 6)
        observable
            .toArray()
            .debug("toArray")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // 通过一个转换函数，将 Observable 的每个元素转换一遍
    // map 操作符将源 Observable 的每个元素应用你提供的转换方法，然后返回含有转换结果的 Observable。
    @objc
    func map() {
        let disposeBag = DisposeBag()
        Observable.of(1, 2, 3)
            .map({ (value) -> String in
                return "Value is \(value * 10)"
            })
            .subscribe({ e in
                print("map => \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    
    // 持续的将 Observable 的每一个元素应用一个函数，然后发出每一次函数返回的结果
    // scan 操作符将对第一个元素应用一个函数，将结果作为第一个元素发出。
    // 然后，将结果作为参数填入到第二个元素的应用函数中，创建第二个元素。
    // 以此类推，直到遍历完全部的元素。
    // (这种操作符在其他地方有时候被称作是 accumulator。)
    // 与reduce类似，reduce发送最终结果，scan发送每个步骤
    @objc
    func scan() {
        let observable = Observable<Int>.of(1, 2, 4, 8, 16, 32, 64, 128, 256, 512)
        observable
            .scan(0, accumulator: { (l, r) -> Int in
                return l + r
            })
            .debug("Scan")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // 将 Observable 的元素转换成其他的 Observable，然后将这些 Observables 合并
    // flatMap 操作符将源 Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。
    // 然后将这些 Observables 的元素合并之后再发送出来。
    // 这个操作符是非常有用的，例如，当 Observable 的元素本生拥有其他的 Observable 时，你可以将所有子 Observables 的元素发送出来。
    @objc
    func flatMap() {
        let first = BehaviorSubject(value: "First => 👦🏻")
        let second = BehaviorSubject(value: "Second => 😊")
        let variable = Variable(first)
        
        variable
            .asObservable()
            .flatMap { $0 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        first.onNext("First => 🐱")
        variable.value = second
        second.onNext("Second => 😢")
        first.onNext("First => 🐶")
        first.onNext("First => 🐱")
        second.onNext("Second => 😂")
    }
    
    
    // 将 Observable 的元素转换成其他的 Observable，然后取这些 Observables 中的第一个
    // 只发第一个 Observables 的元素，其他的 Observables 的元素将被忽略掉。
    @objc
    func flatMapFirst() {
        let first = BehaviorSubject(value: "First => 👦🏻")
        let second = BehaviorSubject(value: "Second => 😊")
        let variable = Variable(first)
        
        variable
            .asObservable()
            .flatMapFirst{ $0 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        first.onNext("First => 🐱")
        variable.value = second
        second.onNext("Second => 😢")
        first.onNext("First => 🐶")
        first.onNext("First => 🐱")
        second.onNext("Second => 😂")
    }
    
    
    // 将 Observable 的元素转换成其他的 Observable，然后取这些 Observables 中最新的一个
    // 一旦转换出一个新的 Observable，就只发出它的元素，旧的 Observables 的元素将被忽略掉。
    @objc
    func flatMapLatest() {
        let first = BehaviorSubject(value: "First => 👦🏻")
        let second = BehaviorSubject(value: "Second => 😊")
        let variable = Variable(first)
        
        variable
            .asObservable()
            .flatMapLatest { $0 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        first.onNext("First => 🐱")
        variable.value = second
        second.onNext("Second => 😢")
        first.onNext("First => 🐶")
        first.onNext("First => 🐱")
        second.onNext("Second => 😂")
    }
    
    
    // > `@available(*, deprecated, message: "Please use enumerated().flatMap()")`
    // flatMapWithIndex（ `.enumerated().flatMap(_:)` ） 操作符将 Observable 的元素转换成其他的 Observable，然后取这些 Observables 中指定的一个或者几个
    // 只发出指定允许的index的 Observable 中产生的元素，其他的 Observables 的元素将被忽略掉。
    @objc
    func flatMapWithIndex() {
        // @available(*, deprecated, message: "Please use enumerated().flatMap()")
        
        let first = BehaviorSubject(value: "First => 👦🏻")
        let second = BehaviorSubject(value: "Second => 😊")
        let variable = Variable(first)
        
        variable
            .asObservable()
            .enumerated()
            .flatMap({ (tuple) -> Observable<String> in
                let (index, subject) = tuple
                if index == 1 {
                    return subject
                }
                return BehaviorSubject<String>.empty()
            })
            // .enumerated().flatMap(_:) 以前是
            // .flatMapWithIndex({ (subject, index) -> Observable<String> in
            //     if index == 1 {
            //         return subject
            //     }
            //     return BehaviorSubject<String>.empty()
            // })
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        first.onNext("First => 🐱")
        variable.value = second
        second.onNext("Second => 😢")
        first.onNext("First => 🐶")
        first.onNext("First => 🐱")
        second.onNext("Second => 😂")
    }
    
    
    // concatMap 操作符将源 Observable 的每一个元素应用一个转换方法，将元素转换成 Observable。
    @objc
    func concatMap() {
        getFirstObservable()
            .concatMap({ (str) -> Observable<String> in
                return Observable.of("\(str) + 1️⃣", "\(str) + 2️⃣", "\(str) + 3️⃣", "======================")
            })
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
    
    
    // buffer 操作符将缓存 Observable 中发出的新元素
    // 当元素达到某个数量，或者经过了特定的时间，它就会将这个元素集合发送出来。
    @objc
    func buffer() {
        getFirstObservable()
            .buffer(timeSpan: 1, count: 2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (strArr) in
                print(strArr)
            })
            .disposed(by: disposeBag)
    }
    
    
    // 将 Observable 分解为多个子 Observable，周期性的将子 Observable 发出来
    // window 操作符和 buffer 十分相似:
    // |    \     |                发送出的内容形态               |             发送的时机            |
    // | :------: | :----------------------------------------: | :-----------------------------: |
    // | `buffer` |         周期性的将缓存的元素集合发送出来         | 要等到元素搜集完毕后，才会发出元素序列 |
    // | `window` | 周期性的将元素集合以 `Observable` 的形态发送出来 |         可以实时发出元素序列        |

    @objc
    func window() {
        getFirstObservable()
            .window(timeSpan: 2, count: 3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (observable) in
                print("window => onNext(\(observable))")
                observable
                    .subscribe({ (e) in
                        print("window|onNext => \(e)")
                    })
                    .disposed(by: self.disposeBag)
                }, onError: { (err) in
                    print("window => onError begin")
                    err.printLog()
                    print("window => onError end")
            }, onCompleted: {
                print("window => onCompleted")
            })
            .disposed(by: disposeBag)
    }
    
    
    // 将源 Observable 分解为多个子 Observable，并且每个子 Observable 将源 Observable 中“相似”的元素发送出来
    // groupBy 操作符将源 Observable 分解为多个子 Observable，然后将这些子 Observable 发送出来。
    // 它会将元素通过某个键进行分组，然后将分组后的元素序列以 Observable 的形态发送出来。
    @objc
    func groupBy() {
        enum ObservableValueType {
            case integer
            case string
            case other
        }
        let observable = Observable<Any>.of(1, 2, 3, 4, "22", "23", "34", "54", "12", 44, "112", 65)
        observable
            .groupBy(keySelector: { (value) -> ObservableValueType in
                if value is Int {
                    return ObservableValueType.integer
                }
                if value is String {
                    return ObservableValueType.string
                }
                return ObservableValueType.other
            })
            .subscribe(onNext: { [unowned self] (group) in
                group
                    .subscribe({ (e) in
                        print("\(group.key)\t=> \(e.debugDescription)")
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
}
