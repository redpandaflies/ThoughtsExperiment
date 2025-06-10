//
//  TopicOverviewBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 1/15/25.
//
//import CoreData
//import Mixpanel
//import SwiftUI
//
//struct TopicOverviewBox: View {
//    @EnvironmentObject var dataController: DataController
//    @ObservedObject var topicViewModel: TopicViewModel
//    
//    let topicId: UUID
//    let focusAreasCompleted: Int
//    @FetchRequest var reviews: FetchedResults<TopicReview>
//    
//    var focusAreasUntilReview: Int {
//        let remainder = focusAreasCompleted % 3
//        return remainder
//    }
//    
//    var overviewGenerated: Bool {
//        return reviews.first?.overviewGenerated ?? false
//    }
//    
//    init(topicViewModel: TopicViewModel,
//         topicId: UUID,
//         focusAreasCompleted: Int)
//    {
//        self.topicViewModel = topicViewModel
//        self.topicId = topicId
//        self.focusAreasCompleted = focusAreasCompleted
//        
//        let request: NSFetchRequest<TopicReview> = TopicReview.fetchRequest()
//        request.sortDescriptors = []
//        request.predicate = NSPredicate(format: "topic.id == %@", topicId as CVarArg)
//        
//        self._reviews = FetchRequest(fetchRequest: request)
//        
//    }
//    
//    var body: some View {
//        
//        VStack (spacing: 15) {
//            HStack {
//                Text("Overview")
//                    .multilineTextAlignment(.leading)
//                    .font(.system(size: 16, weight: .light))
//                    .fontWidth(.condensed)
//                    .foregroundStyle(AppColors.yellow1)
//                    .textCase(.uppercase)
//                
//                HStack(spacing: 3) {
//                    ForEach(0..<3, id: \.self) { item in
//                        Image(systemName: getIcon(item: item))
//                            .multilineTextAlignment(.leading)
//                            .font(.system(size: 12, weight: .light))
//                            .fontWidth(.condensed)
//                            .foregroundStyle(AppColors.yellow1)
//                    }
//                }
//                
//                Spacer()
//            }
//            
//            Group {
//                if let review = reviews.first {
//                    reviewOverview(overview: review.reviewOverview)
//                    
//                } else {
//                    TopicReviewEmptyState(text: "Complete three paths to unlock a useful topic summary.\n\nEvery three additional paths reveal an updated overview to help you track your progress and gain new clarity.")
//                        .blur(radius: (focusAreasUntilReview == 0 && focusAreasCompleted != 0 && !overviewGenerated) ? 5 : 0)
//                }
//            }
//            .overlay {
//                if (focusAreasUntilReview == 0 && focusAreasCompleted != 0) && !overviewGenerated {
//                    RectangleButtonPrimary(
//                        buttonText: buttonText(),
//                        action: {
//                            buttonAction()
//                        },
//                        disableMainButton: disableButton(),
//                        sizeSmall: true
//                    )
//                    .frame(width: 200)
//                }
//            }
//        }
//        .onAppear {
//            if focusAreasUntilReview > 0 && overviewGenerated {
//                if let review = reviews.first {
//                    Task {
//                        await dataController.updateOverviewStatus(review: review)
//                    }
//                }
//            }
//        }
//    }
//    
//    private func reviewOverview(overview: String) -> some View {
//        Text(overview)
//            .multilineTextAlignment(.leading)
//            .font(.system(size: 17, weight: .light))
//            .lineSpacing(1.4)
//            .foregroundStyle(AppColors.whiteDefault)
//            .blur(radius: (focusAreasUntilReview == 0 && focusAreasCompleted != 0) && !overviewGenerated ? 5 : 0)
//    }
//    
//    private func getIcon(item: Int) -> String {
//        if (item < focusAreasUntilReview) || (focusAreasUntilReview == 0 && focusAreasCompleted != 0 && !overviewGenerated){
//            return "checkmark.diamond.fill"
//        } else {
//            return "diamond"
//        }
//    }
//    
//    private func buttonText() -> String {
//        
//        switch topicViewModel.createTopicOverview {
//        case .ready:
//            return "Update topic overview"
//        case .loading:
//            return "Working on it..."
//        case .retry:
//            return "Retry"
//        }
//
//    }
//    
//    private func disableButton() -> Bool {
//        return topicViewModel.createTopicOverview == .loading
//    }
//    
//    private func buttonAction() {
//        
//        Task {
//            
//            //generate review
//            do {
//                try await topicViewModel.manageRun(selectedAssistant: .topicOverview, topicId: topicId)
//            } catch {
//                topicViewModel.createTopicOverview = .retry
//            }
//            
//            DispatchQueue.global(qos: .background).async {
//                Mixpanel.mainInstance().track(event: "Updated topic overview")
//            }
//        }
//    }
//    
//}
//
