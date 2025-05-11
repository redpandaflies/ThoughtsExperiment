//
//  QuestionMultiSelectView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/5/24.
//

import SwiftUI


struct MultiSelectOption: Hashable {
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
    @Binding var customItems: [String] // custom items are saved into CoreData or kept in memory (if question hasn't yet been saved in CoreData)
    @Binding var showProgressBar: Bool
    @Binding var itemsEditedInMemory: Bool //for questions that aren't saved yet to coredata
    let question: String
    let items: [String]
    let answers: String //existing answers for question
    let itemsEdited: Bool
    
    @FocusState private var isFocused: Bool
    
    let screenWidth = UIScreen.current.bounds.width
    
    init(multiSelectAnswers: Binding<[String]>, customItems: Binding<[String]> = .constant([]), showProgressBar: Binding<Bool> = .constant(true), itemsEditedInMemory: Binding<Bool> = .constant(false), question: String, items: [String], answers: String = "", itemsEdited: Bool = false) {
        self._multiSelectAnswers = multiSelectAnswers
        self._customItems = customItems
        self._showProgressBar = showProgressBar
        self._itemsEditedInMemory = itemsEditedInMemory
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
           let isEditable = isCustomOptionType || (itemsEdited && isLastItem) || (itemsEditedInMemory && isLastItem)
           
           return MultiSelectOption(
               text: option,
               isEditable: isEditable,
               index: index
           )
       }
   }
    
    var body: some View {
        VStack (alignment: .leading, spacing: isFocused ? 5 : 10) {
            
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
            
            ForEach(processedOptions.filter { $0.isEditable == false }, id: \.self) { option in
                
                MultiSelectQuestionBubble(
                    multiSelectAnswers: $multiSelectAnswers,
                    customItems: $customItems,
                    showProgressBar: $showProgressBar,
                    itemsEditedInMemory: $itemsEditedInMemory,
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
                    itemsEditedInMemory: $itemsEditedInMemory,
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
    @Binding var itemsEditedInMemory: Bool
    
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
        HStack (spacing: 10) {
            
            Image(systemName: showPlusSign ? "plus" : ( selected || customTextIsSelected ? "checkmark.square" : "square"))
                .multilineTextAlignment(.leading)
                .font(.system(size: 19, weight: .light))
                .fontWidth(.condensed)
                .foregroundStyle(selected || customTextIsSelected ? AppColors.textBlack : AppColors.textPrimary)
                .transition(.opacity)
                
            if isEditable {
                
                TextField("", text: $editableOption.max(50))
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(selected || customTextIsSelected ? AppColors.textBlack : AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
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
                            if !itemsEditedInMemory {
                                itemsEditedInMemory = true
                            }
                        }
                    }
                    .onAppear {
                        setUpTextField()
                        
                    }
                    .onChange(of: items) {
                        // when there are two multi select questions in a row, ensures that custom answer of a question isn't displayed for the question after/before it
                        setUpTextField()
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
                    .fixedSize(horizontal: false, vertical: true)
                
            }
            
       
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, isFocused ? 10 : 15)
        .padding(.horizontal, 15)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(selected || customTextIsSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.2), lineWidth: 0.5)
                .fill(selected || customTextIsSelected ? Color.white.opacity(0.8) : Color.white.opacity(0.05))
        }
        .animation(.smooth(duration: 0.2), value: isFocused)
    }
    
    private func setUpTextField() {
        if itemsEditedInMemory {
            editableOption = customItems.last ?? ""
            showPlusSign = true
        } else if  CustomOptionType.isCustomOption(option) {
            editableOption = ""
            showPlusSign = true
        } else {
            editableOption = option
        }
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
