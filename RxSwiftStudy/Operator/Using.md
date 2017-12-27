
> Using Operator


## Using

创建一个**可被清除的资源(即遵守`Disposable`协议)**，它和 `Observable` 具有相同的寿命

通过使用 `using` 操作符创建 `Observable` 时，同时创建一个可被清除的资源，一旦 `Observable` 终止了，那么这个资源就会被清除掉了(即调用了该资源的`dispose()`方法)。

```swift
func using() {
    class DisposableResource: Disposable {
        var values: [Int] = []
        var isDisposed: Bool = false
        
        func dispose() {
            self.values = []
            self.isDisposed = true
            print("!!!DisposableResource is Disposed!!!")
        }
        init(with values: [Int]) {
            self.values = values
        }
    }
    
    let observable = Observable<Int>.using({ () -> DisposableResource in
        return DisposableResource.init(with: [1, 2, 3, 4])
    }, observableFactory: { (resource) -> Observable<Int> in
        if resource.isDisposed {
            return Observable<Int>.from([])
        } else {
            return Observable<Int>.from(resource.values)
        }
    })
    
    observable
        .debug()
        .subscribe()
        .disposed(by: disposeBag)
}
```

```swift
2017-12-27 17:06:35.757: Operator+Using.swift:43 (using()) -> subscribed
2017-12-27 17:06:35.759: Operator+Using.swift:43 (using()) -> Event next(1)
2017-12-27 17:06:35.759: Operator+Using.swift:43 (using()) -> Event next(2)
2017-12-27 17:06:35.759: Operator+Using.swift:43 (using()) -> Event next(3)
2017-12-27 17:06:35.759: Operator+Using.swift:43 (using()) -> Event next(4)
2017-12-27 17:06:35.759: Operator+Using.swift:43 (using()) -> Event completed
2017-12-27 17:06:35.759: Operator+Using.swift:43 (using()) -> isDisposed
!!!DisposableResource is Disposed!!!
```
