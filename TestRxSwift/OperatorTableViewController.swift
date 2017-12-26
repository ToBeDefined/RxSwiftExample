//
//  OperatorTableViewController.swift
//  TestRxSwift
//
//  Created by 邵伟男 on 2017/12/19.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class OperatorTableViewController: TTableViewController {
    struct DataModel {
        var text: String? {
            return self.selector?.description
        }
        var selector: Selector?
        init(_ selector: Selector) {
            self.selector = selector
        }
    }
    
    let dataArray: Variable<[DataModel]> = Variable([])
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let dataArray = [
            SectionModel.init(model: "Debug", items: [
                DataModel.init(#selector(debug)),
                DataModel.init(#selector(`do`)),
                ]),
            SectionModel.init(model: "创建 Observable", items: [
                DataModel.init(#selector(create)),
                DataModel.init(#selector(never)),
                DataModel.init(#selector(empty)),
                DataModel.init(#selector(just)),
                DataModel.init(#selector(error)),
                DataModel.init(#selector(from)),
                DataModel.init(#selector(of)),
                DataModel.init(#selector(range)),
                DataModel.init(#selector(repeatElement)),
                DataModel.init(#selector(`defer`)),
                DataModel.init(#selector(interval)),
                DataModel.init(#selector(timer)),
                ]),
            SectionModel.init(model: "变换 Observable", items: [
                DataModel.init(#selector(toArray)),
                DataModel.init(#selector(map)),
                DataModel.init(#selector(scan)),
                DataModel.init(#selector(flatMap)),
                DataModel.init(#selector(flatMapFirst)),
                DataModel.init(#selector(flatMapLatest)),
                DataModel.init(#selector(flatMapWithIndex)),
                DataModel.init(#selector(concatMap)),
                DataModel.init(#selector(buffer)),
                DataModel.init(#selector(window)),
                DataModel.init(#selector(groupBy)),
                ]),
            SectionModel.init(model: "过滤 Observable", items: [
                DataModel.init(#selector(ignoreElements)),
                DataModel.init(#selector(elementAt)),
                DataModel.init(#selector(filter)),
                DataModel.init(#selector(debounce)),
                DataModel.init(#selector(throttle)),
                DataModel.init(#selector(distinctUntilChanged)),
                DataModel.init(#selector(sample)),
                DataModel.init(#selector(skip)),
                DataModel.init(#selector(skipWhile)),
                DataModel.init(#selector(skipUntil)),
                DataModel.init(#selector(take)),
                DataModel.init(#selector(takeLast)),
                DataModel.init(#selector(takeWhile)),
                DataModel.init(#selector(takeUntil)),
                DataModel.init(#selector(single)),
                ]),
            SectionModel.init(model: "联合 Observable", items: [
                DataModel.init(#selector(merge)),
                DataModel.init(#selector(startWith)),
//                 DataModel.init(#selector(switchLatest)),
                DataModel.init(#selector(combineLatest)),
                DataModel.init(#selector(zip)),
                DataModel.init(#selector(withLatestFrom)),
                ]),
            SectionModel.init(model: "错误处理操作符", items: [
                DataModel.init(#selector(catchError)),
                DataModel.init(#selector(catchErrorJustReturn)),
                DataModel.init(#selector(retry)),
                DataModel.init(#selector(retryWhen)),
                ]),
            
            SectionModel.init(model: "条件和 Bool 操作符", items: [
                DataModel.init(#selector(amb)),
                // 过滤 Observable
                DataModel.init(#selector(skipWhile)),
                DataModel.init(#selector(skipUntil)),
                DataModel.init(#selector(takeWhile)),
                DataModel.init(#selector(takeUntil)),
                ]),
            
            SectionModel.init(model: "数学和聚合操作符", items: [
                DataModel.init(#selector(concat)),
                DataModel.init(#selector(reduce)),
                ]),
            SectionModel.init(model: "连接 Observable 操作符", items: [
//                 DataModel.init(#selector(multicast)),
                DataModel.init(#selector(publish)),
                DataModel.init(#selector(connect)),
                DataModel.init(#selector(refCount)),
                DataModel.init(#selector(replay)),
                DataModel.init(#selector(shareReplay)),
                ]),
            SectionModel.init(model: "About Time", items: [
                DataModel.init(#selector(delay)),
                DataModel.init(#selector(delaySubscription)),
                DataModel.init(#selector(timeout)),
                // 创建 Observable
                DataModel.init(#selector(`defer`)),
                DataModel.init(#selector(timer)),
                ]),
            SectionModel.init(model: "Scheduler", items: [
                DataModel.init(#selector(observeOn)),
                DataModel.init(#selector(subscribeOn)),
                ]),
            SectionModel.init(model: "Materialize", items: [
                DataModel.init(#selector(materialize)),
                DataModel.init(#selector(dematerialize)),
                ]),
            SectionModel.init(model: "Using", items: [
                DataModel.init(#selector(using)),
                ]),
            ]
        let dataArrayObservable = Observable<[SectionModel<String, DataModel>]>.just(dataArray)
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, DataModel>>
            .init(configureCell: { (ds, tv, ip, model) -> UITableViewCell in
                let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: ip)
                cell.textLabel?.text = model.text
                cell.textLabel?.textAlignment = .center
                return cell
            }, titleForHeaderInSection: { (ds, sectionIndex) -> String? in
                let sectionModel = ds.sectionModels[sectionIndex]
                return sectionModel.model
            })
        
        dataArrayObservable
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [unowned self] (index) in
                self.tableView.deselectRow(at: index, animated: true)
                let sectionModel = dataArray[index.section]
                let dataModel = sectionModel.items[index.row]
                if let selector = dataModel.selector {
                    self.perform(selector)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension OperatorTableViewController {
    func getFirstObservable() -> Observable<String> {
        return Observable<String>.create({ (observer) -> Disposable in
            // section 1
            delayTime(1, block: {
                observer.onNext("First -> 1|A")
                observer.onNext("First -> 1|B")
                observer.onNext("First -> 1|C")
            })
            
            // section 2
            delayTime(5, block: {
                observer.onNext("First -> 2|A")
                observer.onNext("First -> 2|B")
                observer.onNext("First -> 2|C")
            })
            
            // section 3
            delayTime(9, block: {
                observer.onNext("First -> 3|A")
                observer.onNext("First -> 3|B")
                observer.onNext("First -> 3|C")
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    func getSecondObservable() -> Observable<String> {
        return Observable<String>.create({ (observer) -> Disposable in
            delayTime(0.1, block: {
                observer.onNext("Second -> 1")
                
                delayTime(4, block: {
                    observer.onNext("Second -> 2")
                })
                
                delayTime(8, block: {
                    observer.onNext("Second -> 3")
                    observer.onCompleted()
                })
            })
            return Disposables.create()
        })
    }
    
    func getThirdObservable() -> Observable<String> {
        return Observable<String>.create({ (observer) -> Disposable in
            delayTime(0.1, block: {
                observer.onNext("Third -> 1")
                observer.onNext("Third -> 2")
                observer.onNext("Third -> 3")
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    func getFourthObservable() -> Observable<String> {
        let observable = Observable<String>.create({ (observer) -> Disposable in
            print("> Send onNext(\"0️⃣\")")
            observer.onNext("0️⃣")
            
            delayTime(1, block: {
                print("> Send onNext(\"1️⃣\")")
                observer.onNext("1️⃣")
            })
            
            delayTime(2, block: {
                print("> Send onNext(\"2️⃣\")")
                observer.onNext("2️⃣")
            })
            return Disposables.create()
        })
        return observable
    }
    
    func getErrorObservable() -> Observable<String> {
        return Observable<String>.create({ (observer) -> Disposable in
            delayTime(1, block: {
                observer.onNext("1️⃣")
            })
            delayTime(2, block: {
                observer.onNext("2️⃣")
            })
            delayTime(3, block: {
                let err = TError.init(errorCode: 10, errorString: "Test", errorData: nil)
                observer.onError(err)
            })
            return Disposables.create()
        })
    }
}


