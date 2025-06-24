//
//  RecapReflectionView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/4/25.
//
import Combine
import SwiftUI

struct RecapReflectionView<ViewModel: TopicRecapObservable>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var animationValue: Bool = false
    @State private var startedAnimation: Bool = false
    
    // LottieView
    @State private var animationSpeed: CGFloat = 1.0
    @State private var play: Bool = true
    
    // text animation
    @State private var animator: TextAnimator?
    @State private var animatedText: String = ""
    @State private var animationCompletedText: Bool = false
    @State private var startedTextAnimation: Bool = false
    
    @Binding var recapSelectedTab: Int
    
    let feedback: String
    let retryAction: () -> Void
    let focusArea: FocusArea?
    let topic: TopicRepresentable?
    let loadingTexts: [String]
    
    init(
        viewModel: ViewModel,
        recapSelectedTab: Binding<Int>,
        feedback: String,
        retryAction: @escaping () -> Void,
        focusArea: FocusArea? = nil,
        topic: TopicRepresentable? = nil,
        loadingText: [String]
    ) {
        self.viewModel = viewModel
        self._recapSelectedTab = recapSelectedTab
        self.feedback = feedback
        self.retryAction = retryAction
        self.focusArea = focusArea
        self.topic = topic
        self.loadingTexts = loadingText
    }
    
    var body: some View {
        
        VStack (alignment: .leading) {
            switch recapSelectedTab {
                case 0:
                    LoadingViewChecklist(
                        texts: loadingTexts,
                        onComplete: {
                            viewModel.markCompleteLoadingAnimationSummary()
                        }
                    )
                
                case 1:
                    getReflection()
                        .transition(.opacity)
                
                default:
                    FocusAreaRetryView(action: {
                        retryAction()
                    })
            }
            
        }//VStack
        .onAppear {
//            if animator == nil {
//                animator = TextAnimator(text: feedback, animatedText: $animatedText, speed: 0.04)
//            }
            
           
                manageTopicRecapView()
        
            
        }
        .onReceive(
          Publishers.CombineLatest(
            viewModel.createTopicRecapPublisher,
            viewModel.completedLoadingAnimationSummaryPublisher
          )
          .filter { summary, loaded in
            summary != .loading && loaded
          }
          .receive(on: DispatchQueue.main)
          .eraseToAnyPublisher()
        ) { _ in
            manageTopicRecapView()
        }
    }
    
    private func getReflection() -> some View {
        VStack (alignment: .leading, spacing: 10) {
            
            LottieView(
                loopMode: .playOnce,
                animationSpeed: $animationSpeed,
                play: $play
            )
            .aspectRatio(contentMode: .fit)
            .frame(width: 90, height: 90)
            .padding(.bottom, 30)
             
            
            Text("Here's what I heard:")
                .multilineTextAlignment(.leading)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 5)
                .padding(.horizontal)

            Text(animatedText)
                .multilineTextAlignment(.leading)
                .font(.system(size: 19, design: .serif))
                .foregroundStyle(AppColors.textPrimary.opacity(0.9).opacity(0.9))
                .lineSpacing(2.0)
                .padding(.horizontal)
            
        }//VStack
        .frame(maxWidth:.infinity, alignment: .topLeading)
    }
    
    private func manageTopicRecapView() {
        switch  viewModel.createTopicRecap  {
            case .ready:
            if !feedback.isEmpty {
                if recapSelectedTab != 1 {
                    recapSelectedTab = 1
                }
            } else {
                recapSelectedTab = 2
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                startReflectionAnimation()
            }

            case .loading:
                recapSelectedTab = 0
            case .retry:
                recapSelectedTab = 2
        }
    }
    
    private func startReflectionAnimation() {
        
        guard !startedTextAnimation else { return }
        
        startedTextAnimation = true
     
        print ("New goal feedback: \(feedback)")
        animator = TextAnimator (
            text: feedback,
            animatedText: $animatedText,
            completedAnimation: $animationCompletedText,
            speed: 0.03
        )
        
        animator?.animate()
        
    }

}

