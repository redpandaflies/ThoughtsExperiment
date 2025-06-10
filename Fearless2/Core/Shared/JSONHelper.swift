//
//  JSONHelper.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 6/5/25.
//

import Foundation

struct JSONHelper {
    static func decode<T: Decodable>(_ messageText: String, as type: T.Type) -> T? {
        guard let data = messageText.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
