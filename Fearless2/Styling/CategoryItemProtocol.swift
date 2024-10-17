//
//  CategoryItemProtocol.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/14/24.
//

import Foundation
import SwiftUI

protocol CategoryItemProtocol {
    func getFullName() -> String
    func getShortName() -> String
    func getBubbleTextColor() -> Color
    func getBubbleColor() -> Color
}
