
> Debug Operator

## debug

打印所有的订阅，事件以及销毁信息

eg:

```swift
func debug() {
    getFirstObservable()
        // identifier: 描述， trimOutput: 是否截取最多四十个字符
        .debug("Test Debug", trimOutput: true)
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 09:14:12.680: Test Debug -> subscribed
2017-12-27 09:14:13.683: Test Debug -> Event next(First -> 1|A)
2017-12-27 09:14:13.683: Test Debug -> Event next(First -> 1|B)
2017-12-27 09:14:13.683: Test Debug -> Event next(First -> 1|C)
2017-12-27 09:14:17.683: Test Debug -> Event next(First -> 2|A)
2017-12-27 09:14:17.683: Test Debug -> Event next(First -> 2|B)
2017-12-27 09:14:17.683: Test Debug -> Event next(First -> 2|C)
2017-12-27 09:14:21.683: Test Debug -> Event next(First -> 3|A)
2017-12-27 09:14:21.683: Test Debug -> Event next(First -> 3|B)
2017-12-27 09:14:21.683: Test Debug -> Event next(First -> 3|C)
2017-12-27 09:14:21.683: Test Debug -> Event completed
2017-12-27 09:14:21.683: Test Debug -> isDisposed

```

## do

- 当 `Observable` 产生某些事件时，执行某个操作
- 当 `Observable` 的某些事件产生时，你可以使用 `do` 操作符来注册一些回调操作。
- 这些回调会被单独调用，它们会和 `Observable` 原本的回调分离。


eg:

```swift
func `do`() {
    let observable = Observable<String>.create({ (observer) -> Disposable in
        delayTime(1, block: {
            observer.onNext("1️⃣")
        })
        
        delayTime(2, block: {
            observer.onNext("2️⃣")
        })
        
        delayTime(3, block: {
            observer.onNext("3️⃣")
            observer.onCompleted()
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
```

输出如下：

```swift
do --> onSubscribe
do --> onSubscribed
do --> 1️⃣
in subscribe --> next(1️⃣)
do --> 2️⃣
in subscribe --> next(2️⃣)
do --> 3️⃣
in subscribe --> next(3️⃣)
do --> onCompleted
in subscribe --> completed
do --> onDispose
```



