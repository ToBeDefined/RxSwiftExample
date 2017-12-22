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
            SectionModel.init(model: "Debug Observable", items: [
                DataModel.init(#selector(debug)),
                ]),
            SectionModel.init(model: "Error Handling", items: [
                DataModel.init(#selector(catchError)),
                DataModel.init(#selector(catchErrorJustReturn)),
                ]),
            SectionModel.init(model: "Observable Subscribe", items: [
                DataModel.init(#selector(publish)),
                DataModel.init(#selector(connect)),
                DataModel.init(#selector(refCount)),
                DataModel.init(#selector(`do`)),
                ]),
            SectionModel.init(model: "Create Observable", items: [
                DataModel.init(#selector(create)),
                DataModel.init(#selector(never)),
                DataModel.init(#selector(empty)),
                DataModel.init(#selector(error)),
                DataModel.init(#selector(from)),
                DataModel.init(#selector(just)),
                DataModel.init(#selector(of)),
                DataModel.init(#selector(interval)),
                ]),
            SectionModel.init(model: "Event Handling", items: [
                DataModel.init(#selector(ignoreElements)),
                DataModel.init(#selector(debounce)),
                DataModel.init(#selector(distinctUntilChanged)),
                DataModel.init(#selector(filter)),
                DataModel.init(#selector(map)),
                DataModel.init(#selector(buffer)),
                DataModel.init(#selector(elementAt)),
                DataModel.init(#selector(groupBy)),
                DataModel.init(#selector(reduce))
                ]),
            SectionModel.init(model: "More Observable Handling", items: [
                DataModel.init(#selector(amb)),
                DataModel.init(#selector(combineLatest)),
                DataModel.init(#selector(flatMap)),
                DataModel.init(#selector(flatMapLatest)),
                // >> concat
                DataModel.init(#selector(concat)),
                DataModel.init(#selector(concatMap)),
                DataModel.init(#selector(merge)),
                ]),
            SectionModel.init(model: "Delay Sometimes", items: [
                DataModel.init(#selector(`defer`)),
                DataModel.init(#selector(delay)),
                DataModel.init(#selector(delaySubscription)),
                ]),
            SectionModel.init(model: "Scheduler", items: [
                DataModel.init(#selector(observeOn)),
                DataModel.init(#selector(subscribeOn)),
                ]),
            SectionModel.init(model: "Materialize", items: [
                DataModel.init(#selector(materialize)),
                DataModel.init(#selector(dematerialize)),
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

extension OperatorTableViewController {
    // MARK: amb
    // 当你传入多个 Observables 到 amb 操作符时
    // 它将取其中一个 Observable：第一个产生事件的那个 Observable
    // 可以是一个 next，error 或者 completed 事件
    // amb 将忽略掉其他的 Observables。
    @objc func amb() {
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
    // buffer 操作符将缓存 Observable 中发出的新元素
    // 当元素达到某个数量，或者经过了特定的时间，它就会将这个元素集合发送出来。
    @objc func buffer() {
        getFirstObservable()
            .buffer(timeSpan: 1, count: 2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (strArr) in
                print(strArr)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: catchError
    // catchError 操作符将会拦截一个 error 事件，将它替换成其他的元素或者一组元素，然后传递给观察者。
    // 这样可以使得 Observable 正常结束，或者根本都不需要结束。
    @objc func catchError() {
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
    // catchErrorJustReturn 操作符会将error 事件替换成其他的一个元素，然后结束该序列。
    @objc func catchErrorJustReturn() {
        getErrorObservable()
            .catchErrorJustReturn("Recover Error")
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: combineLatest
    // combineLatest 操作符将多个 Observables 中最新的元素通过一个函数组合起来，然后将这个组合的结果发出来。
    // 这些源 Observables 中任何一个发出一个元素，他都会发出一个元素（前提是，这些 Observables 曾经发出过元素）。
    @objc func combineLatest() {
        Observable<String>
            .combineLatest(getFirstObservable(), getSecondObservable(), resultSelector: { (fstr, sstr) -> String in
                return fstr + " | " + sstr
            })
            .debug()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    // MARK: concat
    // concat 操作符将多个 Observables 按顺序串联起来，当前一个 Observable 元素发送完毕后，后一个 Observable 才可以开始发出元素。
    // concat 将等待前一个 Observable 产生完成事件后，才对后一个 Observable 进行订阅。
    // 如果后一个是“热” Observable ，在它前一个 Observable 产生完成事件前，所产生的元素将不会被发送出来。
    @objc func concat() {
        getFirstObservable()
            .concat(getSecondObservable())
            .concat(getThirdObservable())
            .debug()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    // MARK: concatMap
    // concatMap 操作符将源 Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。
    // 然后让这些 Observables 按顺序的发出元素，当前一个 Observable 元素发送完毕后，后一个 Observable 才可以开始发出元素。
    // 等待前一个 Observable 产生完成事件后，才对后一个 Observable 进行订阅。
    @objc func concatMap() {
        
        getFirstObservable()
            .concatMap({ (str) -> Observable<String> in
                return Observable.of("\(str) + 1️⃣", "\(str) + 2️⃣", "\(str) + 3️⃣", "======================")
            })
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: connect
    // 通知可被连接的 Observable 可以开始发出元素了
    // 可被连接的 Observable 和普通的 Observable 十分相似
    // 不过在被订阅后不会发出元素，直到 connect 操作符被应用为止。
    // 这样一来你可以等所有观察者全部订阅完成后，才发出元素。
    // 获取 ConnectableObservable 不可以使用 create 获取，只能通过 ObservableType 调用 publish() 方法获取
    @objc func connect() {
        let connectableObservable = ConnectableObservable<String>
            .create({ (observer) -> Disposable in
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
            })
            .publish()
        
        connectableObservable
            .subscribe({ (e) in
                print("First Subscribe : \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
        connectableObservable
            .connect()
            .disposed(by: disposeBag)
        connectableObservable
            .subscribe({ (e) in
                print("Second Subscribe : \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: create
    // create 操作符将创建一个 Observable，你需要提供一个构建函数，在构建函数里面描述事件（next，error，completed）的产生过程。
    // 通常情况下一个有限的序列，只会调用一次观察者的 onCompleted 或者 onError 方法。并且在调用它们后，不会再去调用观察者的其他方法。
    @objc func create() {
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
    // 用于过滤一定时间内发出的高频元素，只发送最后一个
    // debounce 操作符将发出这种元素，在 Observable 产生这种元素后，一段时间内没有新元素产生。
    @objc func debounce() {
        getFirstObservable()
            .debounce(1, scheduler: MainScheduler.instance)
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: debug
    // 打印所有的订阅，事件以及销毁信息
    @objc func debug() {
        // identifier: 描述， trimOutput: 是否截取最多四十个字符
        getFirstObservable()
            .debug("Test Debug", trimOutput: true)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    // MARK: defer
    // 直到订阅发生，才创建 Observable，并且为每位订阅者创建全新的 Observable
    // > ⚠️注意：是延迟创建 Observable ，而不是延迟订阅或者延迟元素的发出时间
    // defer 操作符将等待观察者订阅它，才创建一个 Observable，它会通过一个构建函数为每一位订阅者创建新的 Observable。
    // > ⚠️注意：看上去每位订阅者都是对同一个 Observable 产生订阅，实际上它们都获得了独立的序列。
    // 并不是像以前一样订阅同一个 Observable，实际为每个订阅者都创建了一个Observable
    // 在一些情况下，直到订阅时才创建 Observable 是可以保证拿到的数据都是最新的。
    @objc func `defer`() {
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
    // 将 Observable 的每一个元素拖延一段时间后发出
    // > ⚠️注意：是延迟元素的发出时间而不是延迟订阅或者创建 Observable 的时间
    // delay 操作符将修改一个 Observable，它会将 Observable 的所有元素都拖延一段设定好的时间， 然后才将它们发送出来。
    @objc func delay() {
        getFourthObservable()
            .delay(5, scheduler: MainScheduler.instance)
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: delaySubscription
    // delaySubscription 操作符将在经过所设定的时间后，才对 Observable 进行订阅操作。
    // > ⚠️注意：是延迟延迟订阅时间，而不是元素的发出时间或者创建 Observable 的时间
    @objc func delaySubscription() {
        print("Create Observable Now")
        getFourthObservable()
            .delaySubscription(5, scheduler: MainScheduler.instance)
            .subscribe({ (e) in
                print(e.debugDescription)
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: materialize
    // 通常，一个有限的 Observable 将产生零个或者多个 onNext 事件，然后产生一个 onCompleted 或者 onError 事件。
    // materialize 操作符将 Observable 产生的这些事件全部转换成元素，然后发送出来。
    @objc func materialize() {
        getErrorObservable()
            .materialize()
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: dematerialize
    // dematerialize 操作符将 materialize 转换后的元素还原
    @objc func dematerialize() {
        let materializeObservable = getErrorObservable().materialize()
        materializeObservable
            .dematerialize()
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: distinctUntilChanged
    // distinctUntilChanged 操作符将阻止 Observable 发出相同的元素。
    // 如果后一个元素和前一个元素是相同的，那么这个元素将不会被发出来。
    // 如果后一个元素和前一个元素不相同，那么这个元素才会被发出来。
    @objc func distinctUntilChanged() {
        let observable = Observable.of("🐱", "🐷", "🐱", "🐱", "🐱", "🐵", "🐵", "🐵", "🐵", "🐱")
        observable
            .distinctUntilChanged()
            .debug("distinctUntilChanged")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    // MARK: do
    // 当 Observable 产生某些事件时，执行某个操作
    // 当 Observable 的某些事件产生时，你可以使用 do 操作符来注册一些回调操作。
    // 这些回调会被单独调用，它们会和 Observable 原本的回调分离。
    @objc func `do`() {
        let observable = Observable<String>.create({ (observer) -> Disposable in
            delayTime(1, block: {
                observer.onNext("1️⃣")
            })
            
            delayTime(2, block: {
                observer.onNext("2️⃣")
            })
            
            delayTime(3, block: {
                observer.onNext("3️⃣")
            })
            return Disposables.create()
        })
        
        observable
            .do(onNext: { (str) in
                print("do --> " + str)
            }, onError: { (error) in
                print("do --> ")
                error.printLog()
            }, onCompleted: {
                print("do --> onCompleted")
            }, onSubscribe: {
                print("do --> onSubscribe")
            }, onSubscribed: {
                print("do --> onSubscribed")
            }, onDispose: {
                print("do --> onDispose")
            })
            .subscribe({ (e) in
                print("in subscribe --> \(e)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: elementAt
    // elementAt 操作符将拉取 Observable 序列中指定索引数的元素，然后将它作为唯一的元素发出。
    @objc func elementAt() {
        getFourthObservable()
            .elementAt(1)
            .subscribe({ (e) in
                print("elementAt subscribe -> \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: empty
    // 创建一个空 Observable
    // empty 操作符将创建一个 Observable，这个 Observable 只有一个完成事件。
    @objc func empty() {
        let observable = Observable<String>.empty()
        // 相当于以下代码
        // let observable = Observable<String>.create { observer in
        //     observer.onCompleted()
        //     return Disposables.create()
        // }
        observable
            .debug("Empty")
            .subscribe()
            .disposed(by: disposeBag)
        
    }
    
    // MARK: error
    // 创建一个只有 error 事件的 Observable
    // error 操作符将创建一个 Observable，这个 Observable 只会产生一个 error 事件。
    @objc func error() {
        let err = TError.init(errorCode: 10, errorString: "test error", errorData: nil)
        let observable = Observable<String>.error(err)
        // 相当于以下代码
        // let err = TError.init(errorCode: 10, errorString: "test error", errorData: nil)
        // let id = Observable<Int>.create { observer in
        //     observer.onError(err)
        //     return Disposables.create()
        // }
        observable
            .subscribe({ (e) in
                print("Error --> \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: filter
    // filter 操作符将通过你提供的判定方法过滤一个 Observable。
    // 仅仅发出 Observable 中通过判定的元素
    @objc func filter() {
        Observable
            .of(21, 3, 15, 50, 4, 23, 90, 11)
            .debug("Filter    : ")
            .filter({ (value) -> Bool in
                return value >= 20
            })
            .debug("Subscribe : ")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    // MARK: flatMap
    // 将 Observable 的元素转换成其他的 Observable，然后将这些 Observables 合并
    // flatMap 操作符将源 Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。
    // 然后将这些 Observables 的元素合并之后再发送出来。
    // 这个操作符是非常有用的，例如，当 Observable 的元素本生拥有其他的 Observable 时，你可以将所有子 Observables 的元素发送出来。
    @objc func flatMap() {
        
        let first = BehaviorSubject(value: "First => 👦🏻")
        let second = BehaviorSubject(value: "Second => 😊")
        let variable = Variable(first)
        
        variable
            .asObservable()
            .flatMap { $0 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        first.onNext("First => 🐱")
        variable.value = second
        second.onNext("Second => 😢")
        first.onNext("First => 🐶")
        first.onNext("First => 🐱")
        second.onNext("Second => 😂")
    }
    
    // MARK: flatMapLatest
    // 将 Observable 的元素转换成其他的 Observable，然后取这些 Observables 中最新的一个
    // flatMapLatest 操作符将源 Observable 的每一个元素应用一个转换方法，将他们转换成 Observables。
    // 一旦转换出一个新的 Observable，就只发出它的元素，旧的 Observables 的元素将被忽略掉。
    @objc func flatMapLatest() {
        
        let first = BehaviorSubject(value: "First => 👦🏻")
        let second = BehaviorSubject(value: "Second => 😊")
        let variable = Variable(first)
        
        variable
            .asObservable()
            .flatMapLatest { $0 }
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        
        first.onNext("First => 🐱")
        variable.value = second
        second.onNext("Second => 😢")
        first.onNext("First => 🐶")
        first.onNext("First => 🐱")
        second.onNext("Second => 😂")
    }
    
    // MARK: from
    // 将其他类型或者数据结构转换为 Observable
    // 当你在使用 Observable 时，如果能够直接将其他类型转换为 Observable，这将是非常省事的。from 操作符就提供了这种功能。
    // 将一个数组转换为 Observable
    @objc func from() {
        let array = [34, 2, 44, 21, 54]
        let observable = Observable<Int>.from(array)
        // 相当于
        // let observable = Observable<Int>.create { (observer) -> Disposable in
        //     observer.onNext(34)
        //     observer.onNext(2)
        //     observer.onNext(44)
        //     observer.onNext(21)
        //     observer.onNext(54)
        //     observer.onCompleted()
        //     return Disposables.create()
        // }
        observable
            .subscribe({ (e) in
                print("From Array => \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
        
        
        // 将一个可选值转换为 Observable：
        let optionalInt: Int? = 12
        let observableOptional = Observable<Int>.from(optional: optionalInt)
        // 相当于
        // let optionalInt: Int? = 12
        // let observableOptional = Observable<Int>.create { observer in
        //     if let value = optionalInt {
        //         observer.onNext(value)
        //     }
        //     observer.onCompleted()
        //     return Disposables.create()
        // }
        observableOptional
            .subscribe({ (e) in
                print("From Optional => \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: groupBy
    // 将源 Observable 分解为多个子 Observable，并且每个子 Observable 将源 Observable 中“相似”的元素发送出来
    // groupBy 操作符将源 Observable 分解为多个子 Observable，然后将这些子 Observable 发送出来。
    // 它会将元素通过某个键进行分组，然后将分组后的元素序列以 Observable 的形态发送出来。
    @objc func groupBy() {
        enum ObservableValueType {
            case integer
            case string
            case other
        }
        let observable = Observable<Any>.of(1, 2, 3, 4, "22", "23", "34", "54", "12", 44, "112", 65)
        observable
            .groupBy(keySelector: { (value) -> ObservableValueType in
                if value is Int {
                    return ObservableValueType.integer
                }
                if value is String {
                    return ObservableValueType.string
                }
                return ObservableValueType.other
            })
            .subscribe(onNext: { [unowned self] (group) in
                group
                    .subscribe({ (e) in
                        print("\(group.key)\t=> \(e.debugDescription)")
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: ignoreElements
    // 忽略掉所有的元素，只发出 error 或 completed 事件
    // ignoreElements 操作符将阻止 Observable 发出 next 事件，但是允许他发出 error 或 completed 事件。
    // 如果你并不关心 Observable 的任何元素，你只想知道 Observable 在什么时候终止，那就可以使用 ignoreElements 操作符。
    @objc func ignoreElements() {
        getFourthObservable()
            .ignoreElements()
            .debug("ignoreElements")
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    // MARK: interval
    // 创建一个 Observable 每隔一段时间，发出一个索引数
    // interval 操作符将创建一个 Observable，它每隔一段设定的时间，发出一个索引数的元素。它将发出无数个元素。
    @objc func interval() {
        let intervalQueue = DispatchQueue.init(label: "ink.tbd.test.interval")
        Observable<Int>
            .interval(1, scheduler: ConcurrentDispatchQueueScheduler.init(queue: intervalQueue))
            .subscribe({ (e) in
                print("interval => \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: just
    // 创建 Observable 发出唯一的一个元素
    // just 操作符将某一个元素转换为 Observable。
    @objc func just() {
        let justObservable = Observable<String>.just("A String")
        // 相当于：
        // let justObservable = Observable<String>.create { observer in
        //     observer.onNext("A String")
        //     observer.onCompleted()
        //     return Disposables.create()
        // }
        
        justObservable
            .subscribe({ (e) in
                print("just => \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: of
    // of 操作符将某一个元素或多个元素转换为 Observable。
    @objc func of() {
        let ofObservable = Observable.of(1, 2, 3)
        // let ofObservable = Observable.of(1, 2, 3, scheduler: MainScheduler.instance)
        // 相当于:
        // let ofObservable = Observable<Int>.create { observer in
        //     observer.onNext(1)
        //     observer.onNext(2)
        //     observer.onNext(3)
        //     observer.onCompleted()
        //     return Disposables.create()
        // }
        ofObservable
            .subscribe({ (e) in
                print("Of => \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: map
    // 通过一个转换函数，将 Observable 的每个元素转换一遍
    // map 操作符将源 Observable 的每个元素应用你提供的转换方法，然后返回含有转换结果的 Observable。
    @objc func map() {
        let disposeBag = DisposeBag()
        Observable.of(1, 2, 3)
            .map({ (value) -> String in
                return "Value is \(value * 10)"
            })
            .subscribe({ e in
                print("map => \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: merge
    // 将多个 Observables 合并成一个
    // 通过使用 merge 操作符你可以将多个 Observables 合并成一个，当某一个 Observable 发出一个元素时，他就将这个元素发出。
    // 如果，某一个 Observable 发出一个 onError 事件，那么被合并的 Observable 也会将它发出，并且立即终止序列。
    @objc func merge() {
        let subject1 = PublishSubject<String>()
        let subject2 = PublishSubject<String>()
        
        Observable.of(subject1, subject2)
            .merge()
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        subject1.onNext("🅰️")
        subject1.onNext("🅱️")
        subject2.onNext("①")
        subject2.onNext("②")
        subject1.onNext("🆎")
        subject2.onNext("③")
    }
    
    // MARK: never
    // 创建一个永远不会发出元素的 Observable
    // never 操作符将创建一个 Observable，这个 Observable 不会产生任何事件。
    @objc func never() {
        let observable = Observable<Int>.never()
        observable
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: observeOn
    // 指定 Observable 在那个 Scheduler 发出通知
    // ReactiveX 使用 Scheduler 来让 Observable 支持多线程。你可以使用 observeOn 操作符，来指示 Observable 在哪个 Scheduler 发出通知。
    // ⚠️注意：一旦产生了 onError 事件， observeOn 操作符将立即转发。他不会等待 onError 之前的事件全部被收到。这意味着 onError 事件可能会跳过一些元素提前发送出去。
    // subscribeOn 操作符非常相似。它指示 Observable 在哪个 Scheduler 发出执行。
    // 默认情况下，Observable 创建，应用操作符以及发出通知都会在 Subscribe 方法调用的 Scheduler 执行。subscribeOn 操作符将改变这种行为，它会指定一个不同的 Scheduler 来让 Observable 执行，observeOn 操作符将指定一个不同的 Scheduler 来让 Observable 通知观察者。
    // 如上图所示，subscribeOn 操作符指定 Observable 在那个 Scheduler 开始执行，无论它处于链的那个位置。 另一方面 observeOn 将决定后面的方法在哪个 Scheduler 运行。因此，你可能会多次调用 observeOn 来决定某些操作符在哪个线程运行。
    @objc func observeOn() {
        let observable = Observable<Int>.of(1, 2, 3, 4, 5)
        let observeQueue = DispatchQueue.init(label: "ink.tbd.test.observeQueue")
        observable
            .observeOn(ConcurrentDispatchQueueScheduler.init(queue: observeQueue))
            .subscribe({ (e) in
                print("observeOn: \(getCurrentQueueName());  ==>  \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: subscribeOn
    // 指定 Observable 在那个 Scheduler 执行
    // ReactiveX 使用 Scheduler 来让 Observable 支持多线程。你可以使用 subscribeOn 操作符，来指示 Observable 在哪个 Scheduler 执行。
    // observeOn 操作符非常相似。它指示 Observable 在哪个 Scheduler 发出通知。
    // 默认情况下，Observable 创建，应用操作符以及发出通知都会在 Subscribe 方法调用的 Scheduler 执行。subscribeOn 操作符将改变这种行为，它会指定一个不同的 Scheduler 来让 Observable 执行，observeOn 操作符将指定一个不同的 Scheduler 来让 Observable 通知观察者。
    // 如上图所示，subscribeOn 操作符指定 Observable 在那个 Scheduler 开始执行，无论它处于链的那个位置。 另一方面 observeOn 将决定后面的方法在哪个 Scheduler 运行。因此，你可能会多次调用 observeOn 来决定某些操作符在哪个线程运行。
    @objc func subscribeOn() {
        let observable = Observable<Int>.of(1, 2, 3, 4, 5)
        let subscribeQueue = DispatchQueue.init(label: "ink.tbd.test.subscribeQueue")
        observable
            .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: subscribeQueue))
            .subscribe({ (e) in
                print("subscribeOn: \(getCurrentQueueName());  ==>  \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: publish
    // 将 Observable 转换为可被连接的 Observable
    // publish 会将 Observable 转换为可被连接的 Observable。
    // 可被连接的 Observable 和普通的 Observable 十分相似，不过在被订阅后不会发出元素，直到 connect 操作符被应用为止。
    // 这样一来你可以控制 Observable 在什么时候开始发出元素。
    @objc func publish() {
        let connectObservable = Observable.of(1, 2, 3, 4, 5, 6).publish()
        print("> connectObservable subscribe now")
        connectObservable
            .subscribe({ e in
                print("connectObservable => \(e.debugDescription)")
            })
            .disposed(by: disposeBag)
        delayTime(3) {
            print("> connectObservable connect now")
            connectObservable
                .connect()
                .disposed(by: self.disposeBag)
        }
    }
    
    // MARK: reduce
    // 持续的将 Observable 的每一个元素应用一个函数，然后发出最终结果
    // reduce 操作符将对第一个元素应用一个函数。然后，将结果作为参数填入到第二个元素的应用函数中。以此类推，直到遍历完全部的元素后发出最终结果。
    // 这种操作符在其他地方有时候被称作是 accumulator，aggregate，compress，fold 或者 inject。
    @objc func reduce() {
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
    
    // MARK: refCount
    // 将可被连接的 Observable 转换为普通 Observable
    // 可被连接的 Observable 和普通的 Observable 十分相似，不过在被订阅后不会发出元素，直到 connect 操作符被应用为止。
    // 这样一来你可以控制 Observable 在什么时候开始发出元素。
    // refCount 操作符将自动连接和断开可被连接的 Observable。
    // 它将可被连接的 Observable 转换为普通 Observable。
    // 当第一个观察者对它订阅时，那么底层的 Observable 将被连接。当最后一个观察者离开时，那么底层的 Observable 将被断开连接。
    @objc func refCount() {
        let connectObservable = Observable.of(1, 2, 3, 4, 5, 6).publish()
        let observable = connectObservable.refCount()
        observable
            .subscribe({ (e) in
                print(e)
            })
            .disposed(by: disposeBag)
    }
}


