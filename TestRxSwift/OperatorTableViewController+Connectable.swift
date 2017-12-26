//
//  OperatorTableViewController+Connectable.swift
//  TestRxSwift
//
//  Created by 邵伟男 on 2017/12/26.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxSwift

extension OperatorTableViewController {
    
    // 将 Observable 转换为可被连接的 Observable
    // publish 会将 Observable 转换为可被连接的 Observable。
    // 可被连接的 Observable 和普通的 Observable 十分相似，不过在被订阅后不会发出元素，直到 connect 操作符被应用为止。
    // 这样一来你可以控制 Observable 在什么时候开始发出元素。
    @objc
    func publish() {
        let connectObservable = Observable.of(1, 2, 3, 4, 5, 6).publish()
        print("> connectObservable subscribe now")
        connectObservable
            .subscribe({ e in
                print("connectObservable => \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
        delayTime(3) {
            print("> connectObservable connect now")
            connectObservable
                .connect()
                .disposed(by: self.disposeBag)
        }
    }
    
    
    // 通知可被连接的 Observable 可以开始发出元素了
    // 可被连接的 Observable 和普通的 Observable 十分相似
    // 不过在被订阅后不会发出元素，直到 connect 操作符被应用为止。
    // 这样一来你可以等所有观察者全部订阅完成后，才发出元素。
    @objc
    func connect() {
        let connectableObservable = ConnectableObservable<String>
            .create({ (observer) -> Disposable in
                observer.onNext("ConnectableObservable -> 1")
                observer.onNext("ConnectableObservable -> 2")
                observer.onNext("ConnectableObservable -> 3")
                delayTime(2, block: {
                    observer.onNext("ConnectableObservable -> delay -> 1")
                })
                delayTime(4, block: {
                    observer.onNext("ConnectableObservable -> delay -> 2")
                })
                return Disposables.create()
            })
            .publish()
        
        connectableObservable
            .subscribe({ (e) in
                print("First Subscribe : \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
        connectableObservable
            .connect()
            .disposed(by: disposeBag)
        connectableObservable
            .subscribe({ (e) in
                print("Second Subscribe : \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    
    // 将可被连接的 Observable 转换为普通 Observable
    // 可被连接的 Observable 和普通的 Observable 十分相似，不过在被订阅后不会发出元素，直到 connect 操作符被应用为止。
    // 这样一来你可以控制 Observable 在什么时候开始发出元素。
    // refCount 操作符将自动连接和断开可被连接的 Observable。
    // 它将可被连接的 Observable 转换为普通 Observable。
    // 当第一个观察者对它订阅时，那么底层的 Observable 将被连接。当最后一个观察者离开时，那么底层的 Observable 将被断开连接。
    @objc
    func refCount() {
        let connectObservable = getFirstObservable().publish()
        let observable = connectObservable.refCount()
        observable
            .debug("refCount")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // 确保观察者接收到同样的序列，即使是在 Observable 发出元素后才订阅
    // 可被连接的 Observable 和普通的 Observable 十分相似，不过在被订阅后不会发出元素，直到 connect 操作符被应用为止。这样一来你可以控制 Observable 在什么时候开始发出元素。
    // replay 操作符将 Observable 转换为可被连接的 Observable，并且这个可被连接的 Observable 将缓存最新的 n 个元素。当有新的观察者对它进行订阅时，它就把这些被缓存的元素发送给观察者。
    @objc
    func replay() {
        let observable = getFirstObservable().replayAll()
        // let observable = getFirstObservable().replay(4)
        observable
            .debug("First")
            .subscribe()
            .disposed(by: disposeBag)
        observable
            .connect()
            .disposed(by: disposeBag)
        delayTime(6) {
            observable
                .debug("replay")
                .subscribe()
                .disposed(by: self.disposeBag)
        }
    }
    
    
    // 使观察者共享 Observable，观察者会立即收到最新的元素，即使这些元素是在订阅前产生的
    // shareReplay 操作符将使得观察者共享源 Observable，并且缓存最新的 n 个元素，将这些元素直接发送给新的观察者。
    @objc
    func shareReplay() {
        let observable = getFirstObservable().share(replay: 2, scope: SubjectLifetimeScope.forever)
        observable
            .debug("Origin")
            .subscribe()
            .disposed(by: disposeBag)
        delayTime(3) {
            observable
                .debug("shareReply")
                .subscribe()
                .disposed(by: self.disposeBag)
        }
    }
}
