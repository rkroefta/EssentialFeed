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
    private let currentDate: () -> Date

    init(store: FeedStore, currentDate: @escaping () ->Date = Date.init) {
        self.store = store
        self.currentDate = currentDate
    }

    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void

    enum ReceivedMessage: Equatable {
        case deleteCachedFeedMessage
        case insert([FeedItem], Date)
    }

    private(set) var receveidMessages = [ReceivedMessage]()

    private var deletionCOmpletions = [DeletionCompletion]()

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCOmpletions.append(completion)
        receveidMessages.append(.deleteCachedFeedMessage)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCOmpletions[index](error)
    }

    func completeDeletionSucessfully(at index: Int = 0) {
        deletionCOmpletions[index](nil)
    }

    func insert(_ items: [FeedItem], timestamp: Date) {
        receveidMessages.append(.insert(items, timestamp))
    }


}

class CacheFeedUseCaseTests: XCTestCase {
    func testInitDoesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receveidMessages, [])
    }

    func testSaveRequestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items)


        XCTAssertEqual(store.receveidMessages, [.deleteCachedFeedMessage])
    }

    func testSaveDoesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()

        sut.save(items)
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.receveidMessages, [.deleteCachedFeedMessage])
    }

    func testSaveRequestsNewCacheInsertionWithTimeStampOnSucessfullDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items)
        store.completeDeletionSucessfully()
        
        XCTAssertEqual(store.receveidMessages, [.deleteCachedFeedMessage, .insert(items, timestamp)])
    }



    // MARK: - Helpers

    private func makeSUT(currentDate: @escaping () ->Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
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
