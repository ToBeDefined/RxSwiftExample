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
    
    override var isShouldPrintDeinitLog: Bool {
        return false
    }
    
    let `operator` = Operator()
    let dataArray: Variable<[DataModel]> = Variable([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let dataArray = [
            SectionModel.init(model: "Debug", items: [
                DataModel.init(#selector(Operator.debug)),
                DataModel.init(#selector(Operator.`do`)),
                ]),
            SectionModel.init(model: "创建 Observable", items: [
                DataModel.init(#selector(Operator.create)),
                DataModel.init(#selector(Operator.never)),
                DataModel.init(#selector(Operator.empty)),
                DataModel.init(#selector(Operator.just)),
                DataModel.init(#selector(Operator.error)),
                DataModel.init(#selector(Operator.from)),
                DataModel.init(#selector(Operator.of)),
                DataModel.init(#selector(Operator.range)),
                DataModel.init(#selector(Operator.repeatElement)),
                DataModel.init(#selector(Operator.`defer`)),
                DataModel.init(#selector(Operator.interval)),
                DataModel.init(#selector(Operator.timer)),
                ]),
            SectionModel.init(model: "变换 Observable", items: [
                DataModel.init(#selector(Operator.toArray)),
                DataModel.init(#selector(Operator.map)),
                DataModel.init(#selector(Operator.scan)),
                DataModel.init(#selector(Operator.flatMap)),
                DataModel.init(#selector(Operator.flatMapFirst)),
                DataModel.init(#selector(Operator.flatMapLatest)),
                DataModel.init(#selector(Operator.flatMapWithIndex)),
                DataModel.init(#selector(Operator.concatMap)),
                DataModel.init(#selector(Operator.buffer)),
                DataModel.init(#selector(Operator.window)),
                DataModel.init(#selector(Operator.groupBy)),
                ]),
            SectionModel.init(model: "过滤 Observable", items: [
                DataModel.init(#selector(Operator.ignoreElements)),
                DataModel.init(#selector(Operator.elementAt)),
                DataModel.init(#selector(Operator.filter)),
                DataModel.init(#selector(Operator.debounce)),
                DataModel.init(#selector(Operator.throttle)),
                DataModel.init(#selector(Operator.distinctUntilChanged)),
                DataModel.init(#selector(Operator.sample)),
                DataModel.init(#selector(Operator.skip)),
                DataModel.init(#selector(Operator.skipWhile)),
                DataModel.init(#selector(Operator.skipUntil)),
                DataModel.init(#selector(Operator.take)),
                DataModel.init(#selector(Operator.takeLast)),
                DataModel.init(#selector(Operator.takeWhile)),
                DataModel.init(#selector(Operator.takeUntil)),
                DataModel.init(#selector(Operator.single)),
                ]),
            SectionModel.init(model: "联合 Observable", items: [
                DataModel.init(#selector(Operator.startWith)),
                DataModel.init(#selector(Operator.combineLatest)),
                DataModel.init(#selector(Operator.zip)),
                DataModel.init(#selector(Operator.withLatestFrom)),
                DataModel.init(#selector(Operator.merge)),
                DataModel.init(#selector(Operator.switchLatest)),
                ]),
            SectionModel.init(model: "错误处理操作符", items: [
                DataModel.init(#selector(Operator.catchError)),
                DataModel.init(#selector(Operator.catchErrorJustReturn)),
                DataModel.init(#selector(Operator.retry)),
                DataModel.init(#selector(Operator.retryWhen)),
                ]),
            
            SectionModel.init(model: "条件和 Bool 操作符", items: [
                DataModel.init(#selector(Operator.amb)),
                // 过滤 Observable
                DataModel.init(#selector(Operator.skipWhile)),
                DataModel.init(#selector(Operator.skipUntil)),
                DataModel.init(#selector(Operator.takeWhile)),
                DataModel.init(#selector(Operator.takeUntil)),
                ]),
            
            SectionModel.init(model: "数学和聚合操作符", items: [
                DataModel.init(#selector(Operator.concat)),
                DataModel.init(#selector(Operator.reduce)),
                ]),
            SectionModel.init(model: "连接 Observable 操作符", items: [
                DataModel.init(#selector(Operator.multicast)),
                DataModel.init(#selector(Operator.publish)),
                DataModel.init(#selector(Operator.connect)),
                DataModel.init(#selector(Operator.refCount)),
                DataModel.init(#selector(Operator.replay)),
                DataModel.init(#selector(Operator.shareReplay)),
                ]),
            SectionModel.init(model: "About Time", items: [
                DataModel.init(#selector(Operator.delay)),
                DataModel.init(#selector(Operator.delaySubscription)),
                DataModel.init(#selector(Operator.timeout)),
                // 创建 Observable
                DataModel.init(#selector(Operator.`defer`)),
                DataModel.init(#selector(Operator.timer)),
                ]),
            SectionModel.init(model: "Scheduler", items: [
                DataModel.init(#selector(Operator.observeOn)),
                DataModel.init(#selector(Operator.subscribeOn)),
                ]),
            SectionModel.init(model: "Materialize", items: [
                DataModel.init(#selector(Operator.materialize)),
                DataModel.init(#selector(Operator.dematerialize)),
                ]),
            SectionModel.init(model: "Using", items: [
                DataModel.init(#selector(Operator.using)),
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
                    self.operator.perform(selector)
                }
            })
            .disposed(by: disposeBag)
    }
}




