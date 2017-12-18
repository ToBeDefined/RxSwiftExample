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
        
        dataArray
            .asDriver()
            .drive(tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self),
                   curriedArgument: { [unowned self] (row, type, cell) in
                    cell.textLabel?.text = self.dataArray.value[row].text
            })
            .disposed(by: disposeBag)
        tableView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [unowned self] (indexPath) in
                self.tableView.deselectRow(at: indexPath, animated: true)
                if let selector = self.dataArray.value[indexPath.row].selector {
                    self.perform(selector)
                }
            })
            .disposed(by: disposeBag)
        
        dataArray.value = [DataModel.init(text: "test1", selector: #selector(get)),
                           DataModel.init(text: "test2", selector: #selector(get2))]
    }
    
    @objc func get() {
        print(1111)
    }
    
    
    @objc func get2() {
        print(2222)
    }
}
