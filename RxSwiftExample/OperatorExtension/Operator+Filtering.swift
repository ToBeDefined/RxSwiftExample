//
//  Operator+Filtering.swift
//  RxSwiftExample
//
//  Created by 邵伟男 on 2017/12/26.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxSwift

extension Operator {
    
    // 忽略掉所有的元素，只发出 error 或 completed 事件
    // ignoreElements 操作符将阻止 Observable 发出 next 事件，但是允许他发出 error 或 completed 事件。
    // 如果你并不关心 Observable 的任何元素，你只想知道 Observable 在什么时候终止，那就可以使用 ignoreElements 操作符。
    @objc
    func ignoreElements() {
        Observable<Int>.of(1, 2, 3, 4, 5)
            .ignoreElements()
            .debug("ignoreElements")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // elementAt 操作符将拉取 Observable 序列中指定索引数的元素，然后将它作为唯一的元素发出。
    @objc
    func elementAt() {
        Observable<Int>.of(1, 2, 3, 4, 5)
            .elementAt(1)
            .subscribe({ (e) in
                print("elementAt subscribe -> \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    
    // filter 操作符将通过你提供的判定方法过滤一个 Observable。
    // 仅仅发出 Observable 中通过判定的元素
    @objc
    func filter() {
        Observable
            .of(21, 3, 15, 50, 4, 23, 90, 11)
            .debug("Filter    : ")
            .filter({ (value) -> Bool in
                return value >= 20
            })
            .debug("Subscribe : ")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // 用于过滤一定时间内发出的高频元素，只发送最后一个
    // debounce 操作符将发出这种元素，在 Observable 产生这种元素后，一段时间内没有新元素产生。
    @objc
    func debounce() {
        getFirstObservable()
            .debounce(1, scheduler: MainScheduler.instance)
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
    
    
    // 返回在指定连续时间窗口期间中，由源 Observable 发出的第一个和最后一个元素。
    // 这个运算符确保没有两个元素在少于 dueTime 的时间发送。
    @objc
    func throttle() {
        let subject = BehaviorSubject<Int>.init(value: 0)
        subject
            .asObserver()
            // 2秒内第一个和最后一个发出的元素
            .throttle(2, latest: true, scheduler: MainScheduler.instance)
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
        
        subject.onNext(1)
        subject.onNext(2)
        subject.onNext(3)
        delayTime(3) {
            // 不会发送onNext(4)，因为onNext(3)在上一个2秒的窗口中，最后延迟到2秒发送出来，
            // onNext(4)是在第3秒进行发送，此时 onNext(4)的发送时间减去onNext(3)发送时间小于2，所以被忽略
            // 因为throttle会确保没有两个元素在少于dueTime的时间
            subject.onNext(4)
            subject.onNext(5)
            subject.onNext(6)
        }
        
        delayTime(8.2) {
            subject.onNext(7)
        }
        
        delayTime(12.2) {
            subject.onNext(8)
            subject.onNext(9)
            subject.onNext(10)
            subject.onCompleted()
        }
    }
    
    
    // distinctUntilChanged 操作符将阻止 Observable 发出相同的元素。
    // 如果后一个元素和前一个元素是相同的，那么这个元素将不会被发出来。
    // 如果后一个元素和前一个元素不相同，那么这个元素才会被发出来。
    @objc
    func distinctUntilChanged() {
        let observable = Observable.of("🐱", "🐷", "🐱", "🐱", "🐱", "🐵", "🐵", "🐵", "🐵", "🐱")
        observable
            .distinctUntilChanged()
            .debug("distinctUntilChanged")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // 不定期的对 Observable 取样
    // sample 操作符将不定期的对源 Observable 进行取样操作。
    // 通过第二个 Observable 来控制取样时机。
    // 一旦第二个 Observable 发出一个元素，就从源(第一个) Observable 中取出最后产生的元素（如果这段时间内没发出元素，则不取）。
    @objc
    func sample() {
        let sampleObservable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        let observable = getFirstObservable()
            .sample(sampleObservable)
        observable
            .debug("sample")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // skip 操作符可以让你跳过 Observable 中头 n 个元素，只关注后面的元素。
    @objc
    func skip() {
        Observable<Int>
            .of(0, 0, 0, 0, 1, 2, 3, 4, 5)
            .skip(4)
            .debug("skip")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // 跳过 Observable 中头几个元素，直到元素的判定为否
    // 闭包返回 true 则跳过(skip)
    // skipWhile 操作符可以让你忽略源 Observable 中头几个元素，直到元素的判定为否后，它才镜像源 Observable。
    // 一旦有 false 产生，后面的元素不会再进行判断
    @objc
    func skipWhile() {
        Observable<Int>
            .of(0, 0, 0, 0, 1, 2, 3, 4, 5, -1, 0, 0, 10)
            .skipWhile({ (value) -> Bool in
                return value == 0
            })
            .debug("skipWhile")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // 跳过 Observable 中头几个元素，直到另一个 Observable 发出一个元素
    // skipUntil 操作符可以让你忽略源 Observable 中头几个元素，直到另一个 Observable 发出一个元素后，它才镜像源 Observable。
    @objc
    func skipUntil() {
        let skipUntilObservable = Observable<Int>.create { (observer) -> Disposable in
            delayTime(3, block: {
                print("skipUntilObservable => onNext(0)")
                observer.onNext(0)
            })
            return Disposables.create()
        }
        getFirstObservable()
            .skipUntil(skipUntilObservable)
            .debug("skipUntil")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // 仅仅从 Observable 中发出头 n 个元素
    // 通过 take 操作符你可以只发出头 n 个元素。并且忽略掉后面的元素，直接结束序列。
    @objc
    func take() {
        Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
            .take(3)
            .debug("take")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // 仅仅从 Observable 中发出尾部 n 个元素
    // 通过 takeLast 操作符你可以只发出尾部 n 个元素。并且忽略掉前面的元素。
    // 在 onCompleted() 之后取出最后n个元素一次性发出
    @objc
    func takeLast() {
        getFirstObservable()
            .takeLast(5)
            .debug("takeLast")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // 镜像一个 Observable 直到某个元素的判定为 false
    // 闭包返回true则放行，返回false则结束
    // takeWhile 操作符将镜像源 Observable 直到某个元素的判定为 false。此时，这个镜像的 Observable 将立即终止。
    @objc
    func takeWhile() {
        Observable<Int>
            .of(0, 0, 0, 0, 1, 2, 3, 4, 5, -1, 0, 0, 10)
            .takeWhile({ (value) -> Bool in
                return value >= 0
            })
            .debug("takeWhile")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // 忽略一部分元素，这些元素是在第二个 Observable 产生事件后发出的
    // takeUntil 操作符将镜像源 Observable，它同时观测第二个 Observable。
    // 一旦第二个 Observable 发出一个元素或者产生一个终止事件，那个镜像的 Observable 将立即终止。
    @objc
    func takeUntil() {
        let takeUntilObservable = Observable<Int>.create { (observer) -> Disposable in
            delayTime(3, block: {
                print("takeUntilObservable => onNext(0)")
                observer.onNext(0)
            })
            return Disposables.create()
        }
        getFirstObservable()
            .takeUntil(takeUntilObservable)
            .debug("takeUntil")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // 限制 Observable 只有一个元素，否出发出一个 error 事件
    // single 操作符将限制 Observable 只产生一个元素。
    // 如果 Observable 只有一个元素，它将镜像这个 Observable 。
    // 如果 Observable 没有元素或者元素数量大于一，它将产生一个 error 事件。
    @objc
    func single() {
        Observable<Int>
            .just(1)
            .single()
            .subscribe({ e in
                print("single 1 => \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
        
        Observable<Int>
            .of(1, 2, 3, 4, 5)
            .single()
            .subscribe({ (e) in
                print("single 2 => \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
}
