//
//  SectionReflectionQuestions.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/29/24.
//
import CoreData
import SwiftUI

struct SectionReflectionQuestions: View {
    
    let topicId: UUID
    let selectedCategory: TopicCategoryItem
    
    @FetchRequest var questions: FetchedResults<Question>
   
    init(topicId: UUID, selectedCategory: TopicCategoryItem) {
        
        self.topicId = topicId
        self.selectedCategory = selectedCategory
        
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        request.sortDescriptors = []
        let questionPredicate = NSPredicate(format: "starterQuestion == %d", true)
        let typePredicate = NSPredicate(format: "type == %@", QuestionType.scale.rawValue)
        let topicPredicate = NSPredicate(format: "topic.id == %@", topicId as CVarArg)
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [questionPredicate, typePredicate, topicPredicate])
        request.predicate = compoundPredicate
        self._questions = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            
            Text("Take a moment to reflect on these questions. Update your answers if anything has changed.")
                .multilineTextAlignment(.leading)
                .font(.system(size: 19))
                .fontWeight(.semibold)
                .foregroundStyle(Color.white)
                .padding(.vertical, 10)
            
            ForEach(questions, id: \.questionId) { question in
                
                Text(question.questionContent)
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.white)
                    
                
                SliderView(selectedValue:  Binding(
                    get: { question.answerScale },
                    set: { newValue in
                        question.answerScale = newValue
                    }), selectedCategory: selectedCategory, minLabel: question.questionMinLabel, maxLabel: question.questionMaxLabel)
                   
            }
            
            
            
        }
    }
}

//#Preview {
//    SectionReflectionQuestions()
//}
