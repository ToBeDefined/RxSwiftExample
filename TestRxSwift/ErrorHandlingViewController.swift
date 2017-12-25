//
//  ErrorHandlingViewController.swift
//  TestRxSwift
//
//  Created by 邵伟男 on 2017/12/15.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class ErrorHandlingViewController: TViewController {
    // MARK: retry
    @IBAction func testRetry() {
        getDictObservable()
            .retry(3)   // 总共调用3次包括第一次
            .subscribe({ (e) in
                print("in the end: \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: retryWhen
    @IBAction func testRetryWhen() {
        let retryDelay: RxTimeInterval = 1.0
        getDictObservable()
            .retryWhen({ (rxError) -> Observable<Int> in
                return rxError.flatMap({ (e) -> Observable<Int> in
                    return Observable.timer(retryDelay, scheduler: MainScheduler.instance)
                })
            })
            .subscribe({ (e) in
                print("in the end: \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: retryWhen + MaxRetry
    @IBAction func testRetryWhenAndMaxRetry() {
        let retryDelay: RxTimeInterval = 1.0
        let maxRetryCount: Int = 4
        getDictObservable()
            .retryWhen({ (rxError) -> Observable<Int> in
                return rxError.enumerated().flatMap({ (index, element) -> Observable<Int> in
                    if index >= maxRetryCount {
                        let err = TError.init(errorCode: 0, errorString: "Retry Too Many Times", errorData: nil)
                        return Observable.error(err)
                    }
                    return Observable.timer(retryDelay, scheduler: MainScheduler.instance)
                })
            })
            .subscribe({ (e) in
                print("in the end: \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: catchErrorJustReturn
    @IBAction func testCatchErrorJustReturn() {
        let defaultDict = ["returnDefaultDict": "Is DefaultDict"]
        getDictObservable()
            .catchErrorJustReturn(defaultDict)
            .subscribe ({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: catchError
    @IBAction func testCatchError() {
        let defaultDictVariable: Variable<[AnyHashable: Any]> = Variable.init(["returnDefaultDict": "Is DefaultDictVariable"])
        getDictObservable()
            .catchError({ (error) -> Observable<[AnyHashable : Any]> in
                return defaultDictVariable.asObservable()
            })
            .subscribe ({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: ═══════════════════════════════════════
    // MARK: ╰⋛⋋⊱⋋๑圝◣  Test ResultModel  ◢圝๑⋌⊰⋌⋚╯
    // MARK: ═══════════════════════════════════════
    @IBOutlet weak var testInPreviousWayButton: UIButton!
    @IBOutlet weak var testResultModelButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        testInPreviousWay()
        testResultModel()
    }
    
    // testInPreviousWay
    func testInPreviousWay() {
        // 如果这部分代码只会运行一次（只进行一次绑定）
        // 此时如果发生error事件之后则被丢弃，后续点击则无法再响应
        testInPreviousWayButton.rx.tap
            .flatMapLatest({ [unowned self] (_) -> Observable<[AnyHashable: Any]> in
                return self.getDictObservable()
            })
            .subscribe(onNext: { [unowned self] (dict) in
                print("Button is Taped: \(self.testInPreviousWayButton.titleLabel?.text ?? "" ) ")
                print("get dict success: \(dict)")
            }, onError: { [unowned self] (_) in
                // 此处一旦进入，订阅将失效，后续点击不会响应
                print("Button is Taped: \(self.testInPreviousWayButton.titleLabel?.text ?? "" ) ")
                // err.printLog()
            })
            .disposed(by: disposeBag)
    }
    
    // testResultModel
    func testResultModel() {
        enum ResultModel<T> {
            case success(T)
            case failure(Error)
        }
        
        // 如果这部分代码只会运行一次（只进行一次绑定）
        // 此时如果发生error事件之后则会被转成ResultMode.failure(err)
        // 此时拦截了error事件，订阅不会丢弃，后续点击可以继续响应
        testResultModelButton.rx.tap
            .flatMapLatest({ [unowned self] (_) -> Observable<ResultModel<[AnyHashable: Any]>> in
                return self.getDictObservable()
                    .map(ResultModel<[AnyHashable: Any]>.success)
                    .catchError({ (error) -> Observable<ResultModel<[AnyHashable : Any]>> in
                        return Observable.just(ResultModel.failure(error))
                    })
            })
            .subscribe(onNext: { [unowned self] (resultModel) in
                switch resultModel {
                case .success(let dict):
                    print("Is In ResultModel & Button is Taped: \(self.testResultModelButton.titleLabel?.text ?? "" ) ")
                    print("get dict success: \(dict)")
                case .failure(_):
                    print("Is In ResultModel & Button is Taped: \(self.testResultModelButton.titleLabel?.text ?? "" ) ")
                    // err.printLog()
                }
            }, onError: { [unowned self] (err) in
                // 此处永远不会进入
                print("Is In Subscribe Error & Button is Taped: \(self.testResultModelButton.titleLabel?.text ?? "" ) ")
                err.printLog()
            })
            .disposed(by: disposeBag)
    }
}

extension ErrorHandlingViewController {
    // MARK: getJSONObservable() -> Observable<[AnyHashable: Any]>
    func getDictObservable() -> Observable<[AnyHashable: Any]> {
        return Observable<[AnyHashable: Any]>.create({ (observer) -> Disposable in
            let randomValue = Int(arc4random() % 5)
            if randomValue == 0 {
                print("on Next")
                observer.on(.next(["isSuccess": true]))
            } else {
                print("on Error")
                let err = TError.init(errorCode: 0, errorString: "random value is \(randomValue)", errorData: nil)
                observer.on(.error(err))
            }
            return Disposables.create()
        })
    }
}


