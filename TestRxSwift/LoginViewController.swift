//
//  LoginViewController.swift
//  TestRxSwift
//
//  Created by TBD on 2017/12/12.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LoginViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var nameF: UITextField!
    @IBOutlet weak var pwdF: UITextField!
    @IBOutlet weak var nameT: UILabel!
    @IBOutlet weak var pwdT: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
    }
    
    func setupRx() {
        guard let nameF = nameF, let pwdF = pwdF, let nameT = nameT,
            let pwdT = pwdT, let loginBtn = loginBtn else { return }
        
        let nameIsValid = nameF.rx.text.orEmpty.map({ $0.count > 5 })
        let pwdIsValid  =  pwdF.rx.text.orEmpty.map({ $0.count > 5 })
        nameIsValid.bind(to: nameT.rx.isHidden).disposed(by: disposeBag)
        pwdIsValid.bind(to: pwdT.rx.isHidden).disposed(by: disposeBag)
        let loginEnable = Observable.combineLatest(nameIsValid, pwdIsValid, resultSelector: { (n1, p1) -> (Bool) in
            return n1 && p1
        })
        loginEnable.bind(to: loginBtn.rx.isEnabled).disposed(by: disposeBag)
        
        let nameAndPwd = Observable.combineLatest(nameF.rx.text.orEmpty, pwdF.rx.text.orEmpty) { (nt, pt) -> (String, String)  in
            return (nt, pt)
        }
        let rxUser = loginBtn.rx.tap.withLatestFrom(nameAndPwd)
    }

}
