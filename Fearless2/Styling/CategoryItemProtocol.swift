//
//  CategoryItemProtocol.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/14/24.
//

import Foundation
import SwiftUI

protocol CategoryProtocol: Identifiable {
    var categoryId: UUID {get}
    var categoryName: String { get }
    var categoryEmoji: String { get }
    var categoryLifeArea: String { get }
}

extension Realm: CategoryProtocol {
    
    var categoryId: UUID {self.id}
    var categoryName: String { self.name }
    var categoryEmoji: String {self.emoji}
    var categoryLifeArea: String { self.lifeArea }
}

// Protocol for collections of categories
protocol CategoryCollection {
    associatedtype Item: CategoryProtocol
    var count: Int { get }
    subscript(index: Int) -> Item { get }
    func asArray() -> [Item]
}

// Make FetchedResults conform to CategoryCollection
extension FetchedResults: CategoryCollection where Element == Category {
    func asArray() -> [Category] {
        return Array(self)
    }
}
