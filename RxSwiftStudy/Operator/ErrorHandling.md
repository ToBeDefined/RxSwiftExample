
## 错误处理操作符 - ErrorHandling Operator

### catchError

`catchError` 操作符将会拦截一个 `error` 事件，将它替换成其他的元素或者一组元素，然后传递给观察者。这样可以使得 `Observable` 正常结束，或者根本都不需要结束。

eg:

```swift
func catchError() {
    let recoverObservable = Observable<String>.just("Recover Error")
    getErrorObservable()
        .catchError({ (error) -> Observable<String> in
            print("\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
            error.printLog()
            print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n")
            return recoverObservable
        })
        .debug("catchError")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 13:50:58.068: catchError -> subscribed
2017-12-27 13:50:59.070: catchError -> Event next(1️⃣)
2017-12-27 13:51:00.070: catchError -> Event next(2️⃣)

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
10
Test
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

2017-12-27 13:51:01.070: catchError -> Event next(Recover Error)
2017-12-27 13:51:01.070: catchError -> Event completed
2017-12-27 13:51:01.070: catchError -> isDisposed
```

### catchErrorJustReturn

`catchErrorJustReturn` 操作符会将 `error` 事件替换成其他的一个元素，然后结束该序列。

eg:

```swift
func catchErrorJustReturn() {
    getErrorObservable()
        .catchErrorJustReturn("Recover Error")
        .debug("catchErrorJustReturn")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 13:53:16.850: catchErrorJustReturn -> subscribed
2017-12-27 13:53:17.854: catchErrorJustReturn -> Event next(1️⃣)
2017-12-27 13:53:18.852: catchErrorJustReturn -> Event next(2️⃣)
2017-12-27 13:53:19.854: catchErrorJustReturn -> Event next(Recover Error)
2017-12-27 13:53:19.854: catchErrorJustReturn -> Event completed
2017-12-27 13:53:19.854: catchErrorJustReturn -> isDisposed
```

### retry

如果源 `Observable` 产生一个错误事件，重新对它进行订阅，希望它不会再次产生错误
`retry` 操作符将不会将 `error` 事件，传递给观察者。

然而，它会从新订阅源 `Observable`，给这个 `Observable` 一个重试的机会，让它有机会不产生 error 事件。

`retry` 总是对观察者发出 `next` 事件，即便源序列产生了一个 `error` 事件，所以这样可能会产生重复的元素。

```swift
func retry() {
    let observable = Observable<Int>.create { (observer) -> Disposable in
        if arc4random() % 10 == 0 {
            observer.onNext(1)
        } else {
            let error = TError.init(errorCode: 10, errorString: "Random Error", errorData: nil)
            observer.onError(error)
        }
        return Disposables.create()
    }
    observable
        .debug("Befor Retry")
        .retry()
        .debug("After Retry")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 13:56:42.068: After Retry -> subscribed
2017-12-27 13:56:42.068: Befor Retry -> subscribed
2017-12-27 13:56:42.068: Befor Retry -> Event error(TError(errorCode: 10, errorString: "Random Error", errorData: nil))
2017-12-27 13:56:42.068: Befor Retry -> isDisposed
2017-12-27 13:56:42.068: Befor Retry -> subscribed
2017-12-27 13:56:42.068: Befor Retry -> Event error(TError(errorCode: 10, errorString: "Random Error", errorData: nil))
2017-12-27 13:56:42.069: Befor Retry -> isDisposed
2017-12-27 13:56:42.069: Befor Retry -> subscribed
2017-12-27 13:56:42.069: Befor Retry -> Event error(TError(errorCode: 10, errorString: "Random Error", errorData: nil))
2017-12-27 13:56:42.069: Befor Retry -> isDisposed
2017-12-27 13:56:42.069: Befor Retry -> subscribed
2017-12-27 13:56:42.069: Befor Retry -> Event error(TError(errorCode: 10, errorString: "Random Error", errorData: nil))
2017-12-27 13:56:42.069: Befor Retry -> isDisposed
2017-12-27 13:56:42.069: Befor Retry -> subscribed
2017-12-27 13:56:42.069: Befor Retry -> Event error(TError(errorCode: 10, errorString: "Random Error", errorData: nil))
2017-12-27 13:56:42.069: Befor Retry -> isDisposed
2017-12-27 13:56:42.069: Befor Retry -> subscribed
2017-12-27 13:56:42.069: Befor Retry -> Event error(TError(errorCode: 10, errorString: "Random Error", errorData: nil))
2017-12-27 13:56:42.069: Befor Retry -> isDisposed
2017-12-27 13:56:42.069: Befor Retry -> subscribed
2017-12-27 13:56:42.070: Befor Retry -> Event next(1)
2017-12-27 13:56:42.070: After Retry -> Event next(1)
```


### retryWhen

这个操作符主要描述应该在何时重试，并且通过闭包里面返回的 `Observable` 来控制重试的时机：

闭包里面的参数是 `Observable<Error>` 也就是所产生错误的序列，然后返回值是一个 `Observable`。

- 当这个返回的 Observable 发出一个元素时，就进行重试操作。
- 当它发出一个 error 或者 completed 事件时，就不会重试，并且将这个事件传递给到后面的观察者。

```swift
func retryWhen() {
    let observable = Observable<Int>.create { (observer) -> Disposable in
        if arc4random() % 10 == 0 {
            observer.onNext(1)
        } else {
            let error = TError.init(errorCode: 10, errorString: "Random Error", errorData: nil)
            observer.onError(error)
        }
        return Disposables.create()
    }
    
    let retryDelay: RxTimeInterval = 1.0
    let maxRetryCount: Int = 4
    observable
        .debug("Befor RetryWhen")
        .retryWhen({ (rxError) -> Observable<Int> in
            return rxError.enumerated().flatMap({ (index, element) -> Observable<Int> in
                if index >= maxRetryCount {
                    let err = TError.init(errorCode: 0, errorString: "Retry Too Many Times", errorData: nil)
                    return Observable.error(err)
                }
                return Observable.timer(retryDelay, scheduler: MainScheduler.instance)
            })
        })
        .debug("After RetryWhen")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 13:59:37.270: After RetryWhen -> subscribed
2017-12-27 13:59:37.270: Befor RetryWhen -> subscribed
2017-12-27 13:59:37.270: Befor RetryWhen -> Event error(TError(errorCode: 10, errorString: "Random Error", errorData: nil))
2017-12-27 13:59:37.271: Befor RetryWhen -> isDisposed
2017-12-27 13:59:38.271: Befor RetryWhen -> subscribed
2017-12-27 13:59:38.272: Befor RetryWhen -> Event error(TError(errorCode: 10, errorString: "Random Error", errorData: nil))
2017-12-27 13:59:38.272: Befor RetryWhen -> isDisposed
2017-12-27 13:59:39.273: Befor RetryWhen -> subscribed
2017-12-27 13:59:39.273: Befor RetryWhen -> Event next(1)
2017-12-27 13:59:39.273: After RetryWhen -> Event next(1)
```



