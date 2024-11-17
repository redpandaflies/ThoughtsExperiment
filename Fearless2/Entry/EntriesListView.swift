//
//  EntriesListView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/14/24.
//
import CoreData
import SwiftUI

struct EntriesListView: View {
    @Binding var selectedEntry: Entry?
    
    let topicId: UUID?
    @FetchRequest var entries: FetchedResults<Entry>
    
    init(selectedEntry: Binding<Entry?>, topicId: UUID?) {
        _selectedEntry = selectedEntry
        self.topicId = topicId
        
        let request: NSFetchRequest<Entry> = Entry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        if let currentTopicId = topicId {
            request.predicate = NSPredicate(format: "topic.id == %@", currentTopicId as CVarArg)
        }
        self._entries = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        VStack (spacing: 10) {
            ForEach(entries, id: \.entryId) { entry in
                EntryBoxView(entry: entry)
                    .onTapGesture {
                        selectedEntry = entry
                    }
            }
            
        }
        
    }
}

//#Preview {
//    EntriesListView()
//}
