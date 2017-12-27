//
//  Operator+Materialize.swift
//  RxSwiftExample
//
//  Created by 邵伟男 on 2017/12/26.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxSwift

extension Operator {
    
    // 通常，一个有限的 Observable 将产生零个或者多个 onNext 事件，然后产生一个 onCompleted 或者 onError 事件。
    // materialize 操作符将 Observable 产生的这些事件全部转换成元素，然后发送出来。
    @objc
    func materialize() {
        getErrorObservable()
            .materialize()
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
    
    
    // dematerialize 操作符将 materialize 转换后的元素还原
    @objc
    func dematerialize() {
        let materializeObservable = getErrorObservable().materialize()
        materializeObservable
            .dematerialize()
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
}
