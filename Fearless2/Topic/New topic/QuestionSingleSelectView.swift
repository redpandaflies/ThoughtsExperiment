//
//  QuestionSingleSelectView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/5/24.
//

import SwiftUI
import WrappingHStack

enum CustomOptionType: String, CaseIterable {
    case somethingElse = "Something else"
    case other = "Other"
    
    static func isCustomOption(_ option: String) -> Bool {
        return self.allCases.contains { $0.rawValue == option }
    }
}

struct SingleSelectOption {
    let text: String
    let isEditable: Bool
    let index: Int
}

// Extension to make SingleSelectOption identifiable for ForEach
extension SingleSelectOption: Identifiable {
    var id: Int { index }
}

struct QuestionSingleSelectView: View {
    @Binding var singleSelectAnswer: String
    @Binding var customItems: [String]
    @Binding var showProgressBar: Bool
    let question: String
    let items: [String]
    let answer: String //saved answer for question, used when user navigates to previous question and come back
    let itemsEdited: Bool
    
    @FocusState private var isFocused: Bool

    init(singleSelectAnswer: Binding<String>, customItems: Binding<[String]> = .constant([]), showProgressBar: Binding<Bool> = .constant(true), question: String, items: [String], answer: String = "", itemsEdited: Bool = false) {
        self._singleSelectAnswer = singleSelectAnswer
        self._customItems = customItems
        self._showProgressBar = showProgressBar
        self.question = question
        self.items = items
        self.answer = answer
        self.itemsEdited = itemsEdited
    }
    
    // Process the options once to determine which ones are editable
       private var processedOptions: [SingleSelectOption] {
           return Array(items.enumerated()).map { index, option in
               let isCustomOptionType = CustomOptionType.isCustomOption(option)
               let isLastItem = index == items.count - 1
               let isEditable = isCustomOptionType || (itemsEdited && isLastItem)
               
               return SingleSelectOption(
                   text: option,
                   isEditable: isEditable,
                   index: index
               )
           }
       }
        
    var body: some View {
        VStack (alignment: .leading, spacing: 15) {
            
            Text(question)
                .multilineTextAlignment(.leading)
                .font(.system(size: 22, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 15)
            
            
            VStack (spacing: 15) {
                ForEach(processedOptions, id: \.index) { option in
                    SingleSelectQuestionBubble(
                        singleSelectAnswer: $singleSelectAnswer,
                        customItems: $customItems,
                        showProgressBar: $showProgressBar,
                        selected: singleSelectAnswer == option.text,
                        option: option.text,
                        items: items,
                        isEditable: option.isEditable,
                        isFocused: $isFocused
                    )
                    .onTapGesture {
                        if option.isEditable {
                            isFocused = true
                        }
                        selectPill(option: option)
                        
                    }
                }
            }
            
        }//VStack
        .onAppear {
            if !answer.isEmpty {
               // show the answer user already selected in UI
                singleSelectAnswer = answer
            }
        }
        .onChange(of: question) {
            if !answer.isEmpty {
               // show the answer user already selected in UI, this is needed if there are two single select questions in a row
                singleSelectAnswer = answer
            }
        }
    }
    
    private func selectPill(option: SingleSelectOption) {
            if singleSelectAnswer == option.text {
                // If the pill is already selected, reset selectedOption
                singleSelectAnswer = ""
            } else {
                if !option.isEditable {
                    singleSelectAnswer = option.text
                }
            }
        }
}

struct SingleSelectQuestionBubble: View {
    @State private var editableOption: String = ""
    @State private var showPlusSign: Bool = false
    @Binding var singleSelectAnswer: String
    @Binding var customItems: [String]
    @Binding var showProgressBar: Bool
   
    var selected: Bool
    let option: String
    let items: [String]
    let isEditable: Bool
    
    @FocusState.Binding var isFocused: Bool
    
    var customTextIsSelected: Bool {
        if !singleSelectAnswer.isEmpty {
            return singleSelectAnswer == editableOption
        }
        return false
    }
    
    var body: some View {
        
        HStack (spacing: 5) {
            
            if isEditable {
                
                if showPlusSign {
                    Image(systemName: "plus")
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(AppColors.textPrimary)
                        .transition(.opacity)
                }
                
                TextField("", text: $editableOption.max(40))
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(selected || customTextIsSelected ? AppColors.textBlack : AppColors.textPrimary)
                    .focused($isFocused)
                    .keyboardType(.alphabet)
                    .submitLabel(.done)
                    .onSubmit {
                        isFocused = false
                        withAnimation(.snappy(duration: 0.2)) {
                            showProgressBar = true
                        }
                        if editableOption.isEmpty {
                            editableOption = ""
                            withAnimation(.snappy(duration: 0.2)) {
                                showPlusSign = true
                            }
                            if singleSelectAnswer == option {
                                singleSelectAnswer = ""
                            }
                            
                        } else {
                            singleSelectAnswer = editableOption
                            createCustomItems()
                        }
                    }
                    .onAppear {
                        
                        if CustomOptionType.isCustomOption(option) {
                            editableOption = ""
                            showPlusSign = true
                        } else {
                            editableOption = option
                        }
                    }
                    .onChange(of: isFocused) {
                        if isFocused {
                            withAnimation(.snappy(duration: 0.2)) {
                                showProgressBar = false
                            }
                            if editableOption.isEmpty  {
                                showPlusSign = false
                            }
                            
                            singleSelectAnswer = ""
                       
                        }
                    }
                    
                
            } else {
                
                Text(option)
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(selected ? AppColors.textBlack : AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                
            }
            
            Spacer()
        }//HStack
        .padding(.vertical, isFocused ? 15 : 20)
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 15)
                .stroke(selected || customTextIsSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.2), lineWidth: 0.5)
                .fill(selected || customTextIsSelected ? Color.white.opacity(0.8) : Color.white.opacity(0.05))
        }
        .animation(.smooth(duration: 0.2), value: isFocused)
    }
    
    private func createCustomItems() {
        var newOptions: [String] = items
        //remove the last item, which should be either something else/other
        newOptions.removeLast()
        newOptions.append(editableOption)
        //set custom items equal to new options. custom items will be saved to coredata
        customItems = newOptions
        
    }
}

//#Preview {
//    QuestionMultiSelectView()
//}
