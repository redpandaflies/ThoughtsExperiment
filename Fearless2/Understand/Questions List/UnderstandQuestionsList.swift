//
//  UnderstandQuestionsList.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/21/24.
//
import CoreData
import SwiftUI

struct UnderstandQuestionsList: View {
    
    @State private var selectedQuestion: Understand? = nil
    
    @FetchRequest var questions: FetchedResults<Understand>
    
    init() {
      
        let request: NSFetchRequest<Understand> = Understand.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        self._questions = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        
        NavigationStack {
            ScrollView (showsIndicators: false) {
                VStack (spacing: 10) {
                    ForEach(questions, id: \.understandId) { understand in
                        UnderstandQuestionBoxView(understand: understand)
                            .onTapGesture {
                                selectedQuestion = understand
                            }
                    }
                    
                }//VStack
                .padding()
            }
            .scrollClipDisabled(true)
            .safeAreaInset(edge: .bottom, content: {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 15)
            })
            .sheet(item: $selectedQuestion, onDismiss: {
                selectedQuestion = nil
            }){ understand in
                UnderstandQuestionDetailView(understand: understand)
                    .presentationCornerRadius(20)
                    .presentationBackground(Color.black)
            }
            
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ToolbarTitleItem(title: "Past Questions")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    XmarkToolbarItem()
                }
                
            }
            .toolbarBackground(Color.black)
        }//NavigationStack
    }
}

struct UnderstandQuestionBoxView: View {
    let understand: Understand
    
    var body: some View {
        HStack (spacing: 2) {
            VStack (alignment: .leading, spacing: 15) {
                
                Text(understand.understandQuestion)
                    .font(.system(size: 17))
                    .foregroundStyle(AppColors.whiteDefault)
                
                
                
                Text(DateFormatter.displayString2(from: DateFormatter.incomingFormat.date(from: understand.understandCreatedAt) ?? Date()))
                    .font(.system(size: 11))
                    .fontWeight(.light)
                    .foregroundStyle(AppColors.whiteDefault)
                    .opacity(0.5)
                
            }//VStack
            Spacer()
        }//HStack
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(AppColors.darkBrown)
        }
    }
}

//#Preview {
//    UnderstandQuestionsList()
//}
