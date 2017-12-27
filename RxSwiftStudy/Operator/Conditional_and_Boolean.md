
> Conditional and Boolean Operator

## amb

当你传入多个 `Observables` 到 `amb` 操作符时
它将取其中一个 `Observable`：第一个产生事件的那个 `Observable`，可以是一个 `next`，`error` 或者 `completed` 事件。`amb` 将忽略掉其他的 Observables。

eg:

```swift
func amb() {
    let first = getFirstObservable()
    let second = getSecondObservable()
    let third = getThirdObservable()
    first
        .amb(second)
        .amb(third)
        .debug()
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 14:25:27.276: amb -> subscribed
2017-12-27 14:25:27.388: amb -> Event next(Second -> 1)
2017-12-27 14:25:31.390: amb -> Event next(Second -> 2)
2017-12-27 14:25:35.388: amb -> Event next(Second -> 3)
2017-12-27 14:25:35.388: amb -> Event completed
2017-12-27 14:25:35.388: amb -> isDisposed
```

## skipWhile

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


## skipUntil

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

## takeWhile

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
        .debug("takeWhile")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 12:32:42.491: takeWhile -> subscribed
2017-12-27 12:32:42.492: takeWhile -> Event next(0)
2017-12-27 12:32:42.492: takeWhile -> Event next(0)
2017-12-27 12:32:42.492: takeWhile -> Event next(0)
2017-12-27 12:32:42.492: takeWhile -> Event next(0)
2017-12-27 12:32:42.492: takeWhile -> Event next(1)
2017-12-27 12:32:42.492: takeWhile -> Event next(2)
2017-12-27 12:32:42.492: takeWhile -> Event next(3)
2017-12-27 12:32:42.492: takeWhile -> Event next(4)
2017-12-27 12:32:42.492: takeWhile -> Event next(5)
2017-12-27 12:32:42.492: takeWhile -> Event completed
2017-12-27 12:32:42.492: takeWhile -> isDisposed
```

## takeUntil

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



