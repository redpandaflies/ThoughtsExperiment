//
//  EntryDetailView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/14/24.
//

import SwiftUI

enum Field: Hashable {
    case title
    case summary
    case transcript
}

struct EntryDetailView: View {
  
    @State private var isEditingEnabled: Bool = false
    @State private var selectedTab: EntryPickerItem = .summary
    
    @State private var editableTitle: String = ""
    @State private var editableSummary: String = ""
    @State private var editableTranscript: String = ""
    
    @FocusState private var focusedField: Field?
    
    let entry: Entry
    
    var body: some View {
        NavigationStack {
            ScrollView (showsIndicators: false) {
                
                VStack (alignment: .leading, spacing: 10) {
                    
                    Text(DateFormatter.displayString(from: DateFormatter.incomingFormat.date(from: entry.entryCreatedAt) ?? Date()))
                        .font(.system(size: 12))
                        .fontWeight(.light)
                        .foregroundStyle(AppColors.lightBrown)
                        .textCase(.uppercase)
                        .opacity(0.5)
                    
                    VStack {
                        TextField("", text: $editableTitle.max(60), axis: .vertical)
                            .multilineTextAlignment(.leading)
                            .disabled(!isEditingEnabled)
                            .font(.system(size: 25))
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColors.whiteDefault)
                            .focused($focusedField, equals: .title)
                            .keyboardType(.alphabet)
                    }
                    .contentShape(Rectangle())
                    .padding(.bottom)
                    .onAppear {
                        editableTitle = entry.entryTitle
                    }
                    
                    //Insights
                    entrySubtitle("Insights")
                        .padding(.bottom, 5)
                    
                    ForEach(entry.entryInsights, id: \.insightId) { insight in
                        EntryInsightBoxView(insight: insight)
                    }
                    .padding(.bottom)
                    
                    //Entry
                    HStack {
                        entrySubtitle("Summary", isSelected: selectedTab == .summary)
                            .onTapGesture {
                                selectedTab = .summary
                            }
                        
                        entrySubtitle("/")
                        
                        entrySubtitle("Transcript", isSelected: selectedTab == .transcript)
                            .onTapGesture {
                                selectedTab = .transcript
                            }
                    }
                    .padding(.bottom, 5)
                    
                    switch selectedTab {
                        case .summary:
                            entrySummaryTranscript(text: $editableSummary, entryText: entry.entrySummary, focusField: .summary)
                        case .transcript:
                            entrySummaryTranscript(text: $editableTranscript, entryText: entry.entryTranscript, focusField: .transcript)
                    }
                    
                    
                }//VStack
                .padding()
            }//ScrollView
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EntryToolBarItem()
                }
            }
            .toolbarBackground(Color.black)
            
        }//NavigationStack
    }
    
    private func entrySubtitle(_ title: String, isSelected: Bool? = nil) -> some View {
        Group {
            Text(title)
                .font(.system(size: 17))
                .foregroundStyle(AppColors.entrySubtitle)
                .textCase(.uppercase)
                .opacity((isSelected ?? false) ? 1 : 0.5)
        }
        .contentShape(Rectangle())
    }
    
    private func entrySummaryTranscript(text: Binding<String>, entryText: String, focusField: Field) -> some View {
        VStack {
            TextField("", text: text, axis: .vertical)
                .multilineTextAlignment(.leading)
                .font(.system(size: 15))
                .foregroundStyle(AppColors.whiteDefault)
                .lineSpacing(3)
                .disabled(!isEditingEnabled)
                .focused($focusedField, equals: focusField)
                .keyboardType(.alphabet)
                
        }
        .contentShape(Rectangle())
        .onTapGesture {
//            focusedField = focusField
        }
        .onAppear {
            text.wrappedValue = entryText
        }
    }
}

enum EntryPickerItem: String, CaseIterable {
    case summary
    case transcript
}




//#Preview {
//    EntryDetailView()
//}
