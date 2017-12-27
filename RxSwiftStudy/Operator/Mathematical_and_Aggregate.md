
> Mathematical and Aggregate Operator

## concat

`concat` 操作符将多个 `Observables` 按顺序串联起来，当前一个 `Observable` 元素发送完毕后，后一个 `Observable` 才可以开始发出元素。

`concat` 将等待前一个 `Observable` 产生完成事件后，才对后一个 `Observable` 进行订阅。

如果后一个是`热 Observable` ，在它前一个 `Observable` 产生完成事件前，所产生的元素将不会被发送出来。

> 关于 `热Observable` 和 `冷Observable` 可以参考下面的文档
> 
> [官方文档](https://github.com/ReactiveX/RxSwift/blob/master/Documentation/HotAndColdObservables.md)
> 
> [Hot Observable和Cold Observable](https://medium.com/@DianQK/hot-observable%E5%92%8Ccold-observable-c3ba8d07867b)


eg:

```swift
func concat() {
    getFirstObservable()
        .concat(getSecondObservable())
        .concat(getThirdObservable())
        .debug("concat")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 14:56:25.556: concat -> subscribed
2017-12-27 14:56:26.558: concat -> Event next(First -> 1|A)
2017-12-27 14:56:26.558: concat -> Event next(First -> 1|B)
2017-12-27 14:56:26.558: concat -> Event next(First -> 1|C)
2017-12-27 14:56:30.558: concat -> Event next(First -> 2|A)
2017-12-27 14:56:30.558: concat -> Event next(First -> 2|B)
2017-12-27 14:56:30.558: concat -> Event next(First -> 2|C)
2017-12-27 14:56:34.558: concat -> Event next(First -> 3|A)
2017-12-27 14:56:34.558: concat -> Event next(First -> 3|B)
2017-12-27 14:56:34.558: concat -> Event next(First -> 3|C)
2017-12-27 14:56:34.659: concat -> Event next(Second -> 1)
2017-12-27 14:56:38.660: concat -> Event next(Second -> 2)
2017-12-27 14:56:42.659: concat -> Event next(Second -> 3)
2017-12-27 14:56:42.764: concat -> Event next(Third -> 1)
2017-12-27 14:56:42.764: concat -> Event next(Third -> 2)
2017-12-27 14:56:42.764: concat -> Event next(Third -> 3)
2017-12-27 14:56:42.764: concat -> Event completed
2017-12-27 14:56:42.764: concat -> isDisposed
```

## reduce

持续的将 `Observable` 的每一个元素应用一个函数，然后发出最终结果。

`reduce` 操作符将对第一个元素应用一个函数。然后，将结果作为参数填入到第二个元素的应用函数中。以此类推，直到遍历完全部的元素后发出最终结果。
这种操作符在其他地方有时候被称作是 `accumulator`，`aggregate`，`compress`，`fold` 或者 `inject`。

> 与 `scan` 类似，`reduce` 发送最终结果，`scan` 发送每个步骤

eg:

```swift
func reduce() {
    let observable = Observable.of(1, 2, 3, 4, 5, 6)
    // reduce(_ seed:accumulator:)
    // seed: 基数，accumulator: 运算方法
    // 
    // reduce(_ seed:accumulator:mapResult:)
    // seed: 基数，accumulator: 运算方法，mapResult: 转换返回值
    observable
        .reduce(10, accumulator: {(a, b) -> Int in
            return a*b
        }, mapResult: { (value) -> String in
            return "In the end, value is \(value)"
        })
        .subscribe({ (e) in
            print(e)
        })
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
next(In the end, value is 7200)
completed
```

