//
//  QuestionMultipleChoiceView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/5/24.
//

import SwiftUI
import WrappingHStack


struct MultiSelectOption {
    let text: String
    let isEditable: Bool
    let index: Int
}

// Extension to make MultiSelectOption identifiable for ForEach
extension MultiSelectOption: Identifiable {
    var id: Int { index }
}

struct QuestionMultiSelectView: View {
    @Binding var multiSelectAnswers: [String]
    @Binding var customItems: [String]
    @Binding var showProgressBar: Bool
    let question: String
    let items: [String]
    let answers: String
    let itemsEdited: Bool
    
    @FocusState private var isFocused: Bool
    
    let screenWidth = UIScreen.current.bounds.width
    
    init(multiSelectAnswers: Binding<[String]>, customItems: Binding<[String]> = .constant([]), showProgressBar: Binding<Bool> = .constant(true), question: String, items: [String], answers: String = "", itemsEdited: Bool = false) {
        self._multiSelectAnswers = multiSelectAnswers
        self._customItems = customItems
        self._showProgressBar = showProgressBar
        self.question = question
        self.items = items
        self.answers = answers
        self.itemsEdited = itemsEdited
    }
    
    // Process the options to determine which ones are editable
   private var processedOptions: [MultiSelectOption] {
       return Array(items.enumerated()).map { index, option in
           let isCustomOptionType = CustomOptionType.isCustomOption(option)
           let isLastItem = index == items.count - 1
           let isEditable = isCustomOptionType || (itemsEdited && isLastItem)
           
           return MultiSelectOption(
               text: option,
               isEditable: isEditable,
               index: index
           )
       }
   }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            
            Text(question)
                .multilineTextAlignment(.leading)
                .font(.system(size: 22, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 10)
            
            Text("Choose all that apply")
                .font(.system(size: 11))
                .fontWeight(.light)
                .foregroundStyle(AppColors.textPrimary.opacity(0.7))
                .textCase(.uppercase)
            
            WrappingHStack(processedOptions.filter { $0.isEditable == false }, id: \.self, alignment: .leading, spacing: .constant(14), lineSpacing: 14) { option in
                
                MultiSelectQuestionBubble(
                    multiSelectAnswers: $multiSelectAnswers,
                    customItems: $customItems,
                    showProgressBar: $showProgressBar,
                    selected: multiSelectAnswers.contains(option.text),
                    option: option.text,
                    items: items,
                    isEditable: option.isEditable,
                    isFocused: $isFocused)
                        .onTapGesture {
                            selectPill(option: option)
                        }
            }
            .padding(.bottom, 4)
            
            if let editableOption = processedOptions.filter({ $0.isEditable }).first {
                MultiSelectQuestionBubble(
                    multiSelectAnswers: $multiSelectAnswers,
                    customItems: $customItems,
                    showProgressBar: $showProgressBar,
                    selected: multiSelectAnswers.contains(editableOption.text),
                    option: editableOption.text,
                    items: items,
                    isEditable: editableOption.isEditable,
                    isFocused: $isFocused)
                        .onTapGesture {
                            isFocused = true
                            selectPill(option: editableOption)
                        }
            }

        }//VStack
        .onAppear {
            getSavedAnswers()
        }
        .onChange(of: question) {
            getSavedAnswers()
        }
    }
    
    private func getSavedAnswers() {
        if !answers.isEmpty {
            let answersArray = answers.components(separatedBy: ";")
            for answer in answersArray {
                multiSelectAnswers.append(answer)
            }
        }
    }
    private func selectPill(option: MultiSelectOption) {
        if let index = multiSelectAnswers.firstIndex(of: option.text) {
            // If the pill is already selected, remove it
            multiSelectAnswers.remove(at: index)
        } else {
            //check if option is editable
            if option.isEditable {
                
            } else {
                // Otherwise, add it to the selected pills
                multiSelectAnswers.append(option.text)
            }
        }
    }
    
   
    
    private func enableEditing() {
        // show keyboard
        if !isFocused {
            isFocused = true
        }
        
    }
}

struct MultiSelectQuestionBubble: View {
    @State private var editableOption: String = ""
    @State private var showPlusSign: Bool = false
    @Binding var multiSelectAnswers: [String]
    @Binding var customItems: [String]
    @Binding var showProgressBar: Bool
    
    let selected: Bool
    let option: String
    let items: [String]
    let isEditable: Bool
    
    @FocusState.Binding var isFocused: Bool
    
    var customTextIsSelected: Bool {
        if !multiSelectAnswers.isEmpty {
            return multiSelectAnswers.contains(editableOption) && !isFocused
        }
        return false
    }
    
    var body: some View {
        HStack (spacing: 0) {
            if isEditable {
                
                if showPlusSign {
                    Image(systemName: "plus")
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(AppColors.textPrimary)
                        .transition(.opacity)
                }
                
                
                TextField("", text: $editableOption.max(30))
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(selected || customTextIsSelected ? AppColors.textBlack : AppColors.textPrimary)
                    .fixedSize(horizontal: true, vertical: true)
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
                            //unselect the option if it's been selected
                            if let index = multiSelectAnswers.firstIndex(of: option) {
                                multiSelectAnswers.remove(at: index)
                            }
                            
                        } else {
                            multiSelectAnswers.append(editableOption)
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
                            if editableOption.isEmpty {
                                showPlusSign = false
                            }
                       
                        }
                    }
            } else {
                
                Text(option)
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(selected ? AppColors.textBlack : AppColors.textPrimary)
                    .fixedSize(horizontal: true, vertical: true)
                
            }
        }
        .padding(.leading, 18)
        .padding(.trailing, showPlusSign ? 15 : 18)
        .frame(height: 35)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 10)
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
