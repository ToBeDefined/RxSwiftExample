
## 创建 Observable - Create Observable Operator

### create

`create` 操作符将创建一个 `Observable`，你需要提供一个构建函数，在构建函数里面描述事件（`next`，`error`，`completed`）的产生过程。

通常情况下一个有限的序列，只会调用一次观察者的 `onCompleted` 或者 `onError` 方法。并且在调用它们后，不会再去调用观察者的其他方法。

eg:

```swift
func create() {
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
```

### never

创建一个永远不会发出元素的 `Observable`

`never` 操作符将创建一个 `Observable`，这个 `Observable` 不会产生任何事件。

eg:

```swift
func never() {
    let observable = Observable<Int>.never()
    observable
        .subscribe({ (e) in
            print(e)
        })
        .disposed(by: disposeBag)
}
```


### empty

创建一个空 `Observable`

`empty` 操作符将创建一个 `Observable`，这个 `Observable` 只有一个完成事件。

eg:

```swift
func empty() {
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
```

输出：

```swift
2017-12-27 09:25:19.926: Empty -> subscribed
2017-12-27 09:25:19.926: Empty -> Event completed
2017-12-27 09:25:19.926: Empty -> isDisposed
```

### just

创建 `Observable` 发出唯一的一个元素

`just` 操作符将某一个元素转换为 `Observable`。

eg:

```swift
func just() {
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
```

输出如下：

```swift
just => next(A String)
just => completed
```

### error

创建一个只有 `error` 事件的 `Observable`

`error` 操作符将创建一个 `Observable`，这个 `Observable` 只会产生一个 `error` 事件。

eg:

```swift
func error() {
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
```

输出如下：

```swift
Error --> error(TError(errorCode: 10, errorString: "test error", errorData: nil))
```

### from

将其他类型或者数据结构转换为 `Observable`, 当你在使用 `Observable` 时，如果能够直接将其他类型转换为 `Observable`，这将是非常省事的。

`from` 操作符就提供了这种功能，将一个`数组`转换为 `Observable`

eg:

```swift
func from() {
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
```

输出如下：

```swift
From Array => next(34)
From Array => next(2)
From Array => next(44)
From Array => next(21)
From Array => next(54)
From Array => completed
From Optional => next(12)
From Optional => completed

```

### of

`of` 操作符将某一个元素或多个元素转换为 `Observable`。

eg:

```swift
func of() {
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
```

输出如下
```swift
Of => next(1)
Of => next(2)
Of => next(3)
Of => completed
```

### range

创建一个发射特定范围的顺序整数的 `Observable`

eg:

```swift
func range() {
    let rangeObservable = Observable<Int>.range(start: 10, count: 30, scheduler: MainScheduler.instance)
    rangeObservable
        .debug("range")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 09:37:15.266: range -> subscribed
2017-12-27 09:37:15.266: range -> Event next(10)
2017-12-27 09:37:15.267: range -> Event next(11)
2017-12-27 09:37:15.267: range -> Event next(12)
2017-12-27 09:37:15.268: range -> Event next(13)
2017-12-27 09:37:15.268: range -> Event next(14)
2017-12-27 09:37:15.268: range -> Event next(15)
2017-12-27 09:37:15.268: range -> Event next(16)
2017-12-27 09:37:15.268: range -> Event next(17)
2017-12-27 09:37:15.268: range -> Event next(18)
2017-12-27 09:37:15.268: range -> Event next(19)
2017-12-27 09:37:15.268: range -> Event next(20)
2017-12-27 09:37:15.268: range -> Event next(21)
2017-12-27 09:37:15.268: range -> Event next(22)
2017-12-27 09:37:15.268: range -> Event next(23)
2017-12-27 09:37:15.268: range -> Event next(24)
2017-12-27 09:37:15.268: range -> Event next(25)
2017-12-27 09:37:15.268: range -> Event next(26)
2017-12-27 09:37:15.268: range -> Event next(27)
2017-12-27 09:37:15.268: range -> Event next(28)
2017-12-27 09:37:15.268: range -> Event next(29)
2017-12-27 09:37:15.268: range -> Event next(30)
2017-12-27 09:37:15.269: range -> Event next(31)
2017-12-27 09:37:15.269: range -> Event next(32)
2017-12-27 09:37:15.269: range -> Event next(33)
2017-12-27 09:37:15.269: range -> Event next(34)
2017-12-27 09:37:15.269: range -> Event next(35)
2017-12-27 09:37:15.269: range -> Event next(36)
2017-12-27 09:37:15.269: range -> Event next(37)
2017-12-27 09:37:15.269: range -> Event next(38)
2017-12-27 09:37:15.269: range -> Event next(39)
2017-12-27 09:37:15.269: range -> Event completed
2017-12-27 09:37:15.269: range -> isDisposed
```

### repeatElement
`repeatElement` 操作符将创建一个 `Observable`，这个 `Observable` 将无止尽的发出同一个元素。

eg:

```swift
func repeatElement() {
    let observable = Observable.repeatElement(10, scheduler: MainScheduler.instance)
    // 相当于：
    // let observable = Observable<Int>.create { observer in
    //     DispatchQueue.global().async {
    //         while true {
    //             DispatchQueue.main.async {
    //                 observer.onNext(0)
    //             }
    //             // 防止阻塞主线程
    //             Thread.sleep(forTimeInterval: 0.001)
    //         }
    //     }
    //     return Disposables.create()
    // }
    observable
        .debug("repeatElement")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 09:39:01.061: repeatElement -> subscribed
2017-12-27 09:39:01.061: repeatElement -> Event next(10)
2017-12-27 09:39:01.062: repeatElement -> Event next(10)
2017-12-27 09:39:01.062: repeatElement -> Event next(10)
2017-12-27 09:39:01.062: repeatElement -> Event next(10)
2017-12-27 09:39:01.062: repeatElement -> Event next(10)
2017-12-27 09:39:01.062: repeatElement -> Event next(10)
2017-12-27 09:39:01.062: repeatElement -> Event next(10)
2017-12-27 09:39:01.063: repeatElement -> Event next(10)
2017-12-27 09:39:01.063: repeatElement -> Event next(10)
2017-12-27 09:39:01.063: repeatElement -> Event next(10)
2017-12-27 09:39:01.063: repeatElement -> Event next(10)
............
............
```


### defer

**直到订阅发生，才创建 `Observable`，并且为每位订阅者创建全新的 `Observable`**

> ⚠️注意：是延迟创建 `Observable` ，而不是延迟订阅或者延迟元素的发出时间
> 
>> `defer` 操作符将等待观察者订阅它，才创建一个 `Observable`，它会通过一个构建函数为每一位订阅者创建新的 `Observable`。
> 
> ⚠️注意：看上去每位订阅者都是对同一个 `Observable` 产生订阅，实际上它们都获得了独立的序列。其实并不是像以前一样订阅同一个 `Observable`，实际为每个订阅者都创建了一个 `Observable` ，在一些情况下，直到订阅时才创建 `Observable` 是可以保证拿到的数据都是最新的。

eg:

```swift
func `defer`() {
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
```

输出如下：

```swift
First Subscribe Now
2017-12-27 09:44:31.176: Test Defer: First Subscribe -> subscribed
Observable is Create Now
2017-12-27 09:44:31.280: Test Defer: First Subscribe -> Event next(Second -> 1)
Second Subscribe Now
2017-12-27 09:44:34.171: Test Defer: Second Subscribe -> subscribed
Observable is Create Now
2017-12-27 09:44:34.279: Test Defer: Second Subscribe -> Event next(Second -> 1)
2017-12-27 09:44:35.280: Test Defer: First Subscribe -> Event next(Second -> 2)
2017-12-27 09:44:38.279: Test Defer: Second Subscribe -> Event next(Second -> 2)
2017-12-27 09:44:39.280: Test Defer: First Subscribe -> Event next(Second -> 3)
2017-12-27 09:44:39.280: Test Defer: First Subscribe -> Event completed
2017-12-27 09:44:39.280: Test Defer: First Subscribe -> isDisposed
2017-12-27 09:44:42.279: Test Defer: Second Subscribe -> Event next(Second -> 3)
2017-12-27 09:44:42.279: Test Defer: Second Subscribe -> Event completed
2017-12-27 09:44:42.280: Test Defer: Second Subscribe -> isDisposed
```


### interval

创建一个 `Observable` 每隔一段时间，发出一个索引数

`interval` 操作符将创建一个 `Observable`，它每隔一段设定的时间，发出一个索引数的元素。它将发出无数个元素。

eg:

```swift
func interval() {
    let intervalQueue = DispatchQueue.init(label: "ink.tbd.test.interval")
    Observable<Int>
        .interval(1, scheduler: ConcurrentDispatchQueueScheduler.init(queue: intervalQueue))
        .subscribe({ (e) in
            print("interval => \(e.debugDescription)")
        })
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
interval => next(0)
interval => next(1)
interval => next(2)
interval => next(3)
interval => next(4)
interval => next(5)
interval => next(6)
interval => next(7)
...........
...........
```

### timer

创建一个 `Observable` 在一段延时后，产生唯一的一个元素

`timer` 操作符将创建一个 `Observable`，它在经过设定的一段时间后，产生唯一的一个元素。

> ⚠️注意：`timer(_:period:scheduler:)` 与 `interval(_:scheduler:)` 的区别
> 
> `timer(_:period:scheduler:)` 的实现：

> ```swift
> public static func timer(_ dueTime: RxTimeInterval, period: RxTimeInterval? = nil, scheduler: SchedulerType)
>     -> Observable<E> {
>         return Timer(
>             dueTime: dueTime,
>             period: period,
>             scheduler: scheduler
>         )
> }
> ```
> 
> `interval(_:scheduler:)` 的实现：
> 
> ```swift
> public static func interval(_ period: RxTimeInterval, scheduler: SchedulerType)
>     -> Observable<E> {
>         return Timer(dueTime: period,
>                      period: period,
>                      scheduler: scheduler
>         )
> }
> ```


eg:

```swift
func timer() {
    // dueTime: 初始延时, period: 时间间隔, scheduler: 队列
    let timerObservable = Observable<Int>.timer(5.0, period: 1, scheduler: MainScheduler.instance)
    timerObservable
        .debug("timer")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 09:57:16.075: timer -> subscribed
2017-12-27 09:57:21.077: timer -> Event next(0)
2017-12-27 09:57:22.076: timer -> Event next(1)
2017-12-27 09:57:23.077: timer -> Event next(2)
2017-12-27 09:57:24.077: timer -> Event next(3)
2017-12-27 09:57:25.077: timer -> Event next(4)
2017-12-27 09:57:26.077: timer -> Event next(5)
2017-12-27 09:57:27.077: timer -> Event next(6)
2017-12-27 09:57:28.076: timer -> Event next(7)
2017-12-27 09:57:29.076: timer -> Event next(8)
2017-12-27 09:57:30.076: timer -> Event next(9)
2017-12-27 09:57:31.075: timer -> Event next(10)
............
............
```



