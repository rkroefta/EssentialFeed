//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Rodrigo Kroef Tarouco on 12/02/24.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
