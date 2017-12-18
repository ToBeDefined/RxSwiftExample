//
//  MainTableViewController.swift
//  TestRxSwift
//
//  Created by 邵伟男 on 2017/12/18.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class MainTableViewController: TTableViewController {
    let data: Variable<[UIViewController.Type]> = Variable([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // MARK: 第一种
        //let items = Observable<[SectionModel<String, UIViewController.Type>]>.just([
        //    SectionModel.init(model: "0", items: [
        //        ObservableViewController.self,
        //        ObserverViewController.self,
        //        Observer_ObservableViewController.self,
        //        DisposableViewController.self,
        //        SchedulersViewController.self,
        //        ErrorHandlingViewController.self
        //        ])
        //    ])
        //let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, UIViewController.Type>>
        //    .init(configureCell: { [unowned self] (_, tableView, indexPath, type) -> UITableViewCell in
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //        cell.textLabel?.text = self.getDescriptionString(with: type)
        //        return cell
        //    })
        //
        //items
        //    .asDriver(onErrorJustReturn: [])
        //    .drive(tableView.rx.items(dataSource: dataSource))
        //    .disposed(by: disposeBag)
        
        // MARK: 第二种
        data.value = [ObservableViewController.self,
                      ObserverViewController.self,
                      Observer_ObservableViewController.self,
                      DisposableViewController.self,
                      SchedulersViewController.self,
                      ErrorHandlingViewController.self]
        data
            .asDriver()
            .drive(tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) {
                [unowned self] (row, type, cell) in
                cell.textLabel?.text = self.getDescriptionString(with: type)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [unowned self] (indexPath) in
                let vcType = self.data.value[indexPath.row]
                let vc = self.getViewController(with: vcType)
                vc.title = self.getDescriptionString(with: vcType)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension MainTableViewController {
    func getDescriptionString(with vcType: UIViewController.Type) -> String {
        let vcTypeString = NSStringFromClass(vcType) as String
        var subString = ""
        if let dotIndex = vcTypeString.index(of: ".") {
            let startIndex = vcTypeString.index(after: dotIndex)
            if let endIndex = vcTypeString.range(of: "TableViewController", options: .backwards)?.lowerBound {
                subString = String(vcTypeString[startIndex..<endIndex])
            } else if let endIndex = vcTypeString.range(of: "ViewController", options: .backwards)?.lowerBound {
                subString = String(vcTypeString[startIndex..<endIndex])
            }
        }
        return subString.replacingOccurrences(of: "_", with: "&")
    }
    
    func getViewController(with vcType: UIViewController.Type) -> UIViewController {
        let vcTypeString = NSStringFromClass(vcType) as String
        var subString = ""
        if let dotIndex = vcTypeString.index(of: ".") {
            let startIndex = vcTypeString.index(after: dotIndex)
            subString = String(vcTypeString[startIndex...])
        }
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: subString)

        return vc
    }
}
