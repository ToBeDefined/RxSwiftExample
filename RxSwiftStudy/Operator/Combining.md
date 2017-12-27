
> Combining Operator

## startWith


`startWith` 操作符会在 `Observable` 头部插入一些元素。（如果你想在尾部加入一些元素可以用concat）

eg:

```swift
func startWith() {
    Observable.of("🐶", "🐱", "🐭", "🐹")
        .startWith("First")
        .startWith("Second")
        .startWith("Third")
        .startWith("1", "2", "3")
        .debug("startWith")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 12:42:41.259: startWith -> subscribed
2017-12-27 12:42:41.259: startWith -> Event next(1)
2017-12-27 12:42:41.259: startWith -> Event next(2)
2017-12-27 12:42:41.259: startWith -> Event next(3)
2017-12-27 12:42:41.259: startWith -> Event next(Third)
2017-12-27 12:42:41.259: startWith -> Event next(Second)
2017-12-27 12:42:41.259: startWith -> Event next(First)
2017-12-27 12:42:41.259: startWith -> Event next(🐶)
2017-12-27 12:42:41.259: startWith -> Event next(🐱)
2017-12-27 12:42:41.259: startWith -> Event next(🐭)
2017-12-27 12:42:41.259: startWith -> Event next(🐹)
2017-12-27 12:42:41.260: startWith -> Event completed
2017-12-27 12:42:41.260: startWith -> isDisposed
```

## combineLatest

`combineLatest` 操作符将多个 `Observables` 中最新的元素通过一个函数组合起来，然后将这个组合的结果发出来。

**这些源 `Observables` 中任何一个发出一个元素，他都会发出一个元素（前提是，这些 `Observables` 曾经发出过元素）。**

eg:

```swift
func combineLatest() {
    Observable<String>
        .combineLatest(getFirstObservable(), getSecondObservable(), resultSelector: { (fstr, sstr) -> String in
            return fstr + " | " + sstr
        })
        .debug("combineLatest")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下

```swift
2017-12-27 12:45:26.780: combineLatest -> subscribed
2017-12-27 12:45:27.782: combineLatest -> Event next(First -> 1|A | Second -> 1)
2017-12-27 12:45:27.782: combineLatest -> Event next(First -> 1|B | Second -> 1)
2017-12-27 12:45:27.782: combineLatest -> Event next(First -> 1|C | Second -> 1)
2017-12-27 12:45:30.886: combineLatest -> Event next(First -> 1|C | Second -> 2)
2017-12-27 12:45:31.781: combineLatest -> Event next(First -> 2|A | Second -> 2)
2017-12-27 12:45:31.782: combineLatest -> Event next(First -> 2|B | Second -> 2)
2017-12-27 12:45:31.782: combineLatest -> Event next(First -> 2|C | Second -> 2)
2017-12-27 12:45:34.886: combineLatest -> Event next(First -> 2|C | Second -> 3)
2017-12-27 12:45:35.781: combineLatest -> Event next(First -> 3|A | Second -> 3)
2017-12-27 12:45:35.781: combineLatest -> Event next(First -> 3|B | Second -> 3)
2017-12-27 12:45:35.781: combineLatest -> Event next(First -> 3|C | Second -> 3)
2017-12-27 12:45:35.781: combineLatest -> Event completed
2017-12-27 12:45:35.782: combineLatest -> isDisposed
```


## zip

通过一个函数将多个 `Observables` 的元素组合起来，然后将每一个组合的结果发出来。

`zip` 操作符将多个(最多不超过8个) `Observables` 的元素通过一个函数组合起来，然后将这个组合的结果发出来。它会严格的按照序列的索引数进行组合。

例如，返回的 `Observable` 的`第一个元素`，是由`每一个源 Observables ` 的`第一个元素组合`出来的。它的`第二个元素` ，是由`每一个源 Observables ` 的`第二个元素组合`出来的。它的`第三个元素` ，是由`每一个源 Observables ` 的`第三个元素组合`出来的，以此类推。

它的**元素数量等于源 Observables 中元素数量最少的那个**。

eg:

```swift
func zip()  {
    let disposeBag = DisposeBag()
    let first = PublishSubject<String>()
    let second = PublishSubject<String>()
    
    Observable
        .zip(first, second) { $0 + $1 }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    
    first.onNext("1")
    second.onNext("A")
    
    first.onNext("2")
    second.onNext("B")
    
    second.onNext("C")
    second.onNext("D")
    first.onNext("3")
    first.onNext("4")
    first.onNext("5")
}
```

输出如下：

```swift
1A
2B
3C
4D
```

## withLatestFrom

将两 `Observables` 最新的元素通过一个函数组合以来，当第一个 `Observable` 发出一个元素，就将组合后的元素发送出来

`withLatestFrom` 操作符将两个 Observables 中最新的元素通过一个函数组合起来，然后将这个组合的结果发出来。

当第一个 `Observable` 发出一个元素时，就立即取出第二个 `Observable` 中最新的元素，通过一个组合函数将两个最新的元素合并后发送出去。

eg:

```swift
func withLatestFrom() {
    // 当第一个 Observable 发出一个元素时，就立即取出第二个 Observable 中最新的元素，
    // 然后把第二个 Observable 中最新的元素发送出去。
    print("============================First============================")
    getFirstObservable()
        .withLatestFrom(getSecondObservable())
        .debug("withLatestFrom")
        .subscribe()
        .disposed(by: disposeBag)
    
    // 当第一个 Observable 发出一个元素时，就立即取出第二个 Observable 中最新的元素，
    // 然后把第一个 Observable 中最新的元素first和然后把第二个 Observable 中最新的元素second组合first+second发送出去。
    delayTime(10) {
        print("============================Second============================")
        self.getFirstObservable()
            .withLatestFrom(self.getSecondObservable(), resultSelector: { (first, second) -> String in
                return first + " <====> " + second
            })
            .debug("withLatestFrom & Function")
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}
```

输出如下：

```swift
============================First============================
2017-12-27 12:50:16.250: withLatestFrom -> subscribed
2017-12-27 12:50:17.253: withLatestFrom -> Event next(Second -> 1)
2017-12-27 12:50:17.253: withLatestFrom -> Event next(Second -> 1)
2017-12-27 12:50:17.253: withLatestFrom -> Event next(Second -> 1)
2017-12-27 12:50:21.750: withLatestFrom -> Event next(Second -> 2)
2017-12-27 12:50:21.750: withLatestFrom -> Event next(Second -> 2)
2017-12-27 12:50:21.750: withLatestFrom -> Event next(Second -> 2)
2017-12-27 12:50:26.144: withLatestFrom -> Event next(Second -> 3)
2017-12-27 12:50:26.144: withLatestFrom -> Event next(Second -> 3)
2017-12-27 12:50:26.144: withLatestFrom -> Event next(Second -> 3)
2017-12-27 12:50:26.145: withLatestFrom -> Event completed
2017-12-27 12:50:26.145: withLatestFrom -> isDisposed
============================Second============================
2017-12-27 12:50:26.253: withLatestFrom & Function -> subscribed
2017-12-27 12:50:27.254: withLatestFrom & Function -> Event next(First -> 1|A <====> Second -> 1)
2017-12-27 12:50:27.255: withLatestFrom & Function -> Event next(First -> 1|B <====> Second -> 1)
2017-12-27 12:50:27.255: withLatestFrom & Function -> Event next(First -> 1|C <====> Second -> 1)
2017-12-27 12:50:31.254: withLatestFrom & Function -> Event next(First -> 2|A <====> Second -> 2)
2017-12-27 12:50:31.254: withLatestFrom & Function -> Event next(First -> 2|B <====> Second -> 2)
2017-12-27 12:50:31.254: withLatestFrom & Function -> Event next(First -> 2|C <====> Second -> 2)
2017-12-27 12:50:35.253: withLatestFrom & Function -> Event next(First -> 3|A <====> Second -> 3)
2017-12-27 12:50:35.253: withLatestFrom & Function -> Event next(First -> 3|B <====> Second -> 3)
2017-12-27 12:50:35.253: withLatestFrom & Function -> Event next(First -> 3|C <====> Second -> 3)
2017-12-27 12:50:35.254: withLatestFrom & Function -> Event completed
2017-12-27 12:50:35.254: withLatestFrom & Function -> isDisposed
```


## merge

通过使用 `merge` 操作符你可以将多个 `Observables` 合并成一个，当某一个 `Observable` 发出一个元素时，他就将这个元素发出。

如果，某一个 `Observable` 发出一个 `onError` 事件，那么被合并的 `Observable` 也会将它发出，并且立即终止序列。

eg:

```swift
func merge() {
    let subject1 = PublishSubject<String>()
    let subject2 = PublishSubject<String>()
    
    Observable.of(subject1, subject2)
        .merge()
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    subject1.onNext("🅰️")
    subject1.onNext("🅱️")
    subject2.onNext("1️⃣")
    subject2.onNext("2️⃣")
    subject1.onNext("🆎")
    subject2.onNext("3️⃣")
    let err = TError.init(errorCode: 0, errorString: "Test Error", errorData: nil)
    subject1.onError(err)
    subject2.onNext("4️⃣")
    subject2.onNext("5️⃣")
}
```

输出如下：

```swift
2017-12-27 12:56:10.984: merge -> subscribed
2017-12-27 12:56:10.986: merge -> Event next(🅰️)
2017-12-27 12:56:10.986: merge -> Event next(🅱️)
2017-12-27 12:56:10.987: merge -> Event next(1️⃣)
2017-12-27 12:56:10.987: merge -> Event next(2️⃣)
2017-12-27 12:56:10.987: merge -> Event next(🆎)
2017-12-27 12:56:10.987: merge -> Event next(3️⃣)
2017-12-27 12:56:10.988: merge -> Event error(TError(errorCode: 0, errorString: "Test Error", errorData: nil))
Unhandled error happened: TError(errorCode: 0, errorString: "Test Error", errorData: nil)
 subscription called from:
0   RxSwift                             0x0000000109fa158c _T07RxSwift14ObservableTypePAAE9subscribeAA10Disposable_py1EQzcSg6onNext_ys5Error_pcSg0gI0yycSg0G9CompletedAM0G8DisposedtF + 780
1   TestRxSwift                         0x0000000109853023 _T011TestRxSwift8OperatorC5mergeyyF + 1427
2   TestRxSwift                         0x0000000109853884 _T011TestRxSwift8OperatorC5mergeyyFTo + 36
3   TestRxSwift                         0x0000000109877de1 _T011TestRxSwift27OperatorTableViewControllerC11viewDidLoadyyFy10Foundation9IndexPathVcfU1_ + 897
4   TestRxSwift                         0x0000000109877f17 _T011TestRxSwift27OperatorTableViewControllerC11viewDidLoadyyFy10Foundation9IndexPathVcfU1_TA + 103
5   TestRxSwift                         0x0000000109838da0 _T010Foundation9IndexPathVIxx_ACIxi_TR + 48
6   TestRxSwift                         0x0000000109877fa2 _T010Foundation9IndexPathVIxx_ACIxi_TRTA + 66
7   RxSwift                             0x0000000109fa1d35 _T07RxSwift14ObservableTypePAAE9subscribeAA10Disposable_py1EQzcSg6onNext_ys5Error_pcSg0gI0yycSg0G9CompletedAM0G8DisposedtFyAA5EventOyAGGcfU_ + 885
8   RxSwift                             0x0000000109fa228a _T07RxSwift14ObservableTypePAAE9subscribeAA10Disposable_py1EQzcSg6onNext_ys5Error_pcSg0gI0yycSg0G9CompletedAM0G8DisposedtFyAA5EventOyAGGcfU_TA + 282
9   RxSwift                             0x0000000109ed7998 _T07RxSwift17AnonymousObserverC6onCoreyAA5EventOyxGF + 408
10  RxSwift                             0x0000000109fa9026 _T07RxSwift12ObserverBaseC2onyAA5EventOyxGF + 742
11  RxSwift                             0x0000000109fa95be _T07RxSwift12ObserverBaseCyxGAA0C4TypeAAlAaEP2onyAA5EventOy1EQzGFTW + 62
12  RxSwift                             0x0000000109ed8c93 _T0TA + 115
13  RxSwift                             0x0000000109ee33a7 _T07RxSwift5EventOyxGIxi_ADytIxir_1EQyd__RszAA12ObserverTypeRd__r__lTR + 23
14  RxSwift                             0x0000000109ff5bc6 _T07RxSwift5EventOyxGIxi_ADytIxir_1EQyd__RszAA12ObserverTypeRd__r__lTRTA.47 + 118
15  RxSwift                             0x0000000109ee3770 _T07RxSwift5EventOyxGytIxir_ADIxi_lTR + 16
16  RxSwift                             0x0000000109ee5332 _T07RxSwift5EventOyxGytIxir_ADIxi_lTRTA.18 + 82
17  RxSwift                             0x0000000109ee4564 _T07RxSwift8dispatchyAA3BagVyyAA5EventOyxGcG_AGtlF + 900
18  RxSwift                             0x0000000109fef92e _T07RxSwift36ShareReplay1WhileConnectedConnection33_E9FE621655D67A613BF2FC2D9B3041FCLLC2onyAA5EventOyxGF + 1230
19  RxSwift                             0x0000000109ff1aeb _T07RxSwift36ShareReplay1WhileConnectedConnection33_E9FE621655D67A613BF2FC2D9B3041FCLLCyxGAA12ObserverTypeAAlAaFP2onyAA5EventOy1EQzGFTW + 43
20  RxSwift                             0x0000000109ffdbcc _T07RxSwift4SinkC9forwardOnyAA5EventOy1EQzGF + 780
21  RxSwift                             0x0000000109ef5ff7 _T07RxSwift9CatchSink33_7E15DB08AB19A7B882D5C92A393C6F6DLLC2onyAA5EventOy1EQzGF + 823
22  RxSwift                             0x0000000109ef6a5b _T07RxSwift9CatchSink33_7E15DB08AB19A7B882D5C92A393C6F6DLLCyxGAA12ObserverTypeA2aFRzlAaFP2onyAA5EventOy1EQzGFTW + 43
23  RxSwift                             0x0000000109fa6f11 _T07RxSwift32ObserveOnSerialDispatchQueueSink33_277A93ABA8477198C125F3F26B2D4B62LLCADyxGAA0efG9SchedulerC9scheduler_x8observerAA10Cancelable_p6canceltcfcAA10Disposable_pAE4sink_AA5EventOy1EQzG5eventtcfU_ + 833
24  RxSwift                             0x0000000109fa8579 _T07RxSwift32ObserveOnSerialDispatchQueueSink33_277A93ABA8477198C125F3F26B2D4B62LLCADyxGAA0efG9SchedulerC9scheduler_x8observerAA10Cancelable_p6canceltcfcAA10Disposable_pAE4sink_AA5EventOy1EQzG5eventtcfU_TA + 9
25  RxSwift                             0x0000000109fa77d9 _T07RxSwift32ObserveOnSerialDispatchQueueSink33_277A93ABA8477198C125F3F26B2D4B62LLCyxGAA5EventOy1EQzGAA10Disposable_pIxxir_AE_AJtAaK_pIxir_AA12ObserverTypeRzlTR + 137
26  RxSwift                             0x0000000109fa8786 _T07RxSwift32ObserveOnSerialDispatchQueueSink33_277A93ABA8477198C125F3F26B2D4B62LLCyxGAA5EventOy1EQzGAA10Disposable_pIxxir_AE_AJtAaK_pIxir_AA12ObserverTypeRzlTRTA + 102
27  RxSwift                             0x0000000109f80564 _T07RxSwift13MainSchedulerC16scheduleInternalAA10Disposable_px_AaE_pxc6actiontlF + 484
28  RxSwift                             0x0000000109feca4d _T07RxSwift28SerialDispatchQueueSchedulerC8scheduleAA10Disposable_px_AaE_pxc6actiontlF + 173
29  RxSwift                             0x0000000109fa76cc _T07RxSwift32ObserveOnSerialDispatchQueueSink33_277A93ABA8477198C125F3F26B2D4B62LLC6onCoreyAA5EventOy1EQzGF + 1148
30  RxSwift                             0x0000000109fa9026 _T07RxSwift12ObserverBaseC2onyAA5EventOyxGF + 742
31  RxSwift                             0x0000000109fa95be _T07RxSwift12ObserverBaseCyxGAA0C4TypeAAlAaEP2onyAA5EventOy1EQzGFTW + 62
32  RxSwift                             0x0000000109ffdbcc _T07RxSwift4SinkC9forwardOnyAA5EventOy1EQzGF + 780
33  RxSwift                             0x000000010a0080e0 _T07RxSwift15SubscribeOnSink33_B44C3DD7F62EF81799E6347E59A266A2LLC2onyAA5EventOy1EQzGF + 400
34  RxSwift                             0x000000010a008e0b _T07RxSwift15SubscribeOnSink33_B44C3DD7F62EF81799E6347E59A266A2LLCyxq_GAA12ObserverTypeA2A010ObservableP0RzAaFR_1EQy_AHRtzr0_lAaFP2onyAA5EventOyAHQzGFTW + 43
35  RxSwift                             0x0000000109ffdbcc _T07RxSwift4SinkC9forwardOnyAA5EventOy1EQzGF + 780
36  RxSwift                             0x0000000109f81695 _T07RxSwift7MapSink33_5428EFA9A9B0C0340021B871D2E5AC01LLC2onyAA5EventOyxGF + 1093
37  RxSwift                             0x0000000109f81beb _T07RxSwift7MapSink33_5428EFA9A9B0C0340021B871D2E5AC01LLCyxq_GAA12ObserverTypeA2aFR_r0_lAaFP2onyAA5EventOy1EQzGFTW + 43
38  RxSwift                             0x0000000109ffdbcc _T07RxSwift4SinkC9forwardOnyAA5EventOy1EQzGF + 780
39  RxSwift                             0x000000010a0080e0 _T07RxSwift15SubscribeOnSink33_B44C3DD7F62EF81799E6347E59A266A2LLC2onyAA5EventOy1EQzGF + 400
40  RxSwift                             0x000000010a008e0b _T07RxSwift15SubscribeOnSink33_B44C3DD7F62EF81799E6347E59A266A2LLCyxq_GAA12ObserverTypeA2A010ObservableP0RzAaFR_1EQy_AHRtzr0_lAaFP2onyAA5EventOyAHQzGFTW + 43
41  RxSwift                             0x0000000109ed8c93 _T0TA + 115
42  RxSwift                             0x0000000109ee33a7 _T07RxSwift5EventOyxGIxi_ADytIxir_1EQyd__RszAA12ObserverTypeRd__r__lTR + 23
43  RxSwift                             0x0000000109ff5a36 _T07RxSwift5EventOyxGIxi_ADytIxir_1EQyd__RszAA12ObserverTypeRd__r__lTRTA + 118
44  RxSwift                             0x0000000109ee3770 _T07RxSwift5EventOyxGytIxir_ADIxi_lTR + 16
45  RxSwift                             0x0000000109ee5332 _T07RxSwift5EventOyxGytIxir_ADIxi_lTRTA.18 + 82
46  RxSwift                             0x0000000109ee4564 _T07RxSwift8dispatchyAA3BagVyyAA5EventOyxGcG_AGtlF + 900
47  RxSwift                             0x0000000109ff2eee _T07RxSwift29ShareWhileConnectedConnection33_E9FE621655D67A613BF2FC2D9B3041FCLLC2onyAA5EventOyxGF + 1230
48  RxSwift                             0x0000000109ff4abb _T07RxSwift29ShareWhileConnectedConnection33_E9FE621655D67A613BF2FC2D9B3041FCLLCyxGAA12ObserverTypeAAlAaFP2onyAA5EventOy1EQzGFTW + 43
49  RxSwift                             0x0000000109ffdbcc _T07RxSwift4SinkC9forwardOnyAA5EventOy1EQzGF + 780
50  RxSwift                             0x0000000109f66dfb _T07RxSwift6DoSink33_51F9E615740E91B2E920965FFBB1EED3LLC2onyAA5EventOy1EQzGF + 843
51  RxSwift                             0x0000000109f674eb _T07RxSwift6DoSink33_51F9E615740E91B2E920965FFBB1EED3LLCyxGAA12ObserverTypeA2aFRzlAaFP2onyAA5EventOy1EQzGFTW + 43
52  RxSwift                             0x0000000109ed8c93 _T0TA + 115
53  RxSwift                             0x0000000109ee33a7 _T07RxSwift5EventOyxGIxi_ADytIxir_1EQyd__RszAA12ObserverTypeRd__r__lTR + 23
54  RxSwift                             0x0000000109fbd396 _T07RxSwift5EventOyxGIxi_ADytIxir_1EQyd__RszAA12ObserverTypeRd__r__lTRTA + 118
55  RxSwift                             0x0000000109ee3770 _T07RxSwift5EventOyxGytIxir_ADIxi_lTR + 16
56  RxSwift                             0x0000000109ee5332 _T07RxSwift5EventOyxGytIxir_ADIxi_lTRTA.18 + 82
57  RxSwift                             0x0000000109ee4564 _T07RxSwift8dispatchyAA3BagVyyAA5EventOyxGcG_AGtlF + 900
58  RxSwift                             0x0000000109fbb1ca _T07RxSwift14PublishSubjectC2onyAA5EventOyxGF + 1018
59  RxCocoa                             0x0000000109c6cd91 _T07RxSwift14PublishSubjectC2onyAA5EventOyxGFTA + 17
60  RxCocoa                             0x0000000109c6c46d _T07RxSwift5EventOySayypGGIxi_AEIxx_TR + 29
61  RxCocoa                             0x0000000109c6cd6e _T07RxSwift5EventOySayypGGIxi_AEIxx_TRTA + 78
62  RxCocoa                             0x0000000109c6a5eb _T07RxCocoa13DelegateProxyC14_methodInvokedy10ObjectiveC8SelectorV_SayypG13withArgumentstF + 283
63  RxCocoa                             0x0000000109c6a664 _T07RxCocoa13DelegateProxyC14_methodInvokedy10ObjectiveC8SelectorV_SayypG13withArgumentstFTo + 84
64  RxCocoa                             0x0000000109c3b588 -[_RXDelegateProxy forwardInvocation:] + 536
65  CoreFoundation                      0x000000010dee1cd8 ___forwarding___ + 760
66  CoreFoundation                      0x000000010dee1958 _CF_forwarding_prep_0 + 120
67  UIKit                               0x000000010b309839 -[UITableView _selectRowAtIndexPath:animated:scrollPosition:notifyDelegate:] + 1810
68  UIKit                               0x000000010b309a54 -[UITableView _userSelectRowAtPendingSelectionIndexPath:] + 344
69  UIKit                               0x000000010b1d2d59 _runAfterCACommitDeferredBlocks + 318
70  UIKit                               0x000000010b1c1bb1 _cleanUpAfterCAFlushAndRunDeferredBlocks + 280
71  UIKit                               0x000000010b1f10e0 _afterCACommitHandler + 137
72  CoreFoundation                      0x000000010df01c07 __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__ + 23
73  CoreFoundation                      0x000000010df01b5e __CFRunLoopDoObservers + 430
74  CoreFoundation                      0x000000010dee6124 __CFRunLoopRun + 1572
75  CoreFoundation                      0x000000010dee5889 CFRunLoopRunSpecific + 409
76  GraphicsServices                    0x00000001136149c6 GSEventRunModal + 62
77  UIKit                               0x000000010b1c75d6 UIApplicationMain + 159
78  TestRxSwift                         0x0000000109858c07 main + 55
79  libdyld.dylib                       0x000000010f7bcd81 start + 1
80  ???                                 0x0000000000000001 0x0 + 1
2017-12-27 12:56:10.991: merge -> isDisposed
```

## switchLatest

当你的事件序列是一个事件序列的序列 (`Observable<Observable<T>>`) 的时候，（可以理解成二维序列）

可以使用 `switch` 将序列的序列平铺成一维，并且在出现新的序列的时候，自动切换到最新的那个序列上。

和 `merge` 相似的是，它也是起到了将多个序列`拍平`成一条序列的作用。


> ⚠️注意：当源 `Observable` 发出一个新的 `Observable` 时，而不是当新的 `Observable` 发出一个项目时，它将从之前发出的Observable中取消订阅。
> 
>> 这意味着在后面的 `Observable` 被发射的时间和随后的 `Observable` 本身开始发射的时间之间，前一个 `Observable` 发射的物体将被丢弃。

eg:

```swift
func switchLatest() {
    // 第一个： 发送3个元素
    let innerObservable_1 = Observable<String>.of("innerObservable_1: 1",
                                                  "innerObservable_1: 2",
                                                  "innerObservable_1: 3")
    // 持续1秒发出一个元素，递增
    let innerObservable_2 = Observable<Int>.interval(1, scheduler: MainScheduler.instance).map { (value) -> String in
        print("innerObservable_2 => Send \(value)")
        return "innerObservable_2: \(value)"
    }
    // 持续1秒发出一个元素，递增
    let innerObservable_3 = Observable<Int>.interval(1, scheduler: MainScheduler.instance).map { (value) -> String in
        print("innerObservable_3 => Send \(value)")
        return "innerObservable_3: \(value)"
    }
    
    let externalObservable = Observable<Observable<String>>.create({ (observer) -> Disposable in
        observer.onNext(innerObservable_1)
        delayTime(2, block: {
            observer.onNext(innerObservable_2)
        })
        
        delayTime(6, block: {
            observer.onNext(innerObservable_3)
        })
        delayTime(12, block: {
            // 不加 observer.onNext(Observable<String>.never()) 的话，innerObservable_3会持续不断的发送
            print("observer.onNext(Observable<String>.never())")
            print("observer.onCompleted()")
            observer.onNext(Observable<String>.never())
            observer.onCompleted()
        })
        return Disposables.create()
    })
    
    externalObservable
        .switchLatest()
        .debug("switchLatest")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 12:59:48.877: switchLatest -> subscribed
2017-12-27 12:59:48.878: switchLatest -> Event next(innerObservable_1: 1)
2017-12-27 12:59:48.878: switchLatest -> Event next(innerObservable_1: 2)
2017-12-27 12:59:48.878: switchLatest -> Event next(innerObservable_1: 3)
innerObservable_2 => Send 0
2017-12-27 12:59:51.880: switchLatest -> Event next(innerObservable_2: 0)
innerObservable_2 => Send 1
2017-12-27 12:59:52.881: switchLatest -> Event next(innerObservable_2: 1)
innerObservable_2 => Send 2
2017-12-27 12:59:53.881: switchLatest -> Event next(innerObservable_2: 2)
innerObservable_3 => Send 0
2017-12-27 12:59:55.879: switchLatest -> Event next(innerObservable_3: 0)
innerObservable_3 => Send 1
2017-12-27 12:59:56.879: switchLatest -> Event next(innerObservable_3: 1)
innerObservable_3 => Send 2
2017-12-27 12:59:57.878: switchLatest -> Event next(innerObservable_3: 2)
innerObservable_3 => Send 3
2017-12-27 12:59:58.879: switchLatest -> Event next(innerObservable_3: 3)
innerObservable_3 => Send 4
2017-12-27 12:59:59.878: switchLatest -> Event next(innerObservable_3: 4)
observer.onNext(Observable<String>.never())
observer.onCompleted()
```



