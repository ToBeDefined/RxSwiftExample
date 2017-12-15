//
//  DisposableViewController.swift
//  TestRxSwift
//
//  Created by 邵伟男 on 2017/12/15.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DisposableViewController: TViewController {
    private let disposeBag = DisposeBag()
}

extension DisposableViewController {
    // MARK: getObservable(with:) -> Observable<JSON>
    func getObservable() -> Observable<JSON> {
        return Observable<JSON>.create { (observer) -> Disposable in
            guard let url = URL.init(string: "https://api.github.com/") else {
                let err = TError.init(errorCode: 10, errorString: "url error", errorData: nil)
                observer.onError(err)
                return Disposables.create()
            }
            let request = URLRequest.init(url: url)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let err = error {
                    observer.onError(err)
                    return
                }
                
                guard let jsonData = data, let jsonObj = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) else {
                    let err = TError.init(errorCode: 11, errorString: "json error", errorData: data)
                    observer.onError(err)
                    return
                }
                observer.onNext(jsonObj)
                observer.onCompleted()
            })
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

// MARK: Test
extension DisposableViewController {
    
    // MARK: DisposeTime
    @IBAction func testDisposeTime() {
        // observer.onCompleted()之后会直接dispose
        // 如果一直没 onCompleted(), 调用dispose()才会dispose
        // 如果一直没 onCompleted(), 调用disposed(by: disposeBag), disposeBag释放时候才会dispose
        
        // Observable 1: 不发送 .onCompleted() 不调用 .dispose()
        _ = Observable<String>
            .create({ (observer) -> Disposable in
                observer.onNext(
                    """
                    \n
                    Observable 1: 不发送 .onCompleted() 不调用 .dispose()
                    \t\t\t 永远不会释放
                    """
                )
                return Disposables.create {
                    print("Observable 1: Now Dispose")
                }
            })
            .subscribe(onNext: { (s) in
                print(s)
            })
        
        // Observable 2: 会发送 .onCompleted() 的 Observable
        _ = Observable<String>
            .create({ (observer) -> Disposable in
                observer.onNext(
                    """
                    \n
                    Observable 2: 会发送 .onCompleted() 的 Observable
                    \t\t\t 完成后就会释放
                    """
                )
                observer.onCompleted()
                return Disposables.create {
                    print("Observable 2: Now Dispose")
                }
            })
            .subscribe(onNext: { (s) in
                print(s)
            })
        
        // Observable 3: 不发送 .onCompleted() , 调用 .dispose()
        Observable<String>
            .create({ (observer) -> Disposable in
                observer.onNext(
                    """
                    \n
                    Observable 3: 不发送 .onCompleted() , 调用 .dispose()
                    \t\t\t 调用 .dispose() 时候释放
                    """
                )
                return Disposables.create {
                    print("Observable 3: Now Dispose")
                }
            })
            .subscribe(onNext: { (s) in
                print(s)
            })
            .dispose()
        
        // Observable 4: 不发送 .onCompleted() , 调用 .disposed(by: disposeBag)
        Observable<String>
            .create({ (observer) -> Disposable in
                observer.onNext(
                    """
                    \n
                    Observable 4: 不发送 .onCompleted() , 调用 .disposed(by: disposeBag)
                    \t\t\t disposeBag释放时候(VC deinit之后)释放
                    """
                )
                return Disposables.create {
                    print("Observable 4: Now Dispose")
                }
            })
            .subscribe(onNext: { (s) in
                print(s)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Dispose
    @IBAction func testDispose() {
        for i in 1...4 {
            Observable<String>
                .create({ (observer) -> Disposable in
                    observer.onNext("Observable \(i) onNext")
                    return Disposables.create {
                        print("Observable \(i): Now Dispose")
                    }
                })
                .subscribe({ (e) in
                    print(e)
                })
                .dispose()
        }
    }
    
    // MARK: DisposeBag
    @IBAction func testDisposeBag() {
        let funcDisposeBag = DisposeBag()
        for i in 1...4 {
            Observable<String>
                .create({ (observer) -> Disposable in
                    observer.onNext("Observable \(i) onNext")
                    return Disposables.create {
                        print("Observable \(i) Now Dispose")
                    }
                })
                .subscribe({ (e) in
                    print(e)
                })
                .disposed(by: funcDisposeBag)
        }
    }
    
    // MARK: takeUntil
    @IBAction func testTakeUntil() {
        for i in 1...4 {
            let observable = Observable<String>.create({ (observer) -> Disposable in
                observer.onNext("Observable \(i) onNext")
                return Disposables.create {
                    print("Observable \(i): Now Dispose")
                }
            })
            
            _ = observable
                .takeUntil(self.rx.deallocated)
                .subscribe({ (e) in
                    print("Observable \(i): " + e.debugDescription)
                })
        }
    }
}













