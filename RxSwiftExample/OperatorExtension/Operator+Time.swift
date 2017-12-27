//
//  Operator+Time.swift
//  RxSwiftExample
//
//  Created by 邵伟男 on 2017/12/26.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxSwift

extension Operator {
    
    // 将 Observable 的每一个元素拖延一段时间后发出
    // > ⚠️注意：是延迟元素的发出时间而不是延迟订阅或者创建 Observable 的时间
    // delay 操作符将修改一个 Observable，它会将 Observable 的所有元素都拖延一段设定好的时间， 然后才将它们发送出来。
    @objc
    func delay() {
        getFourthObservable()
            .delay(5, scheduler: MainScheduler.instance)
            .debug("delay")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // delaySubscription 操作符将在经过所设定的时间后，才对 Observable 进行订阅操作。
    // > ⚠️注意：是延迟延迟订阅时间，而不是元素的发出时间或者创建 Observable 的时间
    @objc
    func delaySubscription() {
        print("Create Observable Now")
        getFourthObservable()
            .delaySubscription(5, scheduler: MainScheduler.instance)
            .debug("delaySubscription")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // 如果源 Observable 在规定时间内没有发任何出元素，就产生一个超时的 error 事件
    // timer 操作符将使得序列发出一个 error 事件，只要 Observable 在一段时间内没有产生元素。
    @objc
    func timeout() {
        let observable = Observable<Int>.never()
        observable
            .timeout(3, scheduler: MainScheduler.instance)
            .debug("timeout")
            .subscribe()
            .disposed(by: disposeBag)
    }
}
