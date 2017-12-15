//
//  MainTableViewController.swift
//  TestRxSwift
//
//  Created by 邵伟男 on 2017/12/15.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    var data: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.data = ["Observable",
                     "Observer",
                     "Observer&Observable",
                     "Disposable",
                     "Schedulers"]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func getViewController(with vcName: String) -> UIViewController {
        let realName = vcName.replacingOccurrences(of: "&", with: "_").appending("ViewController")
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: realName)
        return vc
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vcName = data[indexPath.row]
        let vc = getViewController(with: vcName)
        vc.title = vcName
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
