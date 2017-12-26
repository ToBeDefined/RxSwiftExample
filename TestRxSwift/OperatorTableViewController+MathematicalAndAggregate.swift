//
//  OperatorTableViewController+MathematicalAndAggregate.swift
//  TestRxSwift
//
//  Created by 邵伟男 on 2017/12/26.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxSwift

extension OperatorTableViewController {
    
    // concat 操作符将多个 Observables 按顺序串联起来，当前一个 Observable 元素发送完毕后，后一个 Observable 才可以开始发出元素。
    // concat 将等待前一个 Observable 产生完成事件后，才对后一个 Observable 进行订阅。
    // 如果后一个是“热” Observable ，在它前一个 Observable 产生完成事件前，所产生的元素将不会被发送出来。
    @objc
    func concat() {
        getFirstObservable()
            .concat(getSecondObservable())
            .concat(getThirdObservable())
            .debug()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    
    // 持续的将 Observable 的每一个元素应用一个函数，然后发出最终结果
    // reduce 操作符将对第一个元素应用一个函数。然后，将结果作为参数填入到第二个元素的应用函数中。以此类推，直到遍历完全部的元素后发出最终结果。
    // 这种操作符在其他地方有时候被称作是 accumulator，aggregate，compress，fold 或者 inject。
    // 与scan类似，reduce发送最终结果，scan发送每个步骤
    @objc
    func reduce() {
        let observable = Observable.of(1, 2, 3, 4, 5, 6)
        // reduce(<#T##seed: A##A#>, accumulator: <#T##(A, Int) throws -> A#>)
        // seed: 基数，accumulator: 运算方法
        // reduce(<#T##seed: A##A#>, accumulator: <#T##(A, Int) throws -> A#>, mapResult: <#T##(A) throws -> R#>)
        // seed: 基数，accumulator: 运算方法，mapResult:
        observable
            .reduce(10, accumulator: {(a, b) -> Int in
                return a*b
            }, mapResult: { (value) -> String in
                return "In the end, value is \(value)"
            })
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
}


