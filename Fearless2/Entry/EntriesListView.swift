//
//  EntriesListView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/14/24.
//
import CoreData
import SwiftUI

struct EntriesListView: View {
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    @Binding var selectedEntry: Entry?
    @Binding var showRecordingView: Bool
    let topicId: UUID?
    @FetchRequest var entries: FetchedResults<Entry>
    
    init(transcriptionViewModel: TranscriptionViewModel, selectedEntry: Binding<Entry?>, showRecordingView: Binding<Bool>, topicId: UUID?) {
        self.transcriptionViewModel = transcriptionViewModel
        self._selectedEntry = selectedEntry
        self._showRecordingView = showRecordingView
        self.topicId = topicId
        
        let request: NSFetchRequest<Entry> = Entry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        if let currentTopicId = topicId {
            request.predicate = NSPredicate(format: "topic.id == %@", currentTopicId as CVarArg)
        }
        self._entries = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        
        if entries.isEmpty {
            EntriesEmptyState(transcriptionViewModel: transcriptionViewModel, showRecordingView: $showRecordingView)
            
        } else {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack (spacing: 14){
                        ForEach(entries, id: \.entryId) { entry in
                            EntryBoxView(entry: entry)
                                .onTapGesture {
                                    selectedEntry = entry
                                }
                        }
                    }//HStack
                    .padding(.bottom, 90)
                }
                .scrollClipDisabled(true)
                
                StartRecordingButton(transcriptionViewModel: transcriptionViewModel, showRecordingView: $showRecordingView)
                
            }
        }
        
    }
}

//#Preview {
//    EntriesListView()
//}
