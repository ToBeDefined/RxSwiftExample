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

func delayTime(_ delayTime: TimeInterval, block: (() -> ())? ) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {
        block?()
    }
}

class OperatorTableViewController: TTableViewController {
    
    struct DataModel {
        var text: String?
        var selector: Selector?
        
        init(text: String, selector: Selector) {
            self.text = text
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
            SectionModel.init(model: "1", items: [
                DataModel.init(text: "amb", selector: #selector(amb)),
                DataModel.init(text: "buffer", selector: #selector(buffer)),
                DataModel.init(text: "catchError", selector: #selector(catchError)),
                DataModel.init(text: "catchErrorJustReturn", selector: #selector(catchErrorJustReturn)),
                DataModel.init(text: "combineLatest", selector: #selector(combineLatest)),
                DataModel.init(text: "concat", selector: #selector(concat)),
                DataModel.init(text: "concatMap", selector: #selector(concatMap)),
                DataModel.init(text: "connect", selector: #selector(connect)),
                DataModel.init(text: "create", selector: #selector(create)),
                DataModel.init(text: "debounce", selector: #selector(debounce)),
                DataModel.init(text: "debug", selector: #selector(debug)),
                ]),
            SectionModel.init(model: "2", items: [
                DataModel.init(text: "defer", selector: #selector(`defer`)),
                DataModel.init(text: "delay", selector: #selector(delay)),
                DataModel.init(text: "delaySubscription", selector: #selector(delaySubscription)),
                ]),
            SectionModel.init(model: "3", items: [
                DataModel.init(text: "materialize", selector: #selector(materialize)),
                DataModel.init(text: "dematerialize", selector: #selector(dematerialize)),
                ])
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
            delayTime(0.11, block: {
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
            print("> Send onNext(\"1️⃣\")")
            observer.onNext("1️⃣")
            
            delayTime(1, block: {
                print("> Send onNext(\"2️⃣\")")
                observer.onNext("2️⃣")
            })
            
            delayTime(2, block: {
                print("> Send onNext(\"3️⃣\")")
                observer.onNext("3️⃣")
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

extension OperatorTableViewController {
    // MARK: amb
    @objc func amb() {
        // 当你传入多个 Observables 到 amb 操作符时
        // 它将取其中一个 Observable：第一个产生事件的那个 Observable
        // 可以是一个 next，error 或者 completed 事件
        // amb 将忽略掉其他的 Observables。
        
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
    
    // MARK: buffer
    @objc func buffer() {
        // buffer 操作符将缓存 Observable 中发出的新元素
        // 当元素达到某个数量，或者经过了特定的时间，它就会将这个元素集合发送出来。
        getFirstObservable()
            .buffer(timeSpan: 1, count: 2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (strArr) in
                print(strArr)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: catchError
    @objc func catchError() {
        // catchError 操作符将会拦截一个 error 事件，将它替换成其他的元素或者一组元素，然后传递给观察者。
        // 这样可以使得 Observable 正常结束，或者根本都不需要结束。
        
        let recoverObservable = Observable<String>.just("Recover Error")
        getErrorObservable()
            .catchError({ (error) -> Observable<String> in
                print("\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
                error.printLog()
                print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n")
                return recoverObservable
            })
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: catchErrorJustReturn
    @objc func catchErrorJustReturn() {
        // catchErrorJustReturn 操作符会将error 事件替换成其他的一个元素，然后结束该序列。
        getErrorObservable()
            .catchErrorJustReturn("Recover Error")
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: combineLatest
    @objc func combineLatest() {
        // combineLatest 操作符将多个 Observables 中最新的元素通过一个函数组合起来，然后将这个组合的结果发出来。
        // 这些源 Observables 中任何一个发出一个元素，他都会发出一个元素（前提是，这些 Observables 曾经发出过元素）。
        Observable<String>
            .combineLatest(getFirstObservable(), getSecondObservable(), resultSelector: { (fstr, sstr) -> String in
                return fstr + " | " + sstr
            })
            .debug()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    // MARK: concat
    @objc func concat() {
        // concat 操作符将多个 Observables 按顺序串联起来，当前一个 Observable 元素发送完毕后，后一个 Observable 才可以开始发出元素。
        // concat 将等待前一个 Observable 产生完成事件后，才对后一个 Observable 进行订阅。
        // 如果后一个是“热” Observable ，在它前一个 Observable 产生完成事件前，所产生的元素将不会被发送出来。
        getFirstObservable()
            .concat(getSecondObservable())
            .concat(getThirdObservable())
            .debug()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    // MARK: concatMap
    @objc func concatMap() {
        // concatMap 操作符将源 Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。
        // 然后让这些 Observables 按顺序的发出元素，当前一个 Observable 元素发送完毕后，后一个 Observable 才可以开始发出元素。
        // 等待前一个 Observable 产生完成事件后，才对后一个 Observable 进行订阅。
        let subject1 = BehaviorSubject(value: "🍎")
        let subject2 = BehaviorSubject(value: "🐶")
        let variable = Variable(subject1)
        
        variable.asObservable()
            .concatMap { $0 }
            .subscribe { print($0) }
            .disposed(by: disposeBag)
        
        subject1.onNext("🍐")
        subject1.onNext("🍊")
        variable.value = subject2
        subject2.onNext("I would be ignored")
        subject2.onNext("🐱")
        subject1.onCompleted()
        subject2.onNext("🐭")
    }
    
    // MARK: connect
    @objc func connect() {
        // 通知可被连接的 Observable 可以开始发出元素了
        // 可被连接的 Observable 和普通的 Observable 十分相似
        // 不过在被订阅后不会发出元素，直到 connect 操作符被应用为止。
        // 这样一来你可以等所有观察者全部订阅完成后，才发出元素。
        
        // 获取 ConnectableObservable 不可以使用 create 获取，只能通过 ObservableType 调用 publish() 方法获取
        
        let connectableObservable: ConnectableObservable<String> = ConnectableObservable<String>.create({ (observer) -> Disposable in
            observer.onNext("ConnectableObservable -> 1")
            observer.onNext("ConnectableObservable -> 2")
            observer.onNext("ConnectableObservable -> 3")
            delayTime(2, block: {
                observer.onNext("ConnectableObservable -> delay -> 1")
            })
            delayTime(4, block: {
                observer.onNext("ConnectableObservable -> delay -> 2")
            })
            return Disposables.create()
        }).publish()
        
        connectableObservable
            .subscribe({ (e) in
                print("First Subscribe : \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
        connectableObservable.connect().disposed(by: disposeBag)
        connectableObservable
            .subscribe({ (e) in
                print("Second Subscribe : \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: create
    @objc func create() {
        // create 操作符将创建一个 Observable，你需要提供一个构建函数，在构建函数里面描述事件（next，error，completed）的产生过程。
        // 通常情况下一个有限的序列，只会调用一次观察者的 onCompleted 或者 onError 方法。并且在调用它们后，不会再去调用观察者的其他方法。
        _ = Observable<String>.create { (observer) -> Disposable in
            observer.onNext("1")
            observer.onNext("2")
            observer.onNext("3")
            observer.onNext("4")
            observer.onNext("5")
            observer.onNext("6")
            observer.onNext("7")
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    // MARK: debounce
    @objc func debounce() {
        // 用于过滤一定时间内发出的高频元素，只发送最后一个
        // debounce 操作符将发出这种元素，在 Observable 产生这种元素后，一段时间内没有新元素产生。
        getFirstObservable()
            .debounce(1, scheduler: MainScheduler.instance)
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: debug
    @objc func debug() {
        // 打印所有的订阅，事件以及销毁信息
        // identifier: 描述， trimOutput: 是否截取最多四十个字符
        getFirstObservable()
            .debug("Test Debug", trimOutput: true)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    // MARK: defer
    @objc func `defer`() {
        // 直到订阅发生，才创建 Observable，并且为每位订阅者创建全新的 Observable
        // > 注意：是延迟创建 Observable ，而不是延迟订阅或者延迟元素的发出时间
        
        // defer 操作符将等待观察者订阅它，才创建一个 Observable，它会通过一个构建函数为每一位订阅者创建新的 Observable。
        // > 注意：看上去每位订阅者都是对同一个 Observable 产生订阅，实际上它们都获得了独立的序列。
        // 并不是像以前一样订阅同一个 Observable，实际为每个订阅者都创建了一个Observable
        
        // 在一些情况下，直到订阅时才创建 Observable 是可以保证拿到的数据都是最新的。
        let observable = Observable<String>.deferred { [unowned self] () -> Observable<String> in
            print("Observable is Create Now")
            return self.getSecondObservable()
        }
        
        delayTime(2) {
            print("First Subscribe Now")
            observable
                .debug("Test Defer: First Subscribe")
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // 测试是否为每位订阅者都创建了 Observable
        delayTime(5) {
            print("Second Subscribe Now")
            observable
                .debug("Test Defer: Second Subscribe")
                .subscribe()
                .disposed(by: self.disposeBag)
        }
    }
    
    // MARK: delay
    @objc func delay() {
        // 将 Observable 的每一个元素拖延一段时间后发出
        // > 注意：是延迟元素的发出时间而不是延迟订阅或者创建 Observable 的时间
        // delay 操作符将修改一个 Observable，它会将 Observable 的所有元素都拖延一段设定好的时间， 然后才将它们发送出来。
        
        getFourthObservable()
            .delay(5, scheduler: MainScheduler.instance)
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: delaySubscription
    @objc func delaySubscription() {
        // delaySubscription 操作符将在经过所设定的时间后，才对 Observable 进行订阅操作。
        // > 注意：是延迟延迟订阅时间，而不是元素的发出时间或者创建 Observable 的时间
        
        print("Create Observable Now")
        getFourthObservable()
            .delaySubscription(5, scheduler: MainScheduler.instance)
            .subscribe({ (e) in
                print(e.debugDescription)
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: materialize
    @objc func materialize() {
        // 通常，一个有限的 Observable 将产生零个或者多个 onNext 事件，然后产生一个 onCompleted 或者 onError 事件。
        // materialize 操作符将 Observable 产生的这些事件全部转换成元素，然后发送出来。
        
        getErrorObservable()
            .materialize()
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: dematerialize
    @objc func dematerialize() {
        // dematerialize 操作符将 materialize 转换后的元素还原
        let materializeObservable = getErrorObservable().materialize()
        materializeObservable
            .dematerialize()
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
    
    
}


