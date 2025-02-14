//
//  TextLimitMax.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/15/24.
//
import SwiftUI

extension Binding where Value == String {
    func max(_ limit: Int) -> Self {
        if self.wrappedValue.count > limit {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.dropLast())
            }
        }
        return self
    }
}
