////
////  NextSequenceView.swift
////  Fearless2
////
////  Created by Yue Deng-Wu on 4/7/25.
////
//
//import SwiftUI
//
//struct NextSequenceView: View {
//    @EnvironmentObject var dataController: DataController
//    @EnvironmentObject var openAISwiftService: OpenAISwiftService
//    @State private var selectedTab: Int = 0
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                
//                
//                VStack (alignment: (selectedTab == 1) ? .leading : .center, spacing: 5) {
//                    switch selectedTab {
//                        case 0:
//                            RecapCelebrationView(title: "[Sequence]", text: "For completing", points: "+10")
//                                .padding(.horizontal)
//                                .padding(.bottom, 100)
//                            
//                        case 1:
//                            recapView()
//                               
//                        case 2:
//                            //Question view
//                            
//                        
//                        
//                        default:
//                            RecapCelebrationView(title: "[Goal]", text: "For resolving", points: "+20")
//                                .padding(.horizontal)
//                                .padding(.bottom, 100)
//                    }
//                }
//                
//                VStack {
//                    
//                    Spacer()
//                    
//                    RectangleButtonPrimary(
//                        buttonText: getButtonText(),
//                        action: {
//                            buttonAction()
//                        },
//                        disableMainButton: disableButton(),
//                        buttonColor: .white
//                    )
//                    .padding(.bottom, 10)
//                    .padding(.horizontal)
//                }
//                
//            }//VStack
//            .background {
//                if let category = topic.category {
//                    BackgroundPrimary(backgroundColor: Realm.getBackgroundColor(forName: category.categoryName))
//                } else {
//                    BackgroundPrimary(backgroundColor: AppColors.backgroundCareer)
//                }
//            }
//            .onAppear {
//                getTopicReview()
//            }
//            .toolbar {
//               
//                ToolbarItem(placement: .principal) {
//                    ToolbarTitleItem2(emoji: topic.category?.categoryEmoji ?? "", title: "Quest complete")
//                }
//                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    XmarkToolbarItem()
//                }
//                
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbarBackgroundVisibility(.hidden)
//            
//        }//NavigationStack
//    }
//    
//    private func getButtonText() -> String {
//        switch selectedTab {
//            case 0:
//                return "Next: [sequence] reflection"
//            case 1:
//               return getButtonTextRecapView()
//            case 2:
//                return "Next"
//            default:
//                return "Done"
//        }
//    }
//    
//    private func getButtonTextRecapView() -> String {
//        switch topicViewModel.createTopicOverview {
//            case .ready:
//                return "Next: restore lost fragment"
//            case .loading:
//               return "Loading . . ."
//            case .retry:
//                return "Retry"
//        }
//    }
//    
//}
//
//#Preview {
//    NextSequenceView()
//}
