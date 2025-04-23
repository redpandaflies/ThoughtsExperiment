//
//  QuestionProtocol.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/14/24.
//

import Foundation
import SwiftUI

protocol QuestionProtocol: Identifiable, Codable {
    var id: Int { get }
    var content: String { get set }
    var questionType: QuestionType { get set }
    var options: [String]? { get set }
}
