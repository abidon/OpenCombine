//
//  Publishers.CombineLatest.swift
//
//
//  Created by Aurelien Bidon on 23.07.2024.
//

extension Publishers {
    /// A publisher that receives and combines the latest elements from two publishers.
    public struct CombineLatest<A, B> : Publisher where
        A : Publisher,
        B : Publisher,
        A.Failure == B.Failure
    {

        /// The kind of values published by this publisher.
        public typealias Output = (A.Output, B.Output)

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure

        public let a: A
        public let b: B

        public init(_ a: A, _ b: B) {
            self.a = a
            self.b = b
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where
            S : Subscriber,
            B.Failure == S.Failure,
            S.Input == (A.Output, B.Output)
        {
            let subscription = DownstreamSubscription<S>(downstream: subscriber, self.a, self.b)
            subscriber.receive(subscription: subscription)
        }
    }
    
    /// A publisher that receives and combines the latest elements from three publishers.
    public struct CombineLatest3<A, B, C> : Publisher where
        A : Publisher,
        B : Publisher,
        C : Publisher,
        A.Failure == B.Failure,
        B.Failure == C.Failure
    {

        /// The kind of values published by this publisher.
        public typealias Output = (A.Output, B.Output, C.Output)

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure

        public let a: A
        public let b: B
        public let c: C

        public init(_ a: A, _ b: B, _ c: C) {
            self.a = a
            self.b = b
            self.c = c
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where
            S : Subscriber,
            C.Failure == S.Failure,
            S.Input == (A.Output, B.Output, C.Output)
        {
            let subscription = DownstreamSubscription<S>(downstream: subscriber, self.a, self.b, self.c)
            subscriber.receive(subscription: subscription)
        }
    }

    /// A publisher that receives and combines the latest elements from four publishers.
    public struct CombineLatest4<A, B, C, D> : Publisher where A : Publisher, B : Publisher, C : Publisher, D : Publisher, A.Failure == B.Failure, B.Failure == C.Failure, C.Failure == D.Failure {

        /// The kind of values published by this publisher.
        public typealias Output = (A.Output, B.Output, C.Output, D.Output)

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = A.Failure

        public let a: A
        public let b: B
        public let c: C
        public let d: D

        public init(_ a: A, _ b: B, _ c: C, _ d: D) {
            self.a = a
            self.b = b
            self.c = c
            self.d = d
        }

        /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
        ///
        /// - SeeAlso: `subscribe(_:)`
        /// - Parameters:
        ///     - subscriber: The subscriber to attach to this `Publisher`.
        ///                   once attached it can begin to receive values.
        public func receive<S>(subscriber: S) where
            S : Subscriber,
            D.Failure == S.Failure,
            S.Input == (A.Output, B.Output, C.Output, D.Output)
        {
            let subscription = DownstreamSubscription<S>(downstream: subscriber, self.a, self.b, self.c, self.d)
            subscriber.receive(subscription: subscription)
        }
    }
    
}

extension Publisher {
    
    /// Subscribes to an additional publisher and publishes a tuple upon receiving output from either publisher.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// All upstream publishers need to finish for this publisher to finsh. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - other: Another publisher to combine with this one.
    /// - Returns: A publisher that receives and combines elements from this and another publisher.
    public func combineLatest<P>(_ other: P) -> Publishers.CombineLatest<Self, P> where
        P : Publisher,
        Self.Failure == P.Failure
    {
        return Publishers.CombineLatest(self, other)
    }
    
    /// Subscribes to an additional publisher and invokes a closure upon receiving output from either publisher.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// All upstream publishers need to finish for this publisher to finsh. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - other: Another publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this and another publisher.
    public func combineLatest<P, T>(
        _ other: P,
        _ transform: @escaping (Self.Output, P.Output) -> T
    ) -> Publishers.Map<Publishers.CombineLatest<Self, P>, T> where
        P : Publisher,
        Self.Failure == P.Failure
    {
        return Publishers.Map(
            upstream: Publishers.CombineLatest(self, other),
            transform: transform
        )
    }
    
    /// Subscribes to two additional publishers and publishes a tuple upon receiving output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    /// - Returns: A publisher that receives and combines elements from this publisher and two other publishers.
    public func combineLatest<P, Q>(
        _ publisher1: P,
        _ publisher2: Q
    ) -> Publishers.CombineLatest3<Self, P, Q> where
        P : Publisher,
        Q : Publisher,
        Self.Failure == P.Failure,
        P.Failure == Q.Failure
    {
        return Publishers.CombineLatest3(self, publisher1, publisher2)
    }

    /// Subscribes to two additional publishers and invokes a closure upon receiving output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this publisher and two other publishers.
    public func combineLatest<P, Q, T>(
        _ publisher1: P,
        _ publisher2: Q,
        _ transform: @escaping (Self.Output, P.Output, Q.Output) -> T
    ) -> Publishers.Map<Publishers.CombineLatest3<Self, P, Q>, T> where
        P : Publisher,
        Q : Publisher,
        Self.Failure == P.Failure,
        P.Failure == Q.Failure
    {
        return Publishers.Map(
            upstream: Publishers.CombineLatest3(self, publisher1, publisher2),
            transform: transform
        )
    }
    
    /// Subscribes to three additional publishers and publishes a tuple upon receiving output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    ///   - publisher3: A fourth publisher to combine with this one.
    /// - Returns: A publisher that receives and combines elements from this publisher and three other publishers.
    public func combineLatest<P, Q, R>(
        _ publisher1: P,
        _ publisher2: Q,
        _ publisher3: R
    ) -> Publishers.CombineLatest4<Self, P, Q, R> where
        P : Publisher,
        Q : Publisher,
        R : Publisher,
        Self.Failure == P.Failure,
        P.Failure == Q.Failure,
        Q.Failure == R.Failure
    {
        return Publishers.CombineLatest4(self, publisher1, publisher2, publisher3)
    }

    /// Subscribes to three additional publishers and invokes a closure upon receiving output from any of the publishers.
    ///
    /// The combined publisher passes through any requests to *all* upstream publishers. However, it still obeys the demand-fulfilling rule of only sending the request amount downstream. If the demand isn’t `.unlimited`, it drops values from upstream publishers. It implements this by using a buffer size of 1 for each upstream, and holds the most recent value in each buffer.
    /// All upstream publishers need to finish for this publisher to finish. If an upstream publisher never publishes a value, this publisher never finishes.
    /// If any of the combined publishers terminates with a failure, this publisher also fails.
    /// - Parameters:
    ///   - publisher1: A second publisher to combine with this one.
    ///   - publisher2: A third publisher to combine with this one.
    ///   - publisher3: A fourth publisher to combine with this one.
    ///   - transform: A closure that receives the most recent value from each publisher and returns a new value to publish.
    /// - Returns: A publisher that receives and combines elements from this publisher and three other publishers.
    public func combineLatest<P, Q, R, T>(_ publisher1: P, _ publisher2: Q, _ publisher3: R, _ transform: @escaping (Self.Output, P.Output, Q.Output, R.Output) -> T) -> Publishers.Map<Publishers.CombineLatest4<Self, P, Q, R>, T> where P : Publisher, Q : Publisher, R : Publisher, Self.Failure == P.Failure, P.Failure == Q.Failure, Q.Failure == R.Failure {
        return Publishers.Map(
            upstream: Publishers.CombineLatest4(self, publisher1, publisher2, publisher3),
            transform: transform
        )
    }
    
}

fileprivate protocol AnyDownstreamSubscription<InputA, InputB, InputC, InputD, Failure>: AnyObject, Subscription {
    associatedtype Failure: Error
    associatedtype InputA
    associatedtype InputB
    associatedtype InputC
    associatedtype InputD
    
    func receive(subscription: Subscription, from upstreamId: UpstreamId)
    func receive(inputFromA input: InputA)
    func receive(inputFromB input: InputB)
    func receive(inputFromC input: InputC)
    func receive(inputFromD input: InputD)
    func receive(completion: Subscribers.Completion<Failure>, from upstreamId: UpstreamId)
}

extension AnyDownstreamSubscription {
    var focusedOnA: FocusedDownstreamSubscription<InputA, Failure> {
        return .init(
            receiveSubscription: { self.receive(subscription: $0, from: .a) },
            receiveInput: { self.receive(inputFromA: $0) },
            receiveCompletion: { self.receive(completion: $0, from: .a) }
        )
    }
    
    var focusedOnB: FocusedDownstreamSubscription<InputB, Failure> {
        return .init(
            receiveSubscription: { self.receive(subscription: $0, from: .b) },
            receiveInput: { self.receive(inputFromB: $0) },
            receiveCompletion: { self.receive(completion: $0, from: .b) }
        )
    }
    
    var focusedOnC: FocusedDownstreamSubscription<InputC, Failure> {
        return .init(
            receiveSubscription: { self.receive(subscription: $0, from: .c) },
            receiveInput: { self.receive(inputFromC: $0) },
            receiveCompletion: { self.receive(completion: $0, from: .c) }
        )
    }
    
    var focusedOnD: FocusedDownstreamSubscription<InputD, Failure> {
        return .init(
            receiveSubscription: { self.receive(subscription: $0, from: .d) },
            receiveInput: { self.receive(inputFromD: $0) },
            receiveCompletion: { self.receive(completion: $0, from: .d) }
        )
    }
}

fileprivate struct FocusedDownstreamSubscription<Input, Failure: Error> {
    let receiveSubscription: (Subscription) -> Void
    let receiveInput: (Input) -> Void
    let receiveCompletion: (Subscribers.Completion<Failure>) -> Void
}

extension AnyDownstreamSubscription where InputC == Never {
    func receive(inputFromC input: InputC) {}
}

extension AnyDownstreamSubscription where InputD == Never {
    func receive(inputFromD input: InputD) {}
}

extension Publishers.CombineLatest {
    private class DownstreamSubscription<Downstream: Subscriber>: AnyDownstreamSubscription, CustomStringConvertible
        where Downstream.Failure == Failure,
        Downstream.Input == (A.Output, B.Output)
    {
        typealias InputA = A.Output
        typealias InputB = B.Output
        typealias InputC = Never
        typealias InputD = Never
        
        let description = "CombineLatest"
        
        private var downstream: Downstream?
        private var latestA: InputA?
        private var latestB: InputB?
        private var completionA: Subscribers.Completion<Failure>?
        private var completionB: Subscribers.Completion<Failure>?
        private var subscriptionA: Subscription?
        private var subscriptionB: Subscription?
        
        private var isComplete: Bool {
            switch (completionA, completionB) {
            case (.finished, .finished), (.failure, _), (_, .failure): return true
            default: return false
            }
        }

        init(downstream: Downstream, _ a: A, _ b: B) {
            self.downstream = downstream
            a.subscribe(UpstreamSubscriber<Downstream, A.Output>(parent: self.focusedOnA))
            b.subscribe(UpstreamSubscriber<Downstream, B.Output>(parent: self.focusedOnB))
        }
        
        func receive(subscription: any Subscription, from upstreamId: UpstreamId) {
            switch upstreamId {
            case .a:
                self.subscriptionA = subscription
            case .b:
                self.subscriptionB = subscription
            default:
                fatalError("Receiving subscription from invalid upstream `\(upstreamId)`")
            }
        }
        
        private func forwardToDownstream() {
            guard !isComplete else { return }
            if let latestA, let latestB {
                _ = downstream?.receive((latestA, latestB))
            }
        }
        
        func receive(inputFromA input: A.Output) {
            guard !isComplete else { return }
            self.latestA = input
            self.forwardToDownstream()
        }
        
        func receive(inputFromB input: B.Output) {
            guard !isComplete else { return }
            self.latestB = input
            self.forwardToDownstream()
        }
        
        func receive(completion: Subscribers.Completion<Failure>, from upstreamId: UpstreamId) {
            guard !isComplete else { return }
            
            switch upstreamId {
            case .a:
                self.completionA = completion
            case .b:
                self.completionB = completion
            default:
                fatalError("Receiving input from invalid upstream `\(upstreamId)`")
            }
            
            if case .failure = completion {
                downstream?.receive(completion: completion)
            } else if case .finished = completionA, case .finished = completionB {
                downstream?.receive(completion: .finished)
            }
        }
        
        func request(_ demand: Subscribers.Demand) {
            subscriptionA?.request(demand)
            subscriptionB?.request(demand)
        }
        
        func cancel() {
            subscriptionA?.cancel()
            subscriptionB?.cancel()
            downstream = nil
        }
    }
}

extension Publishers.CombineLatest3 {
    private class DownstreamSubscription<Downstream: Subscriber>: AnyDownstreamSubscription, CustomStringConvertible
        where Downstream.Failure == Failure,
        Downstream.Input == (A.Output, B.Output, C.Output)
    {
        typealias InputA = A.Output
        typealias InputB = B.Output
        typealias InputC = C.Output
        typealias InputD = Never
        
        let description = "CombineLatest"
        
        private var downstream: Downstream?
        private var latestA: InputA?
        private var latestB: InputB?
        private var latestC: InputC?
        private var completionA: Subscribers.Completion<Failure>?
        private var completionB: Subscribers.Completion<Failure>?
        private var completionC: Subscribers.Completion<Failure>?
        private var subscriptionA: Subscription?
        private var subscriptionB: Subscription?
        private var subscriptionC: Subscription?
        
        private var isComplete: Bool {
            switch (completionA, completionB, completionC) {
            case (.finished, .finished, .finished),
                (.failure, _, _),
                (_, .failure, _),
                (_, _, .failure): return true
            default: return false
            }
        }

        init(downstream: Downstream, _ a: A, _ b: B, _ c: C) {
            self.downstream = downstream
            a.subscribe(UpstreamSubscriber<Downstream, A.Output>(parent: self.focusedOnA))
            b.subscribe(UpstreamSubscriber<Downstream, B.Output>(parent: self.focusedOnB))
            c.subscribe(UpstreamSubscriber<Downstream, C.Output>(parent: self.focusedOnC))
        }
        
        func receive(subscription: any Subscription, from upstreamId: UpstreamId) {
            switch upstreamId {
            case .a:
                self.subscriptionA = subscription
            case .b:
                self.subscriptionB = subscription
            case .c:
                self.subscriptionC = subscription
            default:
                fatalError("Receiving subscription from invalid upstream `\(upstreamId)`")
            }
        }
        
        private func forwardToDownstream() {
            guard !isComplete else { return }
            if let latestA, let latestB, let latestC {
                _ = downstream?.receive((latestA, latestB, latestC))
            }
        }
        
        func receive(inputFromA input: A.Output) {
            guard !isComplete else { return }
            self.latestA = input
            self.forwardToDownstream()
        }
        
        func receive(inputFromB input: B.Output) {
            guard !isComplete else { return }
            self.latestB = input
            self.forwardToDownstream()
        }
        
        func receive(inputFromC input: C.Output) {
            guard !isComplete else { return }
            self.latestC = input
            self.forwardToDownstream()
        }
        
        func receive(completion: Subscribers.Completion<Failure>, from upstreamId: UpstreamId) {
            guard !isComplete else { return }
            
            switch upstreamId {
            case .a:
                self.completionA = completion
            case .b:
                self.completionB = completion
            case .c:
                self.completionC = completion
            default:
                fatalError("Receiving input from invalid upstream `\(upstreamId)`")
            }
            
            if case .failure = completion {
                downstream?.receive(completion: completion)
            } else if case .finished = completionA, case .finished = completionB {
                downstream?.receive(completion: .finished)
            }
        }
        
        func request(_ demand: Subscribers.Demand) {
            subscriptionA?.request(demand)
            subscriptionB?.request(demand)
            subscriptionC?.request(demand)
        }
        
        func cancel() {
            subscriptionA?.cancel()
            subscriptionB?.cancel()
            subscriptionC?.cancel()
            downstream = nil
        }
    }
}

extension Publishers.CombineLatest4 {
    private class DownstreamSubscription<Downstream: Subscriber>: AnyDownstreamSubscription, CustomStringConvertible
        where Downstream.Failure == Failure,
        Downstream.Input == (A.Output, B.Output, C.Output, D.Output)
    {
        typealias InputA = A.Output
        typealias InputB = B.Output
        typealias InputC = C.Output
        typealias InputD = D.Output
        
        let description = "CombineLatest"
        
        private var downstream: Downstream?
        private var latestA: InputA?
        private var latestB: InputB?
        private var latestC: InputC?
        private var latestD: InputD?
        private var completionA: Subscribers.Completion<Failure>?
        private var completionB: Subscribers.Completion<Failure>?
        private var completionC: Subscribers.Completion<Failure>?
        private var completionD: Subscribers.Completion<Failure>?
        private var subscriptionA: Subscription?
        private var subscriptionB: Subscription?
        private var subscriptionC: Subscription?
        private var subscriptionD: Subscription?
        
        private var isComplete: Bool {
            switch (completionA, completionB, completionC, completionD) {
            case (.finished, .finished, .finished, .finished),
                (.failure, _, _, _),
                (_, .failure, _, _),
                (_, _, .failure, _),
                (_, _, _, .failure): return true
            default: return false
            }
        }

        init(downstream: Downstream, _ a: A, _ b: B, _ c: C, _ d: D) {
            self.downstream = downstream
            a.subscribe(UpstreamSubscriber<Downstream, A.Output>(parent: self.focusedOnA))
            b.subscribe(UpstreamSubscriber<Downstream, B.Output>(parent: self.focusedOnB))
            c.subscribe(UpstreamSubscriber<Downstream, C.Output>(parent: self.focusedOnC))
            d.subscribe(UpstreamSubscriber<Downstream, D.Output>(parent: self.focusedOnD))
        }
        
        func receive(subscription: any Subscription, from upstreamId: UpstreamId) {
            switch upstreamId {
            case .a:
                self.subscriptionA = subscription
            case .b:
                self.subscriptionB = subscription
            case .c:
                self.subscriptionC = subscription
            case .d:
                self.subscriptionD = subscription
            }
        }
        
        private func forwardToDownstream() {
            guard !isComplete else { return }
            if let latestA, let latestB, let latestC, let latestD {
                _ = downstream?.receive((latestA, latestB, latestC, latestD))
            }
        }
        
        func receive(inputFromA input: A.Output) {
            guard !isComplete else { return }
            self.latestA = input
            self.forwardToDownstream()
        }
        
        func receive(inputFromB input: B.Output) {
            guard !isComplete else { return }
            self.latestB = input
            self.forwardToDownstream()
        }
        
        func receive(inputFromC input: C.Output) {
            guard !isComplete else { return }
            self.latestC = input
            self.forwardToDownstream()
        }
        
        func receive(inputFromD input: D.Output) {
            guard !isComplete else { return }
            self.latestD = input
            self.forwardToDownstream()
        }
        
        func receive(completion: Subscribers.Completion<Failure>, from upstreamId: UpstreamId) {
            guard !isComplete else { return }
            
            switch upstreamId {
            case .a:
                self.completionA = completion
            case .b:
                self.completionB = completion
            case .c:
                self.completionC = completion
            case .d:
                self.completionD = completion
            }
            
            if case .failure = completion {
                downstream?.receive(completion: completion)
            } else if case .finished = completionA, case .finished = completionB {
                downstream?.receive(completion: .finished)
            }
        }
        
        func request(_ demand: Subscribers.Demand) {
            subscriptionA?.request(demand)
            subscriptionB?.request(demand)
            subscriptionC?.request(demand)
            subscriptionD?.request(demand)
        }
        
        func cancel() {
            subscriptionA?.cancel()
            subscriptionB?.cancel()
            subscriptionC?.cancel()
            subscriptionD?.cancel()
            downstream = nil
        }
    }
}

fileprivate enum UpstreamId {
    case a
    case b
    case c
    case d
}

fileprivate class UpstreamSubscriber<Downstream: Subscriber, Input>: Subscriber {
    typealias Input = Input
    typealias Failure = Downstream.Failure
    
    private let parent: FocusedDownstreamSubscription<Input, Failure>
    
    public init(
        parent: FocusedDownstreamSubscription<Input, Failure>
    ) {
        self.parent = parent
    }
    
    func receive(subscription: any Subscription) {
        parent.receiveSubscription(subscription)
        subscription.request(.unlimited)
    }
    
    func receive(_ input: Input) -> Subscribers.Demand {
        parent.receiveInput(input)
        return .unlimited
    }
    
    func receive(completion: Subscribers.Completion<Downstream.Failure>) {
        parent.receiveCompletion(completion)
    }
}
