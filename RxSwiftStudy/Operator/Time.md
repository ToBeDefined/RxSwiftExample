
> Time Operator

## delay


`delay` 操作符将修改一个 `Observable`，它会将 `Observable` 的所有元素都拖延一段设定好的时间， 然后才将它们发送出来。

**⚠️注意：是延迟元素的发出时间而不是延迟订阅或者创建 Observable 的时间**

eg:

```swift
func delay() {
    getFourthObservable()
        .delay(5, scheduler: MainScheduler.instance)
        .debug("delay")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 16:38:12.431: delay -> subscribed
> Send onNext("0️⃣")
> Send onNext("1️⃣")
> Send onNext("2️⃣")
2017-12-27 16:38:17.435: delay -> Event next(0️⃣)
2017-12-27 16:38:18.433: delay -> Event next(1️⃣)
2017-12-27 16:38:19.433: delay -> Event next(2️⃣)
```

## delaySubscription

`delaySubscription` 操作符将在经过所设定的时间后，才真正的对 `Observable` 进行订阅操作。

**⚠️注意：是延迟延迟订阅时间，而不是元素的发出时间或者创建 Observable 的时间**

```swift
func delaySubscription() {
    print("Create Observable Now")
    getFourthObservable()
        .delaySubscription(5, scheduler: MainScheduler.instance)
        .debug("delaySubscription")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
Create Observable Now
2017-12-27 16:42:49.984: delaySubscription -> subscribed
> Send onNext("0️⃣")
2017-12-27 16:42:54.989: delaySubscription -> Event next(0️⃣)
> Send onNext("1️⃣")
2017-12-27 16:42:56.086: delaySubscription -> Event next(1️⃣)
> Send onNext("2️⃣")
2017-12-27 16:42:57.179: delaySubscription -> Event next(2️⃣)
```

## defer

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

## interval

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

## timer

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

## timeout

如果源 `Observable` 在规定时间内没有发任何出元素，就产生一个超时的 `error` 事件

`timer` 操作符将使得序列发出一个 `error` 事件，只要 `Observable` 在一段时间内没有产生元素。

eg:

```swift
func timeout() {
    let observable = Observable<Int>.never()
    observable
        .timeout(3, scheduler: MainScheduler.instance)
        .debug("timeout")
        .subscribe()
        .disposed(by: disposeBag)
}
```

输出如下：

```swift
2017-12-27 16:44:32.898: timeout -> subscribed
2017-12-27 16:44:35.899: timeout -> Event error(Sequence timeout.)
Unhandled error happened: Sequence timeout.
 subscription called from:
0   RxSwift                             0x000000010b9db58c _T07RxSwift14ObservableTypePAAE9subscribeAA10Disposable_py1EQzcSg6onNext_ys5Error_pcSg0gI0yycSg0G9CompletedAM0G8DisposedtF + 780
1   RxSwiftExample                         0x000000010b277bae _T011RxSwiftExample8OperatorC7timeoutyyF + 1150
2   RxSwiftExample                         0x000000010b277e04 _T011RxSwiftExample8OperatorC7timeoutyyFTo + 36
3   RxSwiftExample                         0x000000010b2ac771 _T011RxSwiftExample27OperatorTableViewControllerC11viewDidLoadyyFy10Foundation9IndexPathVcfU1_ + 897
4   RxSwiftExample                         0x000000010b2ac8a7 _T011RxSwiftExample27OperatorTableViewControllerC11viewDidLoadyyFy10Foundation9IndexPathVcfU1_TA + 103
5   RxSwiftExample                         0x000000010b26cdc0 _T010Foundation9IndexPathVIxx_ACIxi_TR + 48
6   RxSwiftExample                         0x000000010b2ac932 _T010Foundation9IndexPathVIxx_ACIxi_TRTA + 66
7   RxSwift                             0x000000010b9dbd35 _T07RxSwift14ObservableTypePAAE9subscribeAA10Disposable_py1EQzcSg6onNext_ys5Error_pcSg0gI0yycSg0G9CompletedAM0G8DisposedtFyAA5EventOyAGGcfU_ + 885
8   RxSwift                             0x000000010b9dc28a _T07RxSwift14ObservableTypePAAE9subscribeAA10Disposable_py1EQzcSg6onNext_ys5Error_pcSg0gI0yycSg0G9CompletedAM0G8DisposedtFyAA5EventOyAGGcfU_TA + 282
9   RxSwift                             0x000000010b911998 _T07RxSwift17AnonymousObserverC6onCoreyAA5EventOyxGF + 408
10  RxSwift                             0x000000010b9e3026 _T07RxSwift12ObserverBaseC2onyAA5EventOyxGF + 742
11  RxSwift                             0x000000010b9e35be _T07RxSwift12ObserverBaseCyxGAA0C4TypeAAlAaEP2onyAA5EventOy1EQzGFTW + 62
12  RxSwift                             0x000000010b912c93 _T0TA + 115
13  RxSwift                             0x000000010b91d3a7 _T07RxSwift5EventOyxGIxi_ADytIxir_1EQyd__RszAA12ObserverTypeRd__r__lTR + 23
14  RxSwift                             0x000000010ba2fbc6 _T07RxSwift5EventOyxGIxi_ADytIxir_1EQyd__RszAA12ObserverTypeRd__r__lTRTA.47 + 118
15  RxSwift                             0x000000010b91d770 _T07RxSwift5EventOyxGytIxir_ADIxi_lTR + 16
16  RxSwift                             0x000000010b91f332 _T07RxSwift5EventOyxGytIxir_ADIxi_lTRTA.18 + 82
17  RxSwift                             0x000000010b91e564 _T07RxSwift8dispatchyAA3BagVyyAA5EventOyxGcG_AGtlF + 900
18  RxSwift                             0x000000010ba2992e _T07RxSwift36ShareReplay1WhileConnectedConnection33_E9FE621655D67A613BF2FC2D9B3041FCLLC2onyAA5EventOyxGF + 1230
19  RxSwift                             0x000000010ba2baeb _T07RxSwift36ShareReplay1WhileConnectedConnection33_E9FE621655D67A613BF2FC2D9B3041FCLLCyxGAA12ObserverTypeAAlAaFP2onyAA5EventOy1EQzGFTW + 43
20  RxSwift                             0x000000010ba37bcc _T07RxSwift4SinkC9forwardOnyAA5EventOy1EQzGF + 780
21  RxSwift                             0x000000010b92fff7 _T07RxSwift9CatchSink33_7E15DB08AB19A7B882D5C92A393C6F6DLLC2onyAA5EventOy1EQzGF + 823
22  RxSwift                             0x000000010b930a5b _T07RxSwift9CatchSink33_7E15DB08AB19A7B882D5C92A393C6F6DLLCyxGAA12ObserverTypeA2aFRzlAaFP2onyAA5EventOy1EQzGFTW + 43
23  RxSwift                             0x000000010b9e0f11 _T07RxSwift32ObserveOnSerialDispatchQueueSink33_277A93ABA8477198C125F3F26B2D4B62LLCADyxGAA0efG9SchedulerC9scheduler_x8observerAA10Cancelable_p6canceltcfcAA10Disposable_pAE4sink_AA5EventOy1EQzG5eventtcfU_ + 833
24  RxSwift                             0x000000010b9e2579 _T07RxSwift32ObserveOnSerialDispatchQueueSink33_277A93ABA8477198C125F3F26B2D4B62LLCADyxGAA0efG9SchedulerC9scheduler_x8observerAA10Cancelable_p6canceltcfcAA10Disposable_pAE4sink_AA5EventOy1EQzG5eventtcfU_TA + 9
25  RxSwift                             0x000000010b9e17d9 _T07RxSwift32ObserveOnSerialDispatchQueueSink33_277A93ABA8477198C125F3F26B2D4B62LLCyxGAA5EventOy1EQzGAA10Disposable_pIxxir_AE_AJtAaK_pIxir_AA12ObserverTypeRzlTR + 137
26  RxSwift                             0x000000010b9e2786 _T07RxSwift32ObserveOnSerialDispatchQueueSink33_277A93ABA8477198C125F3F26B2D4B62LLCyxGAA5EventOy1EQzGAA10Disposable_pIxxir_AE_AJtAaK_pIxir_AA12ObserverTypeRzlTRTA + 102
27  RxSwift                             0x000000010b9ba564 _T07RxSwift13MainSchedulerC16scheduleInternalAA10Disposable_px_AaE_pxc6actiontlF + 484
28  RxSwift                             0x000000010ba26a4d _T07RxSwift28SerialDispatchQueueSchedulerC8scheduleAA10Disposable_px_AaE_pxc6actiontlF + 173
29  RxSwift                             0x000000010b9e16cc _T07RxSwift32ObserveOnSerialDispatchQueueSink33_277A93ABA8477198C125F3F26B2D4B62LLC6onCoreyAA5EventOy1EQzGF + 1148
30  RxSwift                             0x000000010b9e3026 _T07RxSwift12ObserverBaseC2onyAA5EventOyxGF + 742
31  RxSwift                             0x000000010b9e35be _T07RxSwift12ObserverBaseCyxGAA0C4TypeAAlAaEP2onyAA5EventOy1EQzGFTW + 62
32  RxSwift                             0x000000010ba37bcc _T07RxSwift4SinkC9forwardOnyAA5EventOy1EQzGF + 780
33  RxSwift                             0x000000010ba420e0 _T07RxSwift15SubscribeOnSink33_B44C3DD7F62EF81799E6347E59A266A2LLC2onyAA5EventOy1EQzGF + 400
34  RxSwift                             0x000000010ba42e0b _T07RxSwift15SubscribeOnSink33_B44C3DD7F62EF81799E6347E59A266A2LLCyxq_GAA12ObserverTypeA2A010ObservableP0RzAaFR_1EQy_AHRtzr0_lAaFP2onyAA5EventOyAHQzGFTW + 43
35  RxSwift                             0x000000010ba37bcc _T07RxSwift4SinkC9forwardOnyAA5EventOy1EQzGF + 780
36  RxSwift                             0x000000010b9bb695 _T07RxSwift7MapSink33_5428EFA9A9B0C0340021B871D2E5AC01LLC2onyAA5EventOyxGF + 1093
37  RxSwift                             0x000000010b9bbbeb _T07RxSwift7MapSink33_5428EFA9A9B0C0340021B871D2E5AC01LLCyxq_GAA12ObserverTypeA2aFR_r0_lAaFP2onyAA5EventOy1EQzGFTW + 43
38  RxSwift                             0x000000010ba37bcc _T07RxSwift4SinkC9forwardOnyAA5EventOy1EQzGF + 780
39  RxSwift                             0x000000010ba420e0 _T07RxSwift15SubscribeOnSink33_B44C3DD7F62EF81799E6347E59A266A2LLC2onyAA5EventOy1EQzGF + 400
40  RxSwift                             0x000000010ba42e0b _T07RxSwift15SubscribeOnSink33_B44C3DD7F62EF81799E6347E59A266A2LLCyxq_GAA12ObserverTypeA2A010ObservableP0RzAaFR_1EQy_AHRtzr0_lAaFP2onyAA5EventOyAHQzGFTW + 43
41  RxSwift                             0x000000010b912c93 _T0TA + 115
42  RxSwift                             0x000000010b91d3a7 _T07RxSwift5EventOyxGIxi_ADytIxir_1EQyd__RszAA12ObserverTypeRd__r__lTR + 23
43  RxSwift                             0x000000010ba2fa36 _T07RxSwift5EventOyxGIxi_ADytIxir_1EQyd__RszAA12ObserverTypeRd__r__lTRTA + 118
44  RxSwift                             0x000000010b91d770 _T07RxSwift5EventOyxGytIxir_ADIxi_lTR + 16
45  RxSwift                             0x000000010b91f332 _T07RxSwift5EventOyxGytIxir_ADIxi_lTRTA.18 + 82
46  RxSwift                             0x000000010b91e564 _T07RxSwift8dispatchyAA3BagVyyAA5EventOyxGcG_AGtlF + 900
47  RxSwift                             0x000000010ba2ceee _T07RxSwift29ShareWhileConnectedConnection33_E9FE621655D67A613BF2FC2D9B3041FCLLC2onyAA5EventOyxGF + 1230
48  RxSwift                             0x000000010ba2eabb _T07RxSwift29ShareWhileConnectedConnection33_E9FE621655D67A613BF2FC2D9B3041FCLLCyxGAA12ObserverTypeAAlAaFP2onyAA5EventOy1EQzGFTW + 43
49  RxSwift                             0x000000010ba37bcc _T07RxSwift4SinkC9forwardOnyAA5EventOy1EQzGF + 780
50  RxSwift                             0x000000010b9a0dfb _T07RxSwift6DoSink33_51F9E615740E91B2E920965FFBB1EED3LLC2onyAA5EventOy1EQzGF + 843
51  RxSwift                             0x000000010b9a14eb _T07RxSwift6DoSink33_51F9E615740E91B2E920965FFBB1EED3LLCyxGAA12ObserverTypeA2aFRzlAaFP2onyAA5EventOy1EQzGFTW + 43
52  RxSwift                             0x000000010b912c93 _T0TA + 115
53  RxSwift                             0x000000010b91d3a7 _T07RxSwift5EventOyxGIxi_ADytIxir_1EQyd__RszAA12ObserverTypeRd__r__lTR + 23
54  RxSwift                             0x000000010b9f7396 _T07RxSwift5EventOyxGIxi_ADytIxir_1EQyd__RszAA12ObserverTypeRd__r__lTRTA + 118
55  RxSwift                             0x000000010b91d770 _T07RxSwift5EventOyxGytIxir_ADIxi_lTR + 16
56  RxSwift                             0x000000010b91f332 _T07RxSwift5EventOyxGytIxir_ADIxi_lTRTA.18 + 82
57  RxSwift                             0x000000010b91e564 _T07RxSwift8dispatchyAA3BagVyyAA5EventOyxGcG_AGtlF + 900
58  RxSwift                             0x000000010b9f51ca _T07RxSwift14PublishSubjectC2onyAA5EventOyxGF + 1018
59  RxCocoa                             0x000000010b6a6d91 _T07RxSwift14PublishSubjectC2onyAA5EventOyxGFTA + 17
60  RxCocoa                             0x000000010b6a646d _T07RxSwift5EventOySayypGGIxi_AEIxx_TR + 29
61  RxCocoa                             0x000000010b6a6d6e _T07RxSwift5EventOySayypGGIxi_AEIxx_TRTA + 78
62  RxCocoa                             0x000000010b6a45eb _T07RxCocoa13DelegateProxyC14_methodInvokedy10ObjectiveC8SelectorV_SayypG13withArgumentstF + 283
63  RxCocoa                             0x000000010b6a4664 _T07RxCocoa13DelegateProxyC14_methodInvokedy10ObjectiveC8SelectorV_SayypG13withArgumentstFTo + 84
64  RxCocoa                             0x000000010b675588 -[_RXDelegateProxy forwardInvocation:] + 536
65  CoreFoundation                      0x000000010f91bcd8 ___forwarding___ + 760
66  CoreFoundation                      0x000000010f91b958 _CF_forwarding_prep_0 + 120
67  UIKit                               0x000000010cd43839 -[UITableView _selectRowAtIndexPath:animated:scrollPosition:notifyDelegate:] + 1810
68  UIKit                               0x000000010cd43a54 -[UITableView _userSelectRowAtPendingSelectionIndexPath:] + 344
69  UIKit                               0x000000010cc0cd59 _runAfterCACommitDeferredBlocks + 318
70  UIKit                               0x000000010cbfbbb1 _cleanUpAfterCAFlushAndRunDeferredBlocks + 280
71  UIKit                               0x000000010cc2b0e0 _afterCACommitHandler + 137
72  CoreFoundation                      0x000000010f93bc07 __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__ + 23
73  CoreFoundation                      0x000000010f93bb5e __CFRunLoopDoObservers + 430
74  CoreFoundation                      0x000000010f920124 __CFRunLoopRun + 1572
75  CoreFoundation                      0x000000010f91f889 CFRunLoopRunSpecific + 409
76  GraphicsServices                    0x000000011504a9c6 GSEventRunModal + 62
77  UIKit                               0x000000010cc015d6 UIApplicationMain + 159
78  RxSwiftExample                         0x000000010b28d597 main + 55
79  libdyld.dylib                       0x00000001111f6d81 start + 1
80  ???                                 0x0000000000000001 0x0 + 1
2017-12-27 16:44:35.902: timeout -> isDisposed
```
