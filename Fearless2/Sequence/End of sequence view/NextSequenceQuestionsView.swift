//
//  NextSequenceQuestionsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/16/25.
//

import SwiftUI
   

struct NextSequenceQuestionsView: View {
    @EnvironmentObject var dataController: DataController

    @Binding var selectedQuestion: Int
    @Binding var answersOpen: [String]
    @Binding var answersSingleSelect: [String]
    @Binding var answersMultiSelect: [[String]]
    @Binding var multiSelectCustomItems: [[String]]
    @Binding var multiSelectOptionsEdited: [Bool]
    
    let questions: [NewQuestion]
    let focusField: FocusState<DefaultFocusField?>.Binding
    let sequenceObjectives: String
    let keepExploringAction: () -> Void
    let resolveTopicAction: () -> Void
    
    var currentQuestion: NewQuestion {
        return questions[selectedQuestion]
    }

    var body: some View {
        
        VStack {
            switch currentQuestion.questionType {
                case .open:
                    QuestionOpenView2(
                        topicText: $answersOpen[selectedQuestion],
                        focusField: focusField,
                        focusValue: .question(selectedQuestion),
                        question: currentQuestion.content,
                        placeholderText: "For best results, be very specific."
                    )
                case .multiSelect:
                    QuestionMultiSelectView(
                        multiSelectAnswers: $answersMultiSelect[selectedQuestion],
                        customItems: $multiSelectCustomItems[selectedQuestion],
                        question: currentQuestion.content,
                        items: getOptionsForMultiSelect()
                    )
                    
                default:
                    QuestionWhereToNext(
                        question: currentQuestion.content,
                        leftAction: {
                            keepExploringAction()
                        },
                        rightAction: {
                            resolveTopicAction()
                        },
                        leftTitle: "Keep\nexploring",
                        leftSubtitle: "We'll come up with a new plan",
                        rightTitle: "Resolve\ntopic",
                        rightSubtitle: "You can start a new one"
                    )
            }
        }
    
    }
    
    private func getOptionsForMultiSelect() -> [String] {
        if selectedQuestion == 0 {
            var options = sequenceObjectives.components(separatedBy: ";")
            // add “Other” at the end
           options.append(CustomOptionType.other.rawValue)
           return options
        }
        
        return currentQuestion.options.map { $0.text }
    }
}
