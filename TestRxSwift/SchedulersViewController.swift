//
//  SchedulersViewController.swift
//  TestRxSwift
//
//  Created by 邵伟男 on 2017/12/15.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SDWebImage

class SchedulersViewController: TViewController {
    // MARK: subscribeOn
    @IBAction func testSubscribeOn() {
        let subscribeQueue = DispatchQueue.init(label: "ink.tbd.test.subscribeQueue")
        getObservable()
            // 数据序列的构建函数在哪个Scheduler上运行
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: subscribeQueue))
            .subscribe(getObserver())
            .disposed(by: disposeBag)
    }
    
    // MARK: observeOn
    @IBAction func testObserveOn() {
        let observeQueue = DispatchQueue.init(label: "ink.tbd.test.observeQueue")
        getObservable()
            // 在哪个Scheduler监听这个数据序列
            .observeOn(ConcurrentDispatchQueueScheduler.init(queue: observeQueue))
            .subscribe(getObserver())
            .disposed(by: disposeBag)
    }
}

extension SchedulersViewController {
    // getCurrentQueueName() -> String
    func getCurrentQueueName() -> String {
        let name = __dispatch_queue_get_label(nil)
        return String.init(cString: name, encoding: .utf8) ?? ""
    }
    
    // MARK: getObservable() -> Observable<String>
    func getObservable() -> Observable<String> {
        return Observable<String>.create { [weak self] (observer) -> Disposable in
            guard let strongSelf = self else { return Disposables.create() }
            print("Observable  Queue Is: " + strongSelf.getCurrentQueueName())
            
            // 当前线程直接发送元素
            observer.on(.next("Test 1"))
            DispatchQueue.main.async {
                // 切换到主线程发送元素
                observer.on(.next("Test 2"))
            }
            return Disposables.create()
        }
    }
    
    // MARK: getObserver() -> AnyObserver<UIImage?>
    func getObserver() -> AnyObserver<String> {
        return AnyObserver<String>.init(eventHandler: { [weak self] (e) in
            guard let strongSelf = self else { return }
            print("AnyObserver Queue Is: " + strongSelf.getCurrentQueueName())
            print("\t\t" + e.debugDescription)
        })
    }
}









