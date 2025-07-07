//
//  WebsocketTypes.swift
//  
//
//  Created by Adrian Williams on 03/07/2025.
//

import Foundation

struct Item: Codable {
    let id: UUID
    let text: String
}

enum IncomingMessage: Decodable {
    case text(message: String)
//    case items(items: [Item])
//    case update(item: Item)
//    case add(item: Item)
//    case delete(item: Item)
}

enum OutgoingMessage: Encodable {
    case text(message: String)
//    case update(item: Item)
//    case add(item: Item)
//    case delete(id: UUID)
}
