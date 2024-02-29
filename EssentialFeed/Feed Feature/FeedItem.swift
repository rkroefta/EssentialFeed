//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Rodrigo Kroef Tarouco on 12/02/24.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
