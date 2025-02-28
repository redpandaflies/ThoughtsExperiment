//
//  QuestionsOnboarding.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/7/24.
//

import Foundation
import SwiftUI


struct QuestionsOnboarding: Identifiable, Codable {
    let id: Int
    var content: String
    var questionType: QuestionType
    var minLabel: String?
    var maxLabel: String?
    var options: [String]?
    var category: QuestionCategory
    
    init(id: Int, content: String, questionType: QuestionType, category: QuestionCategory, minLabel: String? = nil, maxLabel: String? = nil, options: [String]? = nil) {
        self.id = id
        self.content = content
        self.questionType = questionType
        self.category = category
        self.minLabel = minLabel
        self.maxLabel = maxLabel
        self.options = options
    }
}

enum QuestionCategory: String, Codable, CaseIterable {
    case generic
    case career
    case relationships
    case finance
    case wellness
    case passion
    case purpose
    
    static func getCategoryData(for option: String) -> Realm? {
        return Realm.realmsData.first { $0.lifeArea == option }
    }
}

extension QuestionsOnboarding {
    
    //initial question
    static var initialQuestion: [QuestionsOnboarding] {
        return [QuestionsOnboarding(
            id: 0,
            content: "It's late. You're trying to fall asleep, but your mind is wandering. What are you thinking about?",
            questionType: .singleSelect,
            category: .generic,
            options: Realm.realmsData
                .dropLast()
                .map { $0.lifeArea }
        )]
    }
    
    static func getQuestionFlow(for categoryChoice: String?) -> [QuestionsOnboarding] {
        
        
        // If no choice has been made yet, just return empty array
        guard let categoryChoice = categoryChoice else {
            return []
        }
        
        // Determine which follow-up questions to show based on the first choice
        var questions: [QuestionsOnboarding] = []
        
        switch categoryChoice {
            case Realm.realmsData[0].lifeArea:
                questions.append(contentsOf: careerQuestions)
            case Realm.realmsData[1].lifeArea:
                questions.append(contentsOf: relationshipsQuestions)
            case Realm.realmsData[2].lifeArea:
                questions.append(contentsOf: financeQuestions)
            case Realm.realmsData[3].lifeArea:
            questions.append(contentsOf: wellnessQuestions)
            case Realm.realmsData[4].lifeArea:
                questions.append(contentsOf: passionQuestions)
            case Realm.realmsData[5].lifeArea:
                questions.append(contentsOf: purposeQuestions)
            default:
                // Default to career questions if something unexpected happens
                questions.append(contentsOf: careerQuestions)
            }
        
        return questions
    }
    
    // Career-related questions
    private static var careerQuestions: [QuestionsOnboarding] {
        [
            .init(id: 1,
                 content: "How do you feel about your work?",
                 questionType: .singleSelect,
                 category: .career,
                 options: [
                    "Excited but a bit lost on what to do next",
                    "Frustrated by a lack of progress or growth",
                    "Anxious about my future or job stability",
                    "Overwhelmed by daily tasks and responsibilities",
                    "Disconnected, like my work doesn't match my interests or values"
                 ]),
            .init(id: 2,
                 content: "What's the biggest thing making work hard or stressful right now?",
                 questionType: .singleSelect,
                 category: .career,
                 options: [
                    "Not feeling motivated or excited about my work",
                    "Feeling stuck and not sure how to move forward",
                    "Struggling with confidence in my skills or decisions",
                    "Having too much on my plate and feeling burned out",
                    "Not feeling like my work matters or makes a difference"
                 ]),
            .init(id: 3,
                 content: "What would help you feel better about your work?",
                 questionType: .singleSelect,
                 category: .career,
                 options: [
                    "Feeling more confident in my abilities",
                    "Having a clear path forward",
                    "Finding more meaning or purpose in what I do",
                    "Having a better work-life balance",
                    "Getting recognition or support from others"
                 ]),
            .init(id: 4,
                 content: "What's one change that could make a big difference in how you feel about work?",
                 questionType: .singleSelect,
                 category: .career,
                 options: [
                    "Setting clearer goals and priorities",
                    "Building confidence in my skills and decisions",
                    "Finding more meaning or purpose in my tasks",
                    "Learning how to manage stress and workload better",
                    "Having a mentor or support to guide me"
                 ]),
            .init(id: 5,
                 content: "Imagine you feel really good about your career. What does that look like?",
                 questionType: .open,
                 category: .career
            )
        ]
    }
    
    // Relationship-related questions
    private static var relationshipsQuestions: [QuestionsOnboarding] {
        [
            .init(id: 1,
                 content: "What's getting in the way of feeling close to people?",
                 questionType: .singleSelect,
                 category: .relationships,
                 options: [
                    "Not having enough time to connect with others",
                    "Feeling awkward or unsure of how to start conversations",
                    "Struggling to trust people or open up",
                    "Feeling like I'm not understood or valued by others",
                    "Finding it hard to maintain or deepen friendships"
                 ]),
            .init(id: 2,
                 content: "How do your relationships make you feel?",
                 questionType: .singleSelect,
                 category: .relationships,
                 options: [
                    "Grateful but wishing for deeper connections",
                    "Lonely, even when I'm around people",
                    "Anxious about being judged or misunderstood",
                    "Overwhelmed by social interactions",
                    "Disconnected, like I'm not truly seen or heard"
                 ]),
            .init(id: 3,
                 content: "What would make your relationships feel better?",
                 questionType: .singleSelect,
                 category: .relationships,
                 options: [
                    "Building closer connections with friends and family",
                    "Meeting new people who share my interests",
                    "Feeling more comfortable and confident socially",
                    "Strengthening my relationship with my significant other",
                    "Resolving past conflicts or misunderstandings"
                 ]),
            .init(id: 4,
                 content: "What's one change that could make a big difference in your relationships?",
                 questionType: .singleSelect,
                 category: .relationships,
                 options: [
                    "Making more time for socializing and connecting",
                    "Practicing better communication and listening skills",
                    "Being more open and honest with how I feel",
                    "Surrounding myself with more supportive and positive people",
                    "Letting go of past hurts or grudges"
                 ]),
            .init(id: 5,
                 content: "Imagine your most important relationships are in a great place. What does that look like?",
                 questionType: .open,
                 category: .relationships
                 )
        ]
    }
    
    // Finance-related questions
    private static var financeQuestions: [QuestionsOnboarding] {
        [
            .init(id: 1,
                 content: "How do you feel about your money situation?",
                 questionType: .singleSelect,
                 category: .finance,
                 options: [
                    "Anxious or stressed about finances",
                    "Frustrated by my spending habits",
                    "Confused about how to manage my money better",
                    "Guilty about not saving more or spending wisely",
                    "Overwhelmed by financial decisions and responsibilities"
                 ]),
            .init(id: 2,
                 content: "What's the most stressful thing about your finances?",
                 questionType: .singleSelect,
                 category: .finance,
                 options: [
                    "Worrying about not having enough money for day-to-day expenses",
                    "Struggling to save or build good financial habits",
                    "Feeling uncertain about my financial future",
                    "Balancing saving with enjoying life now",
                    "Not knowing where my money goes each month"
                 ]),
            .init(id: 3,
                 content: "What would make you feel better about your money situation?",
                 questionType: .singleSelect,
                 category: .finance,
                 options: [
                    "Having a clear budget and sticking to it",
                    "Building an emergency fund or savings buffer",
                    "Feeling more in control of my spending",
                    "Making smarter decisions about investments or savings",
                    "Reducing stress about bills and expenses"
                 ]),
            .init(id: 4,
                 content: "What's one change that could make a big difference in how you feel about your finances?",
                 questionType: .singleSelect,
                 category: .finance,
                 options: [
                    "Setting up a budget that actually works for me",
                    "Creating a habit of saving regularly",
                    "Cutting back on unnecessary expenses",
                    "Learning more about managing money and investments",
                    "Paying off debt or building a financial safety net"
                 ]),
            .init(id: 5,
                 content: "Imagine you feel really good about your finances. What does that look like?",
                 questionType: .open,
                 category: .finance
            )
        ]
    }
    
    // Wellness-related questions
    private static var wellnessQuestions: [QuestionsOnboarding] {
        [
            .init(id: 1,
                 content: "How do you feel about your health?",
                 questionType: .singleSelect,
                 category: .wellness,
                 options: [
                    "Tired or low on energy most of the time",
                    "Overwhelmed by stress or mental load",
                    "Frustrated by unhealthy habits I can't break",
                    "Disconnected from my body or how I feel",
                    "Worried about my overall well-being"
                 ]),
            .init(id: 2,
                 content: "What's the hardest part about taking care of yourself?",
                 questionType: .singleSelect,
                 category: .wellness,
                 options: [
                    "Finding the energy and motivation to prioritize my health",
                    "Managing stress and anxiety",
                    "Building and sticking to healthy habits",
                    "Feeling balanced and not burned out",
                    "Getting enough good quality sleep"
                 ]),
            .init(id: 3,
                 content: "What would help you feel healthier?",
                 questionType: .singleSelect,
                 category: .wellness,
                 options: [
                    "Building a consistent sleep routine",
                    "Finding ways to manage stress better",
                    "Creating healthier habits around food and exercise",
                    "Making more time to rest and recharge",
                    "Becoming more in tune with what my body needs"
                 ]),
            .init(id: 4,
                 content: "What's one change that could make a big difference in how you feel about your health?",
                 questionType: .singleSelect,
                 category: .wellness,
                 options: [
                    "Setting small, achievable health goals",
                    "Finding a routine that makes self-care easier",
                    "Learning to manage stress in a healthier way",
                    "Prioritizing rest without feeling guilty",
                    "Making choices that support both my body and mind"
                 ]),
            .init(id: 5,
                 content: "Imagine you feel really healthy and balanced. What does that look like?",
                 questionType: .open,
                 category: .wellness
            )
        ]
    }
    
    // Passion-related questions
    private static var passionQuestions: [QuestionsOnboarding] {
        [
            .init(id: 1,
                 content: "How do you feel about spending time on things you love?",
                 questionType: .singleSelect,
                 category: .passion,
                 options: [
                    "Excited but not sure where to start",
                    "Frustrated by creative blocks or lack of progress",
                    "Anxious about whether my work is good enough",
                    "Disconnected from what usually brings me joy",
                    "Longing to explore new interests but feeling held back"
                 ]),
            .init(id: 2,
                 content: "What's keeping you from doing things you enjoy?",
                 questionType: .singleSelect,
                 category: .passion,
                 options: [
                    "Not having enough time for hobbies or creative projects",
                    "Struggling to find inspiration or new ideas",
                    "Doubting my creative abilities or feeling stuck",
                    "Feeling guilty for spending time on things that aren't \"productive\"",
                    "Not sure what I'm truly passionate about"
                 ]),
            .init(id: 3,
                 content: "What would help you do more of what you love?",
                 questionType: .singleSelect,
                 category: .passion,
                 options: [
                    "Having more time and space to focus on my passions",
                    "Feeling more confident in my creative work",
                    "Discovering new hobbies or interests",
                    "Learning how to move past creative blocks",
                    "Feeling less pressure to be perfect or productive"
                 ]),
            .init(id: 4,
                 content: "What's one change that could make a big difference in how you feel about your passions?",
                 questionType: .singleSelect,
                 category: .passion,
                 options: [
                    "Giving myself permission to explore without pressure",
                    "Setting aside dedicated time for creativity",
                    "Surrounding myself with inspiration and new ideas",
                    "Letting go of the need to be \"good\" at what I do",
                    "Finding ways to connect with others who share my interests"
                 ]),
            .init(id: 5,
                 content: "Imagine you feel really inspired and free to do what you love. What does that look like?",
                 questionType: .open,
                 category: .passion
                 )
        ]
    }
    
    // Purpose-related questions
    private static var purposeQuestions: [QuestionsOnboarding] {
        [
            .init(id: 1,
                 content: "How do you feel about who you are and where you're going?",
                 questionType: .singleSelect,
                 category: .purpose,
                 options: [
                    "Confused about my path or purpose",
                    "Anxious about making the wrong choices",
                    "Frustrated by a lack of direction",
                    "Disconnected from my true self",
                    "Curious but unsure where to start exploring"
                 ]),
            .init(id: 2,
                 content: "What's making it hard to figure out who you are or what you want?",
                 questionType: .singleSelect,
                 category: .purpose,
                 options: [
                    "Feeling unsure about what really matters to me",
                    "Struggling to connect with my own needs and desires",
                    "Doubting my choices or direction in life",
                    "Feeling pressured by what others expect of me",
                    "Not having the time or space to explore who I am"
                 ]),
            .init(id: 3,
                 content: "What would make you feel more sure about your purpose?",
                 questionType: .singleSelect,
                 category: .purpose,
                 options: [
                    "Gaining more clarity about my values and what matters to me",
                    "Trusting my own instincts and decisions",
                    "Letting go of what others think I should do",
                    "Exploring new interests and possibilities",
                    "Feeling more grounded and at peace with myself"
                 ]),
            .init(id: 4,
                 content: "What's one change that could make a big difference in how you feel about your purpose?",
                 questionType: .singleSelect,
                 category: .purpose,
                 options: [
                    "Taking time to explore my interests without pressure",
                    "Learning to listen to my own voice instead of others' opinions",
                    "Setting small goals to understand myself better",
                    "Creating space to reflect on what brings me joy and meaning",
                    "Trying new experiences to see what resonates with me"
                 ]),
            .init(id: 5,
                 content: "Imagine you feel really sure about who you are and your purpose. What does that look like?",
                 questionType: .open,
                 category: .purpose
                 )
        ]
    }
}
