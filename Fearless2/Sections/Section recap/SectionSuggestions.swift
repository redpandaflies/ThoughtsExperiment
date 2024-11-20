//
//  SectionSuggestions.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/29/24.
//

import SwiftUI

struct SectionSuggestionsView: View {
    @Binding var selectedOptions: [String]
    let items: [String]
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            
            HStack {
                Text("What would you like to focus on next?")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 19))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.white)
                    .padding(.vertical, 10)
                
                Spacer()
                
            }
            
            Text("Select one")
                .multilineTextAlignment(.leading)
                .font(.system(size: 11))
                .fontWeight(.light)
                .foregroundStyle(Color.white)
                .textCase(.uppercase)
            
          
            ForEach(items, id: \.self) { pill in
                QuestionBubble(selected: selectedOptions.contains(pill), option: pill)
                    .onTapGesture {
                            selectPill(pillLabel: pill)
                    }
            }
            
        }
        .padding(.bottom, 30)
    }
    
    private func selectPill(pillLabel: String) {
        if let index = selectedOptions.firstIndex(of: pillLabel) {
            // If the pill is already selected, remove it
            selectedOptions.remove(at: index)
        } else {
            // Otherwise, add it to the selected pills
            selectedOptions.append(pillLabel)
        }
    }
}


//#Preview {
//    SectionSuggestionsView(selectedOptions: .constant([]), items: ["Hello", "World"])
//}
