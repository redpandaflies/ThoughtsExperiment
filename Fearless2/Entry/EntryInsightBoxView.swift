//
//  EntryInsightBoxView.swift
//  TrueBlob
//
//  Created by Yue Deng-Wu on 12/20/23.
//

import SwiftUI

struct EntryInsightBoxView: View {
    @EnvironmentObject var dataController: DataController
    @State private var editableContent: String = ""
    @FocusState private var focusedField: Bool
    
    @ObservedObject var insight: Insight
   
    var body: some View {
        HStack {
            
            HStack (spacing: 12){
                    
                TextField("", text: $editableContent, axis: .vertical)
                    .disabled(true)
                    .focused($focusedField)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15))
                    .foregroundStyle(insight.markedSaved ? Color.black : AppColors.whiteDefault)
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
                    .font(.system(size: 20))
                    .fontWeight(.light)
                    .foregroundStyle(insight.markedSaved ? Color.black : AppColors.lightBrown)
                    .padding(.trailing)
                  
            }
            .contentShape(Rectangle())
            .onTapGesture {
                saveInsight()
            }

            
        } //HStack
        .padding(.vertical)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(insight.markedSaved ? Color.clear : AppColors.lightBrown)
                .fill(insight.markedSaved ? AppColors.insightBoxBackground : Color.clear)
        }
    }
    
    private func saveInsight() {
        Task { @MainActor in
            insight.markedSaved.toggle()
            await dataController.save()
        }
    }
}


//
//#Preview {
//    InsightBoxView(emoji: Insight.example.insightEmoji, content: Insight.example.insightContent, markedSaved: false)
//}


