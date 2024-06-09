//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Rodrigo Kroef Tarouco on 04/06/24.
//

import Foundation

public struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
