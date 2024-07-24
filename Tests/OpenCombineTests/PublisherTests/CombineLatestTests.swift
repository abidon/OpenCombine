//
//  CombineLatestTests.swift
//
//  Created by Aurelien Bidon on 24.07.2024.
//

import XCTest

#if OPENCOMBINE_COMPATIBILITY_TEST
import Combine
#else
import OpenCombine
#endif

@available(macOS 10.15, iOS 13.0, *)
final class CombineLatestTests: XCTestCase {
    func testCombineLatestCompletesOnlyAfterAllChildrenComplete() {
        let upstreamSubscription = CustomSubscription()
        let child1Publisher = CustomPublisher(subscription: upstreamSubscription)
        let child2Publisher = CustomPublisher(subscription: upstreamSubscription)

        let combined = child1Publisher.combineLatest(child2Publisher) { $0 + $1 }

        let downstreamSubscriber = TrackingSubscriberBase<Int, TestingError>(
            receiveSubscription: { $0.request(.unlimited) }
        )

        combined.subscribe(downstreamSubscriber)

        XCTAssertEqual(child1Publisher.send(100), .unlimited)
        XCTAssertEqual(child1Publisher.send(200), .unlimited)
        XCTAssertEqual(child1Publisher.send(300), .unlimited)
        XCTAssertEqual(child2Publisher.send(1), .unlimited)
        child1Publisher.send(completion: .finished)

        XCTAssertEqual(downstreamSubscriber.history, [.subscription("CombineLatest"),
                                                      .value(301)])

        XCTAssertEqual(child2Publisher.send(2), .unlimited)
        XCTAssertEqual(child2Publisher.send(3), .unlimited)
        XCTAssertEqual(downstreamSubscriber.history, [.subscription("CombineLatest"),
                                                      .value(301),
                                                      .value(302),
                                                      .value(303)])

        child2Publisher.send(completion: .finished)
        XCTAssertEqual(downstreamSubscriber.history, [.subscription("CombineLatest"),
                                                      .value(301),
                                                      .value(302),
                                                      .value(303),
                                                      .completion(.finished)])

        XCTAssertEqual(
            upstreamSubscription.history,
            [.requested(.unlimited), .requested(.unlimited), .requested(.unlimited), .requested(.unlimited)]
        )
    }
}
