////
////  TopicImageView.swift
////  TrueBlob
////
////  Created by Yue Deng-Wu on 1/2/24.
////
//import Lottie
//import Pow
//import SwiftUI
//
//struct TopicImageView: View {
//    @StateObject var topicImageViewModel: TopicImageViewModel
//    @ObservedObject var topicViewModel: TopicViewModel
//    
//    @ObservedObject var topic: Topic
//    @State private var play: Bool = true
//    @State private var animationSpeed: CGFloat = 1.5
//    
//    var placeholderImageName: String?
//    
//    init(topicViewModel: TopicViewModel, topic: Topic) {
//        self.topicViewModel = topicViewModel
//        self.topic = topic
//       
//        _topicImageViewModel = StateObject(wrappedValue: TopicImageViewModel(topicViewModel: topicViewModel, topic: topic))
//    }
//    
//    var body: some View {
//        ZStack {
//            
//            switch topicImageViewModel.imageStatus {
//                case .loading:
//                    loadingView()
//                case .imageReady:
//                    if let image = topicImageViewModel.topicImage {
//                        topicImage(image: image)
//                    }
//                       
//                case .imageNotFound:
//                    topicImage(image: UIImage(imageLiteralResourceName: "placeholder"))
//            }
//        }
//        .clipShape(RoundedRectangle(cornerRadius: 20))
//        .animation(.easeInOut(duration: 1), value: topicImageViewModel.imageTransition)
//        .onChange(of: topicViewModel.showPlaceholder) {
//            if topicViewModel.showPlaceholder {
//                topicImageViewModel.imageStatus = .imageNotFound
//            }
//        }
//        .onChange(of: topic.topicMainImage) {
//            Task {
//                await topicImageViewModel.loadSavedImage(topic: topic)
//            }
//        }
//    }
//    
//    private func loadingView() -> some View {
//      
//        LottieView(name: "loadingAnimation", animationSpeed: $animationSpeed, play: $play)
//            .aspectRatio(1, contentMode: .fit)
// 
//    }
//    
//    private func topicImage(image: UIImage) -> some View {
//            Image(uiImage: image)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .transition(.movingParts.snapshot)
//        
//    }
//}
//
////struct EntryImageView_Previews: PreviewProvider {
////   
////    static var previews: some View {
////        
////        EntryImageView(entry: Entry.example)
////            .previewLayout(.sizeThatFits)
////    }
////}
