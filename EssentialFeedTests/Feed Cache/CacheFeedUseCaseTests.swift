//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Rodrigo Kroef Tarouco on 13/05/24.
//

import EssentialFeed
import XCTest

class LocalFeedLoader {
    private let store: FeedStore

    init(store: FeedStore) {
        self.store = store
    }

    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

class FeedStore {
    var deletedCachedFeedCallCount = 0

    func deleteCachedFeed() {
        deletedCachedFeedCallCount += 1
    }


}

class CacheFeedUseCaseTests: XCTestCase {
    
    func testInitDoesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)

        XCTAssertEqual(store.deletedCachedFeedCallCount, 0)
    }

    func testSaveRequestCacheDeletion() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items)

        XCTAssertEqual(store.deletedCachedFeedCallCount, 1)
    }

    // MARK: - Helpers

    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }

    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }

}
