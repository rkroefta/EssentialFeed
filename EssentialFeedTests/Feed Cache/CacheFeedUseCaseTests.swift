//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Rodrigo Kroef Tarouco on 13/05/24.
//

import EssentialFeed
import XCTest

class CacheFeedUseCaseTests: XCTestCase {
    func testInitDoesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receveidMessages, [])
    }

    func testSaveRequestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items) { _ in }


        XCTAssertEqual(store.receveidMessages, [.deleteCachedFeedMessage])
    }

    func testSaveDoesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()

        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.receveidMessages, [.deleteCachedFeedMessage])
    }

    func testSaveRequestsNewCacheInsertionWithTimeStampOnSucessfullDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items) { _ in }
        store.completeDeletionSucessfully()
        
        XCTAssertEqual(store.receveidMessages, [.deleteCachedFeedMessage, .insert(items, timestamp)])
    }

    func testSaveFailsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()

        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }

    func testFailsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()

        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSucessfully()
            store.completeInsertion(with: insertionError)
        }
    }

    func testSaveSucceedsOnSucessfullCacheInsertion() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSucessfully()
            store.completeInsertionSucessfully()
        })
    }

    func test_save_doesNotDeliversDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        var receveidResults = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueItem()])  { receveidResults.append($0) }

        sut = nil
        store.completeDeletion(with: NSError())

        XCTAssertTrue(receveidResults.isEmpty)
    }

    func test_save_doesNotDeliversInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        var receveidResults = [LocalFeedLoader.SaveResult]()
        sut?.save([uniqueItem()])  { receveidResults.append($0) }

        store.completeDeletionSucessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())

        XCTAssertTrue(receveidResults.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(currentDate: @escaping () ->Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoyLeaks(store, file: file, line: line)
        trackForMemoyLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")

        var receveidError: Error?
        sut.save([uniqueItem()]) { error in
            receveidError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receveidError as NSError?, expectedError, file: file, line: line)
    }

    private class FeedStoreSpy: FeedStore {
        enum ReceivedMessage: Equatable {
            case deleteCachedFeedMessage
            case insert([FeedItem], Date)
        }

        private(set) var receveidMessages = [ReceivedMessage]()

        private var deletionCompletions = [DeletionCompletion]()
        private var insertionCompletions = [InsertionCompletion]()


        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            deletionCompletions.append(completion)
            receveidMessages.append(.deleteCachedFeedMessage)
        }

        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }

        func completeDeletionSucessfully(at index: Int = 0) {
            deletionCompletions[index](nil)
        }

        func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompletions.append(completion)
            receveidMessages.append(.insert(items, timestamp))
        }

        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }

        func completeInsertionSucessfully(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
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
