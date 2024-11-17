//
//  EntryInsightBoxView.swift
//  TrueBlob
//
//  Created by Yue Deng-Wu on 12/20/23.
//

import SwiftUI

struct EntryInsightBoxView: View {
   
    @State private var editableContent: String = ""
    @FocusState private var focusedField: Bool
    
    let insight: Insight
   
    var body: some View {
        HStack {
            
            HStack (spacing: 12){
                    
                TextField("", text: $editableContent, axis: .vertical)
                    .disabled(true)
                    .focused($focusedField)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15))
                    .foregroundStyle(AppColors.whiteDefault)
                    .lineSpacing(3)
                    .onAppear {
                        self.editableContent = insight.insightContent
                    }
                
               
                Spacer()

            }
            .padding(.leading)
            .contentShape(Rectangle())

                
            VStack {
                Image(systemName: insight.markedSaved ? "checkmark.circle.fill" : "plus.circle")
                    .font(.system(size: 17))
                    .fontWeight(.light)
                    .foregroundStyle(AppColors.lightBrown)
                    .padding(.trailing)
                  
            }

            
        } //HStack
        .padding(.vertical)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(insight.markedSaved ? Color.clear : AppColors.lightBrown)
                .fill(insight.markedSaved ? AppColors.insightBoxBackground : Color.clear)
//                .blendMode(.softLight)
        }
    }
}


//
//#Preview {
//    InsightBoxView(emoji: Insight.example.insightEmoji, content: Insight.example.insightContent, markedSaved: false)
//}


