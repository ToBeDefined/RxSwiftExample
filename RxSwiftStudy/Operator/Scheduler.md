
## Scheduler Operator

### observeOn

[https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/decision_tree/observeOn.html](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/decision_tree/observeOn.html)

指定 `Observable` 在哪个 `Scheduler` 发出通知

`ReactiveX` 使用 `Scheduler` 来让 `Observable` 支持多线程。你可以使用 `observeOn` 操作符，来指示 `Observable` 在哪个 `Scheduler` 发出通知。

**⚠️注意：一旦产生了 `onError` 事件， `observeOn` 操作符将立即转发。他不会等待 `onError` 之前的事件全部被收到。这意味着 `onError` 事件可能会跳过一些元素提前发送出去。**

`subscribeOn` 操作符非常相似。它指示 `Observable` 在哪个 `Scheduler` 发出执行。

默认情况下，`Observable` 创建，应用操作符以及发出通知都会在 `Subscribe` 方法调用的 `Scheduler` 执行。`subscribeOn` 操作符将改变这种行为，它会指定一个不同的 `Scheduler` 来让 `Observable` 执行，`observeOn` 操作符将指定一个不同的 `Scheduler` 来让 `Observable` 通知观察者。

`subscribeOn` 操作符指定 `Observable` 在哪个 `Scheduler` 开始执行，无论它处于链的那个位置。 另一方面 `observeOn` 将决定后面的方法在哪个 `Scheduler` 运行。因此，你可能会多次调用 `observeOn` 来决定某些操作符在哪个线程运行。

eg:

```swift
func observeOn() {
    let observable = Observable<Int>.of(1, 2, 3, 4, 5)
    let observeQueue = DispatchQueue.init(label: "ink.tbd.test.observeQueue")
    observable
        .observeOn(ConcurrentDispatchQueueScheduler.init(queue: observeQueue))
        .subscribe({ (e) in
            print("observeOn: \(getCurrentQueueName());  ==>  \(e.debugDescription)")
        })
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
observeOn: ink.tbd.test.observeQueue;  ==>  next(1)
observeOn: ink.tbd.test.observeQueue;  ==>  next(2)
observeOn: ink.tbd.test.observeQueue;  ==>  next(3)
observeOn: ink.tbd.test.observeQueue;  ==>  next(4)
observeOn: ink.tbd.test.observeQueue;  ==>  next(5)
observeOn: ink.tbd.test.observeQueue;  ==>  completed
```

### subscribeOn

[https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/decision_tree/subscribeOn.html](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/decision_tree/subscribeOn.html)

指定 `Observable` 在哪个 `Scheduler` 执行

`ReactiveX` 使用 `Scheduler` 来让 `Observable` 支持多线程。你可以使用 `subscribeOn` 操作符，来指示 `Observable` 在哪个 `Scheduler` 执行。

`observeOn` 操作符非常相似。它指示 `Observable` 在哪个 `Scheduler` 发出通知。

默认情况下，`Observable` 创建，应用操作符以及发出通知都会在 `Subscribe` 方法调用的 `Scheduler` 执行。`subscribeOn` 操作符将改变这种行为，它会指定一个不同的 `Scheduler` 来让 `Observable` 执行，`observeOn` 操作符将指定一个不同的 `Scheduler` 来让 `Observable` 通知观察者。

`subscribeOn` 操作符指定 `Observable` 在那个 `Scheduler` 开始执行，无论它处于链的那个位置。 另一方面 `observeOn` 将决定后面的方法在哪个 `Scheduler` 运行。因此，你可能会多次调用 `observeOn` 来决定某些操作符在哪个线程运行。

eg:

```swift
func subscribeOn() {
    let observable = Observable<Int>.of(1, 2, 3, 4, 5)
    let subscribeQueue = DispatchQueue.init(label: "ink.tbd.test.subscribeQueue")
    observable
        .subscribeOn(ConcurrentDispatchQueueScheduler.init(queue: subscribeQueue))
        .subscribe({ (e) in
            print("subscribeOn: \(getCurrentQueueName());  ==>  \(e.debugDescription)")
        })
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
subscribeOn: ink.tbd.test.subscribeQueue;  ==>  next(1)
subscribeOn: ink.tbd.test.subscribeQueue;  ==>  next(2)
subscribeOn: ink.tbd.test.subscribeQueue;  ==>  next(3)
subscribeOn: ink.tbd.test.subscribeQueue;  ==>  next(4)
subscribeOn: ink.tbd.test.subscribeQueue;  ==>  next(5)
subscribeOn: ink.tbd.test.subscribeQueue;  ==>  completed
```
