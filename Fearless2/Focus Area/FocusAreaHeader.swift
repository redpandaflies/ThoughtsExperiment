//
//  FocusAreaHeader.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/8/24.
//

import SwiftUI

struct FocusAreaHeader: View {
    @EnvironmentObject var dataController: DataController
    @Binding var showFocusAreasView: Bool
    let topicId: UUID?
    
    var body: some View {
       
        VStack {
            Spacer()
            
            HStack (alignment: .bottom) {
                Spacer()
                
                
                Menu {
                    Button (role: .destructive) {
                        Task {
                            if let currentTopicId = topicId {
                                await dataController.deleteTopic(id: currentTopicId)
                            }
                        }
                        
                    } label: {
                        
                        Label("Delete", systemImage: "trash")
                        
                    }
                    
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(Color.white)
                        .opacity(0.6)
                }
                
                Button {
                    showFocusAreasView = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(Color.white)
                        .opacity(0.6)
                }
                
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .frame(height: 90)
        .background {
            Rectangle()
                .fill(Color.black)
                .ignoresSafeArea()
        }
        
    }
}

//#Preview {
//    FocusAreaHeader()
//}
