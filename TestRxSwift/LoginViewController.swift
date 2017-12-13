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

struct User {
    let id: String
    let nickname: String
    
    // 解析 json
    init?(json: Any) {
        guard
            let dictionary = json as? [String: Any],
            let id = dictionary["id"] as? String,
            let nickname = dictionary["nickname"] as? String
            else {
                return nil
        }
        
        self.id = id
        self.nickname = nickname
    }
}


enum GithubApi {
    public static func login(username: String, password: String) -> Observable<User?> {
        guard let baseURL = URL(string: "https://api.github.com"),
            let url = URL(string: "login?username=\(username)&password=\(password)", relativeTo: baseURL) else {
                return Observable.just(nil)
        }
        
        return URLSession.shared.rx.json(url: url)
            .catchError({ (e) -> Observable<Any> in
                print(e)
                return Observable.just(["id": "10000", "nickname": "luojie"]) // 由于此接口不存在，所以出错就直接返回演示数据
            })
            .map(User.init) // 解析 json
    }
}

class LoginViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var nameF: UITextField!
    @IBOutlet weak var pwdF: UITextField!
    @IBOutlet weak var nameT: UILabel!
    @IBOutlet weak var pwdT: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var imageV: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
        let image = Observable.just(#imageLiteral(resourceName: "NoSelectRoundBtn"))
        imageV.contentMode = .center
        image.subscribeOn(MainScheduler.instance).bind(to: imageV.rx.image).disposed(by: disposeBag)
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
        let rxUser = loginBtn.rx.tap.withLatestFrom(nameAndPwd).do(onNext: { [weak self] (name, pwd) in
            self?.login(name: name, pwd: pwd)
        }).flatMapLatest(GithubApi.login)
        
        rxUser.observeOn(MainScheduler.instance).map ({ (user) -> String in
            return user == nil ? "登录失败，请稍后重试" : "\(user!.nickname) 您已成功登录"
        }).bind(to: loginBtn.rx.title()).disposed(by: disposeBag)
    }
    
    func login(name: String, pwd: String) {
        print("name => \(name), pwd => \(pwd)")
    }

}
