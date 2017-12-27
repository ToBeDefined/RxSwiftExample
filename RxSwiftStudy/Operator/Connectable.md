
## 连接 Observable 操作符 - Connectable Operator

### multicast

`multicast()`需要传入一个 `subject`，通过 `subject` 来管理向订阅者发送消息

eg:

```swift
func multicast() {
    let subject = PublishSubject<Int>()
    subject
        .subscribe(onNext: { print("Subject: \($0)") })
        .disposed(by: disposeBag)
    
    let intSequence = Observable<Int>
        .interval(1, scheduler: MainScheduler.instance)
        .multicast(subject)
        // 与下面相同：
        // .multicast(makeSubject: { () -> PublishSubject<Int> in
        //     return subject
        // })
    
    intSequence
        .subscribe(onNext: { print("\t Subscription 1:, Event: \($0)") })
        .disposed(by: disposeBag)
    
    delayTime(2, block: {
        intSequence.connect().disposed(by: self.disposeBag)
    })
    
    delayTime(4, block: {
        intSequence
            .subscribe(onNext: { print("\t Subscription 2:, Event: \($0)") })
            .disposed(by: self.disposeBag)
    })
    
    delayTime(6, block: {
        intSequence
            .subscribe(onNext: { print("\t Subscription 3:, Event: \($0)") })
            .disposed(by: self.disposeBag)
    })
}
```

输出如下：

```swift
Subject: 0
	 Subscription 1:, Event: 0
Subject: 1
	 Subscription 1:, Event: 1
	 Subscription 2:, Event: 1
Subject: 2
	 Subscription 1:, Event: 2
	 Subscription 2:, Event: 2
Subject: 3
	 Subscription 1:, Event: 3
	 Subscription 2:, Event: 3
	 Subscription 3:, Event: 3
Subject: 4
	 Subscription 1:, Event: 4
	 Subscription 2:, Event: 4
	 Subscription 3:, Event: 4
Subject: 5
	 Subscription 1:, Event: 5
	 Subscription 2:, Event: 5
	 Subscription 3:, Event: 5
Subject: 6
	 Subscription 1:, Event: 6
	 Subscription 2:, Event: 6
	 Subscription 3:, Event: 6
Subject: 7
	 Subscription 1:, Event: 7
	 Subscription 2:, Event: 7
	 Subscription 3:, Event: 7
...........
...........
```


### publish

将 `Observable` 转换为可被连接的 `Observable`，`publish` 会将 `Observable` 转换为可被连接的 `Observable`。

可被连接的 `Observable` 和普通的 `Observable` 十分相似，不过在被订阅后不会发出元素，直到 `connect` 操作符被应用为止。这样一来你可以控制 `Observable` 在什么时候开始发出元素。

eg:

```swift
func publish() {
    let connectObservable = Observable.of(1, 2, 3, 4, 5, 6).publish()
    print("> connectObservable subscribe now")
    connectObservable
        .subscribe({ e in
            print("connectObservable => \(e.debugDescription)")
        })
        .disposed(by: disposeBag)
    delayTime(3) {
        print("> connectObservable connect now")
        connectObservable
            .connect()
            .disposed(by: self.disposeBag)
    }
}
```

输出如下：

```swift
> connectObservable subscribe now
> connectObservable connect now
connectObservable => next(1)
connectObservable => next(2)
connectObservable => next(3)
connectObservable => next(4)
connectObservable => next(5)
connectObservable => next(6)
connectObservable => completed
```


### connect

通知可被连接的 `Observable` 可以开始发出元素了，可被连接的 `Observable` 和普通的 `Observable` 十分相似，不过在被订阅后不会发出元素，直到 `connect` 操作符被应用为止。

这样一来你可以等所有观察者全部订阅完成后，才发出元素。

eg:

```swift
func connect() {
    let connectableObservable = ConnectableObservable<String>
        .create({ (observer) -> Disposable in
            observer.onNext("ConnectableObservable -> 1")
            observer.onNext("ConnectableObservable -> 2")
            observer.onNext("ConnectableObservable -> 3")
            delayTime(2, block: {
                observer.onNext("ConnectableObservable -> delay -> 1")
            })
            delayTime(4, block: {
                observer.onNext("ConnectableObservable -> delay -> 2")
                observer.onCompleted()
            })
            return Disposables.create()
        })
        .publish()
    
    connectableObservable
        .subscribe({ (e) in
            print("First  Subscribe : \(e.debugDescription)")
        })
        .disposed(by: disposeBag)
    connectableObservable
        .connect()
        .disposed(by: disposeBag)
    connectableObservable
        .subscribe({ (e) in
            print("Second Subscribe : \(e.debugDescription)")
        })
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
First  Subscribe : next(ConnectableObservable -> 1)
First  Subscribe : next(ConnectableObservable -> 2)
First  Subscribe : next(ConnectableObservable -> 3)
First  Subscribe : next(ConnectableObservable -> delay -> 1)
Second Subscribe : next(ConnectableObservable -> delay -> 1)
First  Subscribe : next(ConnectableObservable -> delay -> 2)
Second Subscribe : next(ConnectableObservable -> delay -> 2)
First  Subscribe : completed
Second Subscribe : completed
```

### refCount

将可被连接的 `Observable` 转换为普通 `Observable`，`refCount` 操作符将自动连接和断开可被连接的 `Observable`。

- 当第一个观察者对它订阅时，那么底层的 `Observable` 将被连接。
- 当最后一个观察者离开时，那么底层的 `Observable` 将被断开连接。

eg:

```swift
func refCount() {
    let connectObservable = getFirstObservable().publish()
    let observable = connectObservable.refCount()
    observable
        .debug("refCount")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```
2017-12-27 15:11:42.966: refCount -> subscribed
2017-12-27 15:11:43.968: refCount -> Event next(First -> 1|A)
2017-12-27 15:11:43.968: refCount -> Event next(First -> 1|B)
2017-12-27 15:11:43.968: refCount -> Event next(First -> 1|C)
2017-12-27 15:11:47.968: refCount -> Event next(First -> 2|A)
2017-12-27 15:11:47.968: refCount -> Event next(First -> 2|B)
2017-12-27 15:11:47.968: refCount -> Event next(First -> 2|C)
2017-12-27 15:11:51.968: refCount -> Event next(First -> 3|A)
2017-12-27 15:11:51.968: refCount -> Event next(First -> 3|B)
2017-12-27 15:11:51.968: refCount -> Event next(First -> 3|C)
2017-12-27 15:11:51.970: refCount -> Event completed
2017-12-27 15:11:51.970: refCount -> isDisposed
```


### replay

确保观察者接收到同样的序列，即使是在 `Observable` 发出元素后才订阅，`replay` 操作符将 `Observable` 转换为可被连接的 `Observable`，并且这个可被连接的 `Observable` 将缓存最新的 `n` 个元素。当有新的观察者对它进行订阅时，它就把这些被缓存的元素发送给观察者。

> [RxSwift学习之旅 - share vs replay vs shareReplay](http://www.alonemonkey.com/2017/04/02/rxswift-part-eleven/)

eg:

```swift
func replay() {
    let observable = getFirstObservable().replayAll()
    // let observable = getFirstObservable().replay(4)
    observable
        .debug("First")
        .subscribe()
        .disposed(by: disposeBag)
    
    observable
        .connect()
        .disposed(by: disposeBag)
    
    delayTime(6) {
        observable
            .debug("replay")
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}
```

输出如下：

```swift
2017-12-27 15:15:14.401: First  -> subscribed
2017-12-27 15:15:15.403: First  -> Event next(First -> 1|A)
2017-12-27 15:15:15.403: First  -> Event next(First -> 1|B)
2017-12-27 15:15:15.403: First  -> Event next(First -> 1|C)
2017-12-27 15:15:19.892: First  -> Event next(First -> 2|A)
2017-12-27 15:15:19.892: First  -> Event next(First -> 2|B)
2017-12-27 15:15:19.892: First  -> Event next(First -> 2|C)
2017-12-27 15:15:20.999: Replay -> subscribed
2017-12-27 15:15:21.000: Replay -> Event next(First -> 1|A)
2017-12-27 15:15:21.000: Replay -> Event next(First -> 1|B)
2017-12-27 15:15:21.000: Replay -> Event next(First -> 1|C)
2017-12-27 15:15:21.000: Replay -> Event next(First -> 2|A)
2017-12-27 15:15:21.000: Replay -> Event next(First -> 2|B)
2017-12-27 15:15:21.000: Replay -> Event next(First -> 2|C)
2017-12-27 15:15:23.402: First  -> Event next(First -> 3|A)
2017-12-27 15:15:23.403: Replay -> Event next(First -> 3|A)
2017-12-27 15:15:23.403: First  -> Event next(First -> 3|B)
2017-12-27 15:15:23.403: Replay -> Event next(First -> 3|B)
2017-12-27 15:15:23.403: First  -> Event next(First -> 3|C)
2017-12-27 15:15:23.403: Replay -> Event next(First -> 3|C)
2017-12-27 15:15:23.403: First  -> Event completed
2017-12-27 15:15:23.403: First  -> isDisposed
2017-12-27 15:15:23.403: Replay -> Event completed
2017-12-27 15:15:23.403: Replay -> isDisposed
```

### share

使观察者共享 `Observable`，不会对新增的观察者发送之前已经发送了的元素。

**⚠️注意：当订阅者从多个变成 0 的时候重置序列，否则不重置序列。**

> [RxSwift学习之旅 - share vs replay vs shareReplay](http://www.alonemonkey.com/2017/04/02/rxswift-part-eleven/)

eg:

```swift
func share() {
    let observable = getFirstObservable().share()
    observable
        .debug("First  Subscribe")
        .subscribe()
        .disposed(by: disposeBag)
    delayTime(7) {
        observable
            .debug("Second Subscribe")
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    delayTime(12) {
        print("====================订阅者总数变为了0====================")
        observable
            .debug("Third  Subscribe")
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}
```

输出如下：

```swift
2017-12-27 16:14:10.869: First  Subscribe -> subscribed
2017-12-27 16:14:11.871: First  Subscribe -> Event next(First -> 1|A)
2017-12-27 16:14:11.871: First  Subscribe -> Event next(First -> 1|B)
2017-12-27 16:14:11.871: First  Subscribe -> Event next(First -> 1|C)
2017-12-27 16:14:15.871: First  Subscribe -> Event next(First -> 2|A)
2017-12-27 16:14:15.871: First  Subscribe -> Event next(First -> 2|B)
2017-12-27 16:14:15.871: First  Subscribe -> Event next(First -> 2|C)
2017-12-27 16:14:17.871: Second Subscribe -> subscribed
2017-12-27 16:14:20.763: First  Subscribe -> Event next(First -> 3|A)
2017-12-27 16:14:20.763: Second Subscribe -> Event next(First -> 3|A)
2017-12-27 16:14:20.764: First  Subscribe -> Event next(First -> 3|B)
2017-12-27 16:14:20.764: Second Subscribe -> Event next(First -> 3|B)
2017-12-27 16:14:20.764: First  Subscribe -> Event next(First -> 3|C)
2017-12-27 16:14:20.764: Second Subscribe -> Event next(First -> 3|C)
2017-12-27 16:14:20.764: First  Subscribe -> Event completed
2017-12-27 16:14:20.764: First  Subscribe -> isDisposed
2017-12-27 16:14:20.764: Second Subscribe -> Event completed
2017-12-27 16:14:20.764: Second Subscribe -> isDisposed
====================订阅者总数变为了0====================
2017-12-27 16:14:24.066: Third  Subscribe -> subscribed
2017-12-27 16:14:25.163: Third  Subscribe -> Event next(First -> 1|A)
2017-12-27 16:14:25.163: Third  Subscribe -> Event next(First -> 1|B)
2017-12-27 16:14:25.163: Third  Subscribe -> Event next(First -> 1|C)
2017-12-27 16:14:29.066: Third  Subscribe -> Event next(First -> 2|A)
2017-12-27 16:14:29.066: Third  Subscribe -> Event next(First -> 2|B)
2017-12-27 16:14:29.066: Third  Subscribe -> Event next(First -> 2|C)
2017-12-27 16:14:33.066: Third  Subscribe -> Event next(First -> 3|A)
2017-12-27 16:14:33.066: Third  Subscribe -> Event next(First -> 3|B)
2017-12-27 16:14:33.066: Third  Subscribe -> Event next(First -> 3|C)
2017-12-27 16:14:33.066: Third  Subscribe -> Event completed
2017-12-27 16:14:33.066: Third  Subscribe -> isDisposed
```

### shareReplay

> @available(*, deprecated, message: "Suggested replacement is `share(replay: 1)`. In case old 3.x behavior of `shareReplay` is required please use `share(replay: 1, scope: .forever)` instead.", renamed: "share(replay:)")

使观察者共享 `Observable`，观察者会立即收到最新的元素，即使这些元素是在订阅前产生的
`shareReplay` 操作符将使得观察者共享源 `Observable`，并且缓存最新的 `n` 个元素，将这些元素直接发送给新的观察者。

**⚠️注意：当订阅者从多个变成 0 的时候不会清空缓存不会重置序列，再次订阅直接返回 `replay` 的数目的元素。**

> [RxSwift学习之旅 - share vs replay vs shareReplay](http://www.alonemonkey.com/2017/04/02/rxswift-part-eleven/)

```swift
func shareReplay() {
    let observable = getFirstObservable().share(replay: 2, scope: SubjectLifetimeScope.forever)
    observable
        .debug("Origin")
        .subscribe()
        .disposed(by: disposeBag)
    delayTime(3) {
        observable
            .debug("shareReply")
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}
```

输出如下：

```swift
2017-12-27 16:19:53.859: First  Subscribe -> subscribed
2017-12-27 16:19:54.862: First  Subscribe -> Event next(First -> 1|A)
2017-12-27 16:19:54.862: First  Subscribe -> Event next(First -> 1|B)
2017-12-27 16:19:54.862: First  Subscribe -> Event next(First -> 1|C)
2017-12-27 16:19:58.861: First  Subscribe -> Event next(First -> 2|A)
2017-12-27 16:19:58.861: First  Subscribe -> Event next(First -> 2|B)
2017-12-27 16:19:58.861: First  Subscribe -> Event next(First -> 2|C)
2017-12-27 16:20:00.862: Second Subscribe -> subscribed
2017-12-27 16:20:00.863: Second Subscribe -> Event next(First -> 2|B)
2017-12-27 16:20:00.863: Second Subscribe -> Event next(First -> 2|C)
2017-12-27 16:20:02.861: First  Subscribe -> Event next(First -> 3|A)
2017-12-27 16:20:02.861: Second Subscribe -> Event next(First -> 3|A)
2017-12-27 16:20:02.861: First  Subscribe -> Event next(First -> 3|B)
2017-12-27 16:20:02.861: Second Subscribe -> Event next(First -> 3|B)
2017-12-27 16:20:02.861: First  Subscribe -> Event next(First -> 3|C)
2017-12-27 16:20:02.861: Second Subscribe -> Event next(First -> 3|C)
2017-12-27 16:20:02.863: First  Subscribe -> Event completed
2017-12-27 16:20:02.863: First  Subscribe -> isDisposed
2017-12-27 16:20:02.864: Second Subscribe -> Event completed
2017-12-27 16:20:02.864: Second Subscribe -> isDisposed
====================订阅者总数变为了0====================
2017-12-27 16:20:05.862: Third  Subscribe -> subscribed
2017-12-27 16:20:05.862: Third  Subscribe -> Event next(First -> 3|B)
2017-12-27 16:20:05.862: Third  Subscribe -> Event next(First -> 3|C)
2017-12-27 16:20:05.862: Third  Subscribe -> Event completed
2017-12-27 16:20:05.862: Third  Subscribe -> isDisposed
```


### shareReplayLatestWhileConnected

> @available(*, deprecated, message: "use `share(replay: 1)` instead", renamed: "`share(replay:)`")

使观察者共享 `Observable`，观察者会立即收到最新的元素，即使这些元素是在订阅前产生的

`shareReplayLatestWhileConnected` 操作符将使得观察者共享源 `Observable`，并且缓存最新的 `n` 个元素，将这些元素直接发送给新的观察者。

**⚠️注意：当订阅者从多个变成 0 的时候清空缓存并且重置序列，否则不重置序列**

> [RxSwift学习之旅 - share vs replay vs shareReplay](http://www.alonemonkey.com/2017/04/02/rxswift-part-eleven/)

eg:

```swift
func shareReplayLatestWhileConnected() {
    // @available(*, deprecated, message: "use share(replay: 1) instead", renamed: "share(replay:)")
    let observable = getFirstObservable().share(replay: 2, scope: SubjectLifetimeScope.whileConnected)
    observable
        .debug("First  Subscribe")
        .subscribe()
        .disposed(by: disposeBag)
    delayTime(7) {
        observable
            .debug("Second Subscribe")
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    delayTime(12) {
        print("====================订阅者总数变为了0====================")
        observable
            .debug("Third  Subscribe")
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}
```

输出如下：

```swift
2017-12-27 16:26:11.460: First  Subscribe -> subscribed
2017-12-27 16:26:12.466: First  Subscribe -> Event next(First -> 1|A)
2017-12-27 16:26:12.466: First  Subscribe -> Event next(First -> 1|B)
2017-12-27 16:26:12.466: First  Subscribe -> Event next(First -> 1|C)
2017-12-27 16:26:16.463: First  Subscribe -> Event next(First -> 2|A)
2017-12-27 16:26:16.464: First  Subscribe -> Event next(First -> 2|B)
2017-12-27 16:26:16.464: First  Subscribe -> Event next(First -> 2|C)
2017-12-27 16:26:18.870: Second Subscribe -> subscribed
2017-12-27 16:26:18.871: Second Subscribe -> Event next(First -> 2|B)
2017-12-27 16:26:18.871: Second Subscribe -> Event next(First -> 2|C)
2017-12-27 16:26:20.463: First  Subscribe -> Event next(First -> 3|A)
2017-12-27 16:26:20.463: Second Subscribe -> Event next(First -> 3|A)
2017-12-27 16:26:20.464: First  Subscribe -> Event next(First -> 3|B)
2017-12-27 16:26:20.464: Second Subscribe -> Event next(First -> 3|B)
2017-12-27 16:26:20.464: First  Subscribe -> Event next(First -> 3|C)
2017-12-27 16:26:20.464: Second Subscribe -> Event next(First -> 3|C)
2017-12-27 16:26:20.464: First  Subscribe -> Event completed
2017-12-27 16:26:20.464: First  Subscribe -> isDisposed
2017-12-27 16:26:20.464: Second Subscribe -> Event completed
2017-12-27 16:26:20.464: Second Subscribe -> isDisposed
====================订阅者总数变为了0====================
2017-12-27 16:26:23.464: Third  Subscribe -> subscribed
2017-12-27 16:26:24.552: Third  Subscribe -> Event next(First -> 1|A)
2017-12-27 16:26:24.552: Third  Subscribe -> Event next(First -> 1|B)
2017-12-27 16:26:24.552: Third  Subscribe -> Event next(First -> 1|C)
2017-12-27 16:26:28.952: Third  Subscribe -> Event next(First -> 2|A)
2017-12-27 16:26:28.952: Third  Subscribe -> Event next(First -> 2|B)
2017-12-27 16:26:28.952: Third  Subscribe -> Event next(First -> 2|C)
2017-12-27 16:26:32.464: Third  Subscribe -> Event next(First -> 3|A)
2017-12-27 16:26:32.464: Third  Subscribe -> Event next(First -> 3|B)
2017-12-27 16:26:32.464: Third  Subscribe -> Event next(First -> 3|C)
2017-12-27 16:26:32.464: Third  Subscribe -> Event completed
2017-12-27 16:26:32.464: Third  Subscribe -> isDisposed
```



