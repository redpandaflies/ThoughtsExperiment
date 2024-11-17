//
//  EntryBoxView.swift
//  Tinyverse
//
//  Created by Yue Deng-Wu on 10/22/24.
//

import SwiftUI

struct EntryBoxView: View {
    @ObservedObject var entry: Entry
    
    var body: some View {
        HStack (spacing: 2) {
            VStack (alignment: .leading, spacing: 15) {
                
                Text(entry.entryTitle)
                    .font(.system(size: 17))
                    .foregroundStyle(AppColors.whiteDefault)
                
                
                
                Text(DateFormatter.displayString2(from: DateFormatter.incomingFormat.date(from: entry.entryCreatedAt) ?? Date()))
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
//    EntryBoxView()
//}
