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
    var insertCallCount = 0

    func deleteCachedFeed() {
        deletedCachedFeedCallCount += 1
    }

    func completionDeletion(with error: Error, at index: Int = 0) {

    }


}

class CacheFeedUseCaseTests: XCTestCase {
    
    func testInitDoesNotDeleteCacheUponCreation() {
        let (sut, store) = makeSUT()

        XCTAssertEqual(store.deletedCachedFeedCallCount, 0)
    }

    func testSaveRequestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()

        sut.save(items)
        store.completionDeletion(with: deletionError)

        XCTAssertEqual(store.deletedCachedFeedCallCount, 1)
    }

    func testSaveDoesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items)

        XCTAssertEqual(store.insertCallCount, 0)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoyLeaks(store, file: file, line: line)
        trackForMemoyLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }

    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }

    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }

}