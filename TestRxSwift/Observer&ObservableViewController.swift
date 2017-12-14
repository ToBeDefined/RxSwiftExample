//
//  Observer&ObservableViewController.swift
//  TestRxSwift
//
//  Created by 邵伟男 on 2017/12/14.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SDWebImage

class Observer_ObservableViewController: UIViewController {
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension Observer_ObservableViewController {
    @IBAction func testAsyncSubject() {
        let subject = AsyncSubject<String>()
        
        subject.subscribe({ (e) in
            print("Subscription: 1 Event:", e)
        }).disposed(by: disposeBag)
        // 1
        subject.onNext("🐶")
        subject.onNext("🐱")
        // 只发送 onCompleted前面最后一个
        subject.onNext("🐹")
        subject.onCompleted()
    }
    
    @IBAction func testPublishSubject() {
        let disposeBag = DisposeBag()
        let subject = PublishSubject<String>()
        
        subject.subscribe({ (e) in
            print("Subscription: 1 Event:", e)
        }).disposed(by: disposeBag)
        
        subject.onNext("🐶")
        subject.onNext("🐱")
        
        subject.subscribe({ (e) in
            print("Subscription: 2 Event:", e)
        }).disposed(by: disposeBag)
        
        subject.onNext("🅰️")
        subject.onNext("🅱️")
        subject.onCompleted()
    }
}








