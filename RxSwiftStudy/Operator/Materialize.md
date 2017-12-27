
> Materialize Operator

## materialize

通常，一个有限的 `Observable` 将产生零个或者多个 `onNext` 事件，然后产生一个 `onCompleted` 或者 `onError` 事件。

`materialize` 操作符将 `Observable` 产生的这些事件全部转换成元素，然后发送出来。

eg:

```swift
func materialize() {
    getErrorObservable()
        .materialize()
        .subscribe({ (e) in
            print(e)
        })
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
next(next(1️⃣))
next(next(2️⃣))
next(error(TError(errorCode: 10, errorString: "Test", errorData: nil)))
completed
```

## dematerialize

`dematerialize` 操作符将 `materialize` 转换后的元素还原

eg:

```swift
func dematerialize() {
    let materializeObservable = getErrorObservable().materialize()
    materializeObservable
        .dematerialize()
        .subscribe({ (e) in
            print(e)
        })
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
next(1️⃣)
next(2️⃣)
error(TError(errorCode: 10, errorString: "Test", errorData: nil))
```