import Foundation
import UIKit
import RxSwift
import RxCocoa
import PlaygroundSupport
import XCPlayground

PlaygroundPage.current.needsIndefiniteExecution = true

let disposeBag = DisposeBag()

DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    print("MainQueue")
}
//    let imgO = Observable.just(#imageLiteral(resourceName: "NoSelectRoundBtn"))
//    let imgV = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 20, height: 20))
//    imgO.bind(to: imgV.rx.image).disposed(by: disposeBag)

let numbers: Observable<Int> = Observable<Int>.create({ (observer) -> Disposable in
    observer.onNext(0)
    observer.onNext(1)
    observer.onNext(2)
    observer.onNext(3)
    observer.onNext(4)
    observer.onNext(5)
    observer.onCompleted()
    return Disposables.create()
})



typealias JSON = Any

struct MyError: Error {
    var errorCode: Int?
    var errorString: String?
}

let json = Observable<JSON>.create { (observer) -> Disposable in
    guard let url = URL.init(string: "http://www.baidu.com/") else {
        observer.onError(MyError.init(errorCode: 10, errorString: "url error"))
        return Disposables.create()
    }
    let request = URLRequest.init(url: url)
    let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
        if error != nil {
            observer.onError(error!)
            return
        }
        
        guard let jsonData = data, let jsonObj = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) else {
            observer.onError(MyError.init(errorCode: 11, errorString: "json error"))
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
json.subscribe(onNext: { (json) in
    print("Json success")
}, onError: { (error) in
    print(error.localizedDescription)
}, onCompleted: {
    print("completed")
}).disposed(by: disposeBag)











