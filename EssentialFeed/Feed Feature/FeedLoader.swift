//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Rodrigo Kroef Tarouco on 12/02/24.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
