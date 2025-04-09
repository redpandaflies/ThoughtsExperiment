//
//  MirrorMainView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/8/25.
//

import SwiftUI

struct MirrorMainView: View {
    
    @Binding var categoriesScrollPosition: Int?
    var categories: FetchedResults<Category>
    
    var body: some View {
        MirrorActiveGoalsList(categoriesScrollPosition: $categoriesScrollPosition, categories: categories)
            .padding(.top, 20)
    }
}


