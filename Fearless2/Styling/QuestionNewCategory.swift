//
//  QuestionNewCategory.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/7/24.
//

import Foundation
import SwiftUI


struct QuestionNewCategory: Identifiable, Codable, QuestionProtocol {
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
    case mixed
    
    static func getCategoryData(for option: String) -> Realm? {
        return Realm.realmsData.first { $0.name == option }
    }
}

extension QuestionNewCategory {
    
    //get questions new category
    static func initialQuestionsNewCategory() -> [QuestionNewCategory] {
        return [
            QuestionNewCategory(
                id: 0,
                content: "What's on your mind?",
                questionType: .singleSelect,
                category: .generic,
                options: GoalTypeItem.allCases.dropLast().map { $0.getNameLong() }
            )
        ]
    }
    
    
    static func remainingQuestionsNewCategory(userAnswer: String) -> [QuestionNewCategory] {
        
        let secondQuestionContent = GoalTypeItem.question(forLongName: userAnswer)
        
        return [
            QuestionNewCategory(
                id: 1,
                content:  secondQuestionContent,
                questionType: .open,
                category: .generic
            ),
            QuestionNewCategory(
                id: 2,
                content: "How long has this been on your mind?",
                questionType: .singleSelect,
                category: .generic,
                options: [
                    "It's a recent thing",
                    "For a few weeks",
                    "For several months",
                    "For a year or more"
                ]
            ),
            QuestionNewCategory(
                id: 3,
                content: "Anything else that might be relevant?",
                questionType: .open,
                category: .generic
            ),
            QuestionNewCategory(
                id: 4,
                content: "What would be helpful?",
                questionType: .multiSelect,
                category: .generic,
                options: [
                    "Offer a different perspective",
                    "Give candid feedback",
                    "Suggest next steps",
                    "Other"
                ]
            ),
            QuestionNewCategory(
                id: 5,
                content: "What aspects of this topic do you want to explore?",
                questionType: .multiSelect,
                category: .generic
            )
        ]
    }
    
    static func defaultQuestion() -> QuestionNewCategory {
        return QuestionNewCategory(
            id: 4,
            content: "What would be helpful?",
            questionType: .multiSelect,
            category: .generic,
            options: [
                "Offer a different perspective",
                "Give candid feedback",
                "Suggest next steps",
                "Other"
            ]
        )
    }
    
    
    static func getLifeAreas() -> [String] {
        // Filter realmsData to exclude:
        let realms = Realm.realmsData
        
        // Extract and return the lifeArea values from the remaining realms
        return realms.map { $0.name }
    }
    
    static func getQuestionFlow(for categoryChoice: String?) -> [QuestionNewCategory] {
        
        
        // If no choice has been made yet, just return empty array
        guard let categoryChoice = categoryChoice else {
            return []
        }
        
        // Determine which follow-up questions to show based on the first choice
        var questions: [QuestionNewCategory] = []
        
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
        static var careerQuestions: [QuestionNewCategory] {
            [
                .init(
                    id: 2,
                    content: "How are you feeling about your work these days?",
                    questionType: .singleSelect,
                    category: .career,
                    options: [
                        "Excited but unsure what's next",
                        "Frustrated by limited growth",
                        "Overwhelmed by tasks",
                        "Anxious about job security",
                        "Feel like something's missing"
                    ]
                ),
                .init(
                    id: 3,
                    content: "What's making work feel harder than it needs to be right now?",
                    questionType: .singleSelect,
                    category: .career,
                    options: [
                        "I just can't get motivated",
                        "I feel stuck and unsure how to move forward",
                        "I'm doubting myself or my abilities",
                        "There's too much on my plate",
                        "It doesn't feel meaningful"
                    ]
                ),
                .init(
                    id: 4,
                    content: "What would make things easier or better for you at work?",
                    questionType: .singleSelect,
                    category: .career,
                    options: [
                        "Clear goals or direction",
                        "More confidence in my skills",
                        "Finding more meaning or purpose",
                        "A healthier work-life balance",
                        "More support or recognition"
                    ]
                ),
                .init(
                    id: 5,
                    content: "What's your work life like right now?",
                    questionType: .singleSelect,
                    category: .career,
                    options: [
                        "I'm working full-time",
                        "I'm working part-time",
                        "I'm freelancing or running my own thing",
                        "I'm looking for work",
                        "I'm taking a break from working",
                        "I'm a student or just getting started"
                    ]
                ),
                .init(
                    id: 6,
                    content: "Imagine you're really happy with your career. What does that look like?",
                    questionType: .open,
                    category: .career
                )
            ]
        }
        
        // Relationship-related questions
        static var relationshipsQuestions: [QuestionNewCategory] {
            [
                .init(
                    id: 2,
                    content: "How connected do you feel with the people around you lately?",
                    questionType: .singleSelect,
                    category: .relationships,
                    options: [
                        "Pretty good, but I'd like deeper connections",
                        "Lonely, even around people",
                        "Anxious or unsure about social interactions",
                        "Overwhelmed by social expectations",
                        "Disconnected or not fully seen"
                    ]
                ),
                .init(
                    id: 3,
                    content: "What's been holding you back from connecting more deeply?",
                    questionType: .singleSelect,
                    category: .relationships,
                    options: [
                        "Life's too busy to make time",
                        "It feels awkward or hard to open up",
                        "Trusting people feels tough",
                        "I don't feel understood or valued",
                        "Friendships seem hard to keep up"
                    ]
                ),
                .init(
                    id: 4,
                    content: "What would help you feel closer to others right now?",
                    questionType: .singleSelect,
                    category: .relationships,
                    options: [
                        "More quality time with loved ones",
                        "Meeting new, like-minded people",
                        "Feeling more confident socially",
                        "Improving romantic relationships",
                        "Resolving past conflicts"
                    ]
                ),
                .init(
                    id: 5,
                    content: "What relationships matter most to you right now?",
                    questionType: .singleSelect,
                    category: .relationships,
                    options: [
                        "Close friends",
                        "Family",
                        "Romantic partner",
                        "Meeting new people",
                        "Coworkers or professional connections",
                        "Still figuring it out"
                    ]
                ),
                .init(
                    id: 6,
                    content: "Imagine your relationships feel supportive and joyful. What does that look like for you?",
                    questionType: .open,
                    category: .relationships
                )
            ]
        }
        
        // Finance-related questions
        static var financeQuestions: [QuestionNewCategory] {
            [
                .init(
                    id: 2,
                    content: "How do you feel about your finances these days?",
                    questionType: .singleSelect,
                    category: .finance,
                    options: [
                        "Stressed or worried",
                        "Frustrated with spending habits",
                        "Uncertain how to handle money better",
                        "Guilty for not saving enough",
                        "Overwhelmed by money decisions"
                    ]
                ),
                .init(
                    id: 3,
                    content: "What's causing the most tension around money right now?",
                    questionType: .singleSelect,
                    category: .finance,
                    options: [
                        "Struggling with everyday expenses",
                        "Saving feels really difficult",
                        "Worrying about future stability",
                        "Balancing saving with enjoying life now",
                        "Not really knowing where my money goes"
                    ]
                ),
                .init(
                    id: 4,
                    content: "What would help you feel better about your financial situation?",
                    questionType: .singleSelect,
                    category: .finance,
                    options: [
                        "A clear, workable budget",
                        "Saving consistently",
                        "Feeling in control of spending",
                        "Learning smarter financial moves",
                        "Reducing stress around bills"
                    ]
                ),
                .init(
                    id: 5,
                    content: "What's your financial situation like right now?",
                    questionType: .singleSelect,
                    category: .finance,
                    options: [
                        "I'm financially stable and comfortable",
                        "I'm getting by but money feels tight",
                        "I'm dealing with some debt",
                        "I'm focused on building savings or investing",
                        "Going through big financial changes",
                        "Something else"
                    ]
                ),
                .init(
                    id: 6,
                    content: "Imagine you feel totally secure and confident financially. What does that look like?",
                    questionType: .open,
                    category: .finance
                )
            ]
        }
        
        // Wellness-related questions
        static var wellnessQuestions: [QuestionNewCategory] {
            [
                .init(
                    id: 2,
                    content: "How have you been feeling health-wise lately?",
                    questionType: .singleSelect,
                    category: .wellness,
                    options: [
                        "Low on energy or tired a lot",
                        "Often stressed or anxious",
                        "Struggling with unhealthy habits",
                        "Disconnected from my body",
                        "Concerned about my health overall"
                    ]
                ),
                .init(
                    id: 3,
                    content: "What's been making self-care challenging recently?",
                    questionType: .singleSelect,
                    category: .wellness,
                    options: [
                        "Low motivation or energy",
                        "Too much stress or anxiety",
                        "Trouble sticking to healthy habits",
                        "Feeling constantly burned out",
                        "Poor sleep or rest"
                    ]
                ),
                .init(
                    id: 4,
                    content: "What could help you feel healthier or more balanced?",
                    questionType: .singleSelect,
                    category: .wellness,
                    options: [
                        "A better sleep routine",
                        "Managing stress more effectively",
                        "Improved eating or exercise habits",
                        "More rest and recharge time",
                        "Better understanding my body's needs"
                    ]
                ),
                .init(
                    id: 5,
                    content: "What's your biggest wellness priority right now?",
                    questionType: .singleSelect,
                    category: .wellness,
                    options: [
                        "Improving sleep quality",
                        "Managing stress or anxiety",
                        "Exercising more consistently",
                        "Eating healthier",
                        "Feeling more connected mentally and physically",
                        "Not sure yet"
                    ]
                ),
                .init(
                    id: 6,
                    content: "Imagine feeling completely healthy and balanced. How does that look for you?",
                    questionType: .open,
                    category: .wellness
                )
            ]
        }
        
        // Passion-related questions
        static var passionQuestions: [QuestionNewCategory] {
            [
                .init(
                    id: 2,
                    content: "How do you feel about spending time on things you love lately?",
                    questionType: .singleSelect,
                    category: .passion,
                    options: [
                        "Excited but unsure where to start",
                        "Frustrated by creative blocks",
                        "Anxious about my abilities",
                        "Disconnected from activities I used to enjoy",
                        "Curious but unsure what to explore"
                    ]
                ),
                .init(
                    id: 3,
                    content: "What's keeping you from doing more of what you enjoy?",
                    questionType: .singleSelect,
                    category: .passion,
                    options: [
                        "Not enough free time",
                        "Low inspiration or motivation",
                        "Doubting my abilities",
                        "Feeling guilty about not being productive",
                        "Unclear what truly excites me"
                    ]
                ),
                .init(
                    id: 4,
                    content: "What would help you do more of what you love right now?",
                    questionType: .singleSelect,
                    category: .passion,
                    options: [
                        "More dedicated creative time",
                        "Greater confidence in myself",
                        "Discovering new interests",
                        "Overcoming creative blocks",
                        "Less pressure to be perfect"
                    ]
                ),
                .init(
                    id: 5,
                    content: "What excites you most right now?",
                    questionType: .singleSelect,
                    category: .passion,
                    options: [
                        "Creative arts (writing, art, music, etc.)",
                        "Learning new skills or ideas",
                        "Traveling or exploring places",
                        "Connecting deeply with others",
                        "Making or building things",
                        "Still figuring it out"
                    ]
                ),
                .init(
                    id: 6,
                    content: "Imagine you feel inspired and free to explore your passions fully. What does that look like?",
                    questionType: .open,
                    category: .passion
                )
            ]
        }
        
        // Purpose-related questions
        static var purposeQuestions: [QuestionNewCategory] {
            [
                .init(
                    id: 2,
                    content: "How clear do you feel about your life's direction lately?",
                    questionType: .singleSelect,
                    category: .purpose,
                    options: [
                        "Pretty unclear or confused",
                        "Worried about making wrong choices",
                        "Frustrated by lack of progress",
                        "Disconnected from who I really am",
                        "Curious but unsure where to start"
                    ]
                ),
                .init(
                    id: 3,
                    content: "What's making it tough to feel clear about your path?",
                    questionType: .singleSelect,
                    category: .purpose,
                    options: [
                        "Unsure what really matters to me",
                        "Difficulty trusting my inner voice",
                        "Doubting decisions or abilities",
                        "Pressure from others' expectations",
                        "Lack of time to explore myself"
                    ]
                ),
                .init(
                    id: 4,
                    content: "What would help you feel clearer about your purpose right now?",
                    questionType: .singleSelect,
                    category: .purpose,
                    options: [
                        "Understanding my values better",
                        "Trusting myself more",
                        "Letting go of others' opinions",
                        "Exploring new possibilities",
                        "Feeling more grounded in myself"
                    ]
                ),
                .init(
                    id: 5,
                    content: "What feels most meaningful to you right now?",
                    questionType: .singleSelect,
                    category: .purpose,
                    options: [
                        "Personal growth",
                        "Impacting others positively",
                        "Living true to my values",
                        "Creating or expressing myself",
                        "Building meaningful relationships",
                        "Still figuring that out"
                    ]
                ),
                .init(
                    id: 6,
                    content: "Imagine you're completely sure about who you are and where you're headed. What does that look like?",
                    questionType: .open,
                    category: .purpose
                )
            ]
        }
}
