import Foundation

enum QuestionCategory {
    case icebreaker
    case situational
    case humor
    case philosophical
    case smallTalk
    case emotional
    case values
    case social
}

enum PersonalityDimension {
    case formality
    case emotionalExpression
    case humor
    case analyticalThinking
    case empathy
    case assertiveness
    case openness
    case optimism
    case detailOrientation
    case spontaneity
    case conflictStyle
    case socialEnergy
}

struct PersonalityQuestion {
    let id: Int
    let category: QuestionCategory
    let prompt: String
    let subPrompt: String?
    let followUps: [String: String]
    let analysisWeights: [PersonalityDimension: Float]
    let responsePatterns: [String: PersonalityMarker]
}

struct PersonalityMarker {
    let dimension: PersonalityDimension
    let weight: Float
    let indicator: String
}

struct ConversationContext {
    var currentQuestionIndex: Int = 0
    var responses: [QuestionResponse] = []
    var followUpQueue: [String] = []
    var detectedPatterns: [CommunicationPattern] = []
    var mood: EmotionalTone = .neutral
}

struct QuestionResponse {
    let questionId: Int
    let response: String
    let responseTime: TimeInterval
    let wordCount: Int
    let sentimentScore: Float
    let emojiCount: Int
    let punctuationStyle: PunctuationStyle
    let timestamp: Date
}

enum PunctuationStyle {
    case formal
    case casual
    case expressive
    case minimal
}

enum EmotionalTone {
    case enthusiastic
    case neutral
    case contemplative
    case humorous
    case serious
    case anxious
}

struct CommunicationPattern {
    let patternType: PatternType
    let frequency: Int
    let examples: [String]
    
    enum PatternType {
        case storyteller
        case factual
        case emotional
        case questioning
        case deflecting
        case selfDeprecating
        case confident
        case analytical
        case creative
        case pragmatic
    }
}

struct PersonalityProfile {
    let dimensions: [PersonalityDimension: Float]
    let communicationStyle: CommunicationStyle
    let humorStyle: HumorStyle
    let socialStyle: SocialStyle
    let thinkingStyle: ThinkingStyle
    let emotionalStyle: EmotionalStyle
    let typicalResponses: [String: String]
    let conversationStarters: [String]
    let comfortTopics: [String]
    let avoidanceTopics: [String]
    let stressIndicators: [String]
    let signature: PersonalitySignature
}

struct CommunicationStyle {
    let pace: String
    let formality: Float
    let expressiveness: Float
    let directness: Float
    let warmth: Float
    let detail: String
    let examples: [String]
    
    var description: String {
        let formalityStr = formality > 0.7 ? "formal" : formality > 0.3 ? "balanced" : "casual"
        let expressivenessStr = expressiveness > 0.7 ? "expressive" : expressiveness > 0.3 ? "moderate" : "reserved"
        return "\(formalityStr.capitalized) and \(expressivenessStr)"
    }
}

struct HumorStyle {
    let primaryType: HumorType
    let frequency: Float
    let triggers: [String]
    let examples: [String]
    
    enum HumorType {
        case dry
        case silly
        case sarcastic
        case witty
        case observational
        case selfdeprecating
        case none
    }
}

struct SocialStyle {
    let energy: String
    let groupPreference: String
    let initiationStyle: String
    let boundaryStyle: String
    let conflictApproach: String
}

struct ThinkingStyle {
    let approach: String
    let processing: String
    let focus: String
    let examples: [String]
}

struct EmotionalStyle {
    let expression: String
    let regulation: String
    let empathyLevel: Float
    let vulnerabilityComfort: Float
}

struct PersonalitySignature {
    let uniquePhrases: [String]
    let filler: [String]
    let greetingStyle: String
    let signoffStyle: String
    let laughStyle: [String]
    let agreementStyle: [String]
    let disagreementStyle: [String]
}