//
//  Operator+ConditionalAndBoolean.swift
//  TestRxSwift
//
//  Created by 邵伟男 on 2017/12/26.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxSwift

extension Operator {
    
    // 当你传入多个 Observables 到 amb 操作符时
    // 它将取其中一个 Observable：第一个产生事件的那个 Observable
    // 可以是一个 next，error 或者 completed 事件
    // amb 将忽略掉其他的 Observables。
    @objc
    func amb() {
        let first = getFirstObservable()
        let second = getSecondObservable()
        let third = getThirdObservable()
        first
            .amb(second)
            .amb(third)
            .debug()
            .subscribe()
            .disposed(by: disposeBag)
    }
}
