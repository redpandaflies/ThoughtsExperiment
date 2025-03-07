//
//  FocusAreasCalculator.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/19/25.
//

import SwiftUI

struct FocusAreasLimitCalculator {
    /**
     Calculates the number of paths based on topic count:
     - Topic 1: 3 paths
     - Topic 2: 4 paths
     - Topics 3-4: 5 paths
     - Topics 5-6: 6 paths
     - Topic 7+: 7 paths
     
     - Parameter topicCount: The total number of topics
     - Returns: The number of paths needed
     */
    static func calculatePaths(topicIndex: Int, totalTopics: Int) -> Int {
        
        let topicNumber = totalTopics - topicIndex //needed because the latest topic is shown first in the scrollview and has the lowest index
        
        return min(topicNumber, 7)
    }
    
   
}
