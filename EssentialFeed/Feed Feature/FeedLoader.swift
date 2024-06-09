//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Rodrigo Kroef Tarouco on 12/02/24.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
