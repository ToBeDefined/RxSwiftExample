
## 过滤 Observable - Filtering Operator

### ignoreElements

忽略掉所有的元素，只发出 `error` 或 `completed` 事件

`ignoreElements` 操作符将阻止 `Observable` 发出 `next` 事件，但是允许他发出 `error` 或 `completed` 事件。

如果你并不关心 `Observable` 的任何元素，你只想知道 `Observable` 在什么时候终止，那就可以使用 `ignoreElements` 操作符。

eg:

```swift
func ignoreElements() {
    Observable<Int>.of(1, 2, 3, 4, 5)
        .ignoreElements()
        .debug("ignoreElements")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 11:12:47.786: ignoreElements -> subscribed
2017-12-27 11:12:47.787: ignoreElements -> Event completed
2017-12-27 11:12:47.787: ignoreElements -> isDisposed
```

### elementAt

`elementAt` 操作符将拉取 `Observable` 序列中指定索引数的元素，然后将它作为唯一的元素发出。

eg:

```swift
func elementAt() {
    Observable<Int>.of(1, 2, 3, 4, 5)
        .elementAt(1)
        .subscribe({ (e) in
            print("elementAt subscribe -> \(e.debugDescription)")
        })
        .disposed(by: disposeBag)
}
```

输出如下：

```
elementAt subscribe -> next(2)
elementAt subscribe -> completed
```

### filter

`filter` 操作符将通过你提供的判定方法过滤一个 `Observable`。仅仅发出 `Observable` 中通过判定的元素。

eg:

```swift
func filter() {
    Observable
        .of(21, 3, 15, 50, 4, 23, 90, 11)
        .debug("Filter    : ")
        .filter({ (value) -> Bool in
            return value >= 20
        })
        .debug("Subscribe : ")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 11:16:48.888: Subscribe :  -> subscribed
2017-12-27 11:16:48.888: Filter    :  -> subscribed
2017-12-27 11:16:48.888: Filter    :  -> Event next(21)
2017-12-27 11:16:48.888: Subscribe :  -> Event next(21)
2017-12-27 11:16:48.888: Filter    :  -> Event next(3)
2017-12-27 11:16:48.888: Filter    :  -> Event next(15)
2017-12-27 11:16:48.888: Filter    :  -> Event next(50)
2017-12-27 11:16:48.888: Subscribe :  -> Event next(50)
2017-12-27 11:16:48.888: Filter    :  -> Event next(4)
2017-12-27 11:16:48.888: Filter    :  -> Event next(23)
2017-12-27 11:16:48.888: Subscribe :  -> Event next(23)
2017-12-27 11:16:48.888: Filter    :  -> Event next(90)
2017-12-27 11:16:48.888: Subscribe :  -> Event next(90)
2017-12-27 11:16:48.888: Filter    :  -> Event next(11)
2017-12-27 11:16:48.888: Filter    :  -> Event completed
2017-12-27 11:16:48.888: Subscribe :  -> Event completed
2017-12-27 11:16:48.889: Subscribe :  -> isDisposed
2017-12-27 11:16:48.889: Filter    :  -> isDisposed
```


### debounce

用于过滤一定时间内发出的高频元素，只发送最后一个。`debounce` 操作符将发出这种元素，在 `Observable` 产生这种元素后，一段时间内没有新元素产生。

eg:

```swift
func debounce() {
    getFirstObservable()
        .debounce(1, scheduler: MainScheduler.instance)
        .subscribe({ (e) in
            print(e)
        })
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
next(First -> 1|C)
next(First -> 2|C)
next(First -> 3|C)
completed
```


### throttle
返回在指定连续时间窗口期间中，由源 `Observable` 发出的第一个和最后一个元素。这个运算符确保没有两个元素在少于 `dueTime` 的时间发送。

eg:

```swift
func throttle() {
    let subject = BehaviorSubject<Int>.init(value: 0)
    subject
        .asObserver()
        // 2秒内第一个和最后一个发出的元素
        .throttle(2, latest: true, scheduler: MainScheduler.instance)
        .subscribe({ (e) in
            print(e)
        })
        .disposed(by: disposeBag)
    
    subject.onNext(1)
    subject.onNext(2)
    subject.onNext(3)
    delayTime(3) {
        // 不会发送onNext(4)，因为onNext(3)在上一个2秒的窗口中，最后延迟到2秒发送出来，
        // onNext(4)是在第3秒进行发送，此时 onNext(4)的发送时间减去onNext(3)发送时间小于2，所以被忽略
        // 因为throttle会确保没有两个元素在少于dueTime的时间
        subject.onNext(4)
        subject.onNext(5)
        subject.onNext(6)
    }
    
    delayTime(8.2) {
        subject.onNext(7)
    }
    
    delayTime(12.2) {
        subject.onNext(8)
        subject.onNext(9)
        subject.onNext(10)
        subject.onCompleted()
    }
}
```

输出如下：

```swift
next(0)
next(3)
next(6)
next(7)
next(8)
next(10)
completed
```

### distinctUntilChanged

`distinctUntilChanged` 操作符将阻止 `Observable` 发出相同的元素。如果后一个元素和前一个元素是相同的，那么这个元素将不会被发出来。如果后一个元素和前一个元素不相同，那么这个元素才会被发出来。

eg:

```swift
func distinctUntilChanged() {
    let observable = Observable.of("🐱", "🐷", "🐱", "🐱", "🐱", "🐵", "🐵", "🐵", "🐵", "🐱")
    observable
        .distinctUntilChanged()
        .debug("distinctUntilChanged")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 11:23:01.265: distinctUntilChanged -> subscribed
2017-12-27 11:23:01.269: distinctUntilChanged -> Event next(🐱)
2017-12-27 11:23:01.270: distinctUntilChanged -> Event next(🐷)
2017-12-27 11:23:01.270: distinctUntilChanged -> Event next(🐱)
2017-12-27 11:23:01.270: distinctUntilChanged -> Event next(🐵)
2017-12-27 11:23:01.270: distinctUntilChanged -> Event next(🐱)
2017-12-27 11:23:01.270: distinctUntilChanged -> Event completed
2017-12-27 11:23:01.270: distinctUntilChanged -> isDisposed
```

### sample

`sample` 操作符将不定期的对源 `Observable` 进行取样操作。

通过第二个 `Observable` 来控制取样时机。一旦第二个 `Observable` 发出一个元素，就从源(第一个) `Observable` 中取出最后产生的元素（如果这段时间内没发出元素，则不取）。

eg:

```swift
func sample() {
    let sampleObservable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
    let observable = getFirstObservable()
        .sample(sampleObservable)
    observable
        .debug("sample")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 11:24:47.642: sample -> subscribed
2017-12-27 11:24:48.643: sample -> Event next(First -> 1|C)
2017-12-27 11:24:52.644: sample -> Event next(First -> 2|C)
2017-12-27 11:24:56.643: sample -> Event next(First -> 3|C)
2017-12-27 11:24:56.643: sample -> Event completed
2017-12-27 11:24:56.643: sample -> isDisposed
```

### skip

`skip` 操作符可以让你跳过 `Observable` 中头 `n` 个元素，只关注后面的元素。

eg:

```swift
func skip() {
    Observable<Int>
        .of(0, 0, 0, 0, 1, 2, 3, 4, 5)
        .skip(4)
        .debug("skip")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 11:33:49.559: skip -> subscribed
2017-12-27 11:33:49.559: skip -> Event next(1)
2017-12-27 11:33:49.559: skip -> Event next(2)
2017-12-27 11:33:49.559: skip -> Event next(3)
2017-12-27 11:33:49.559: skip -> Event next(4)
2017-12-27 11:33:49.559: skip -> Event next(5)
2017-12-27 11:33:49.559: skip -> Event completed
2017-12-27 11:33:49.559: skip -> isDisposed
```


### skipWhile

跳过 `Observable` 中头几个元素，直到元素的判定为否，闭包返回 `true` 则`跳过(skip)`，`skipWhile` 操作符可以让你忽略源 `Observable` 中 `头几个` 元素，直到元素的判定为 `false` 后，它才镜像源 `Observable`，**一旦有 `false` 产生，后面的元素不会再进行判断**。

eg:

```swift
func skipWhile() {
    Observable<Int>
        .of(0, 0, 0, 0, 1, 2, 3, 4, 5, -1, 0, 0, 10)
        .skipWhile({ (value) -> Bool in
            return value == 0
        })
        .debug("skipWhile")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 11:35:43.512: skipWhile -> subscribed
2017-12-27 11:35:43.512: skipWhile -> Event next(1)
2017-12-27 11:35:43.512: skipWhile -> Event next(2)
2017-12-27 11:35:43.513: skipWhile -> Event next(3)
2017-12-27 11:35:43.513: skipWhile -> Event next(4)
2017-12-27 11:35:43.513: skipWhile -> Event next(5)
2017-12-27 11:35:43.513: skipWhile -> Event next(-1)
2017-12-27 11:35:43.513: skipWhile -> Event next(0)
2017-12-27 11:35:43.513: skipWhile -> Event next(0)
2017-12-27 11:35:43.513: skipWhile -> Event next(10)
2017-12-27 11:35:43.513: skipWhile -> Event completed
2017-12-27 11:35:43.513: skipWhile -> isDisposed
```


### skipUntil

跳过 `Observable` 中头几个元素，直到另一个 `Observable` 发出一个元素，`skipUntil` 操作符可以让你忽略源 `Observable` 中头几个元素，直到另一个 `Observable` 发出一个元素后，它才镜像源 `Observable`。

eg:

```swift
func skipUntil() {
    let skipUntilObservable = Observable<Int>.create { (observer) -> Disposable in
        delayTime(3, block: {
            print("skipUntilObservable => onNext(0)")
            observer.onNext(0)
        })
        return Disposables.create()
    }
    getFirstObservable()
        .skipUntil(skipUntilObservable)
        .debug("skipUntil")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 12:25:42.199: skipUntil -> subscribed
skipUntilObservable => onNext(0)
2017-12-27 12:25:47.199: skipUntil -> Event next(First -> 2|A)
2017-12-27 12:25:47.200: skipUntil -> Event next(First -> 2|B)
2017-12-27 12:25:47.200: skipUntil -> Event next(First -> 2|C)
2017-12-27 12:25:51.201: skipUntil -> Event next(First -> 3|A)
2017-12-27 12:25:51.201: skipUntil -> Event next(First -> 3|B)
2017-12-27 12:25:51.201: skipUntil -> Event next(First -> 3|C)
2017-12-27 12:25:51.201: skipUntil -> Event completed
2017-12-27 12:25:51.201: skipUntil -> isDisposed
```


### take

通过 `take` 操作符你可以只发出头 `n` 个元素。并且忽略掉后面的元素，直接结束序列。

eg:

```swift
func take() {
    Observable.of("🐱", "🐰", "🐶", "🐸", "🐷", "🐵")
        .take(3)
        .debug("take")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 12:28:14.822: take -> subscribed
2017-12-27 12:28:14.822: take -> Event next(🐱)
2017-12-27 12:28:14.822: take -> Event next(🐰)
2017-12-27 12:28:14.822: take -> Event next(🐶)
2017-12-27 12:28:14.822: take -> Event completed
2017-12-27 12:28:14.822: take -> isDisposed
```

### takeLast


通过 `takeLast` 操作符你可以只发出尾部 `n` 个元素。并且忽略掉前面的元素。

在 `onCompleted()` 之后取出最后n个元素一次性发出。

eg:

```swift
func takeLast() {
    getFirstObservable()
        .takeLast(5)
        .debug("takeLast")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 12:30:13.992: takeLast -> subscribed
2017-12-27 12:30:22.994: takeLast -> Event next(First -> 2|B)
2017-12-27 12:30:22.994: takeLast -> Event next(First -> 2|C)
2017-12-27 12:30:22.994: takeLast -> Event next(First -> 3|A)
2017-12-27 12:30:22.994: takeLast -> Event next(First -> 3|B)
2017-12-27 12:30:22.994: takeLast -> Event next(First -> 3|C)
2017-12-27 12:30:22.995: takeLast -> Event completed
2017-12-27 12:30:22.995: takeLast -> isDisposed
```

### takeWhile

镜像一个 `Observable` 直到某个元素的判定为 `false`

闭包返回 `true` 则放行，返回 `false` 则结束

`takeWhile` 操作符将镜像源 `Observable` 直到某个元素的判定为 `false`。此时，这个镜像的 `Observable` 将立即终止。

eg:

```swift
func takeWhile() {
    Observable<Int>
        .of(0, 0, 0, 0, 1, 2, 3, 4, 5, -1, 0, 0, 10)
        .takeWhile({ (value) -> Bool in
            return value >= 0
        })
        .debug("skipWhile")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 12:32:42.491: skipWhile -> subscribed
2017-12-27 12:32:42.492: skipWhile -> Event next(0)
2017-12-27 12:32:42.492: skipWhile -> Event next(0)
2017-12-27 12:32:42.492: skipWhile -> Event next(0)
2017-12-27 12:32:42.492: skipWhile -> Event next(0)
2017-12-27 12:32:42.492: skipWhile -> Event next(1)
2017-12-27 12:32:42.492: skipWhile -> Event next(2)
2017-12-27 12:32:42.492: skipWhile -> Event next(3)
2017-12-27 12:32:42.492: skipWhile -> Event next(4)
2017-12-27 12:32:42.492: skipWhile -> Event next(5)
2017-12-27 12:32:42.492: skipWhile -> Event completed
2017-12-27 12:32:42.492: skipWhile -> isDisposed
```

### takeUntil

忽略一部分元素，这些元素是在第二个 `Observable` 产生事件后发出的(则被忽略)。

`takeUntil` 操作符将镜像源 `Observable`，它同时观测第二个 `Observable`。一旦第二个 `Observable` 发出一个元素或者产生一个终止事件，那个镜像的 `Observable` 将立即终止。

eg:

```swift
func takeUntil() {
    let takeUntilObservable = Observable<Int>.create { (observer) -> Disposable in
        delayTime(3, block: {
            print("takeUntilObservable => onNext(0)")
            observer.onNext(0)
        })
        return Disposables.create()
    }
    getFirstObservable()
        .takeUntil(takeUntilObservable)
        .debug("takeUntil")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 12:36:41.994: takeUntil -> subscribed
2017-12-27 12:36:42.996: takeUntil -> Event next(First -> 1|A)
2017-12-27 12:36:42.996: takeUntil -> Event next(First -> 1|B)
2017-12-27 12:36:42.996: takeUntil -> Event next(First -> 1|C)
takeUntilObservable => onNext(0)
2017-12-27 12:36:44.995: takeUntil -> Event completed
2017-12-27 12:36:44.995: takeUntil -> isDisposed
```

### single

限制 `Observable` 只有一个元素，否出发出一个 `error` 事件，`single` 操作符将限制 `Observable` 只产生一个元素。

- 如果 `Observable` 只有一个元素，它将镜像这个 `Observable` 。
- 如果 `Observable` 没有元素或者元素数量大于一，它将产生一个 `error` 事件。

eg:

```swift
func single() {
    Observable<Int>
        .just(1)
        .single()
        .subscribe({ e in
            print("single 1 => \(e.debugDescription)")
        })
        .disposed(by: disposeBag)
    
    Observable<Int>
        .of(1, 2, 3, 4, 5)
        .single()
        .subscribe({ (e) in
            print("single 2 => \(e.debugDescription)")
        })
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
single 1 => next(1)
single 1 => completed
single 2 => next(1)
single 2 => error(Sequence contains more than one element.)
```



