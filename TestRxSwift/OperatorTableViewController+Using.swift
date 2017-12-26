//
//  OperatorTableViewController+Using.swift
//  TestRxSwift
//
//  Created by 邵伟男 on 2017/12/26.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxSwift

extension OperatorTableViewController {
    
    //  创建一个可被清除的资源，它和 Observable 具有相同的寿命
    // 通过使用 using 操作符创建 Observable 时，同时创建一个可被清除的资源，一旦 Observable 终止了，那么这个资源就会被清除掉了。
    @objc
    func using() {
        class DisposableResource: Disposable {
            var values: [Int] = []
            var isDisposed: Bool = false
            
            func dispose() {
                self.values = []
                self.isDisposed = true
                print("!!!DisposableResource is Disposed!!!")
            }
            init(with values: [Int]) {
                self.values = values
            }
        }
        
        let observable = Observable<Int>.using({ () -> DisposableResource in
            return DisposableResource.init(with: [1, 2, 3, 4])
        }, observableFactory: { (resource) -> Observable<Int> in
            if resource.isDisposed {
                return Observable<Int>.from([])
            } else {
                return Observable<Int>.from(resource.values)
            }
        })
        
        observable
            .debug()
            .subscribe()
            .disposed(by: disposeBag)
    }
}
