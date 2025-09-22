import Foundation

class ChatGPTService {
    static let shared = ChatGPTService()
    
    private let apiKey: String
    private let apiURL = "https://api.openai.com/v1/chat/completions"
    private let session = URLSession.shared
    
    private init() {
        // Get API key from configuration (checks environment and Keychain)
        self.apiKey = APIConfiguration.shared.getAPIKey() ?? ""
    }
    
    struct ChatGPTRequest: Codable {
        let model: String
        let messages: [Message]
        let temperature: Double
        let max_tokens: Int
        let response_format: ResponseFormat?
        
        struct Message: Codable {
            let role: String
            let content: String
        }
        
        struct ResponseFormat: Codable {
            let type: String
        }
    }
    
    struct ChatGPTResponse: Codable {
        let choices: [Choice]
        
        struct Choice: Codable {
            let message: Message
            
            struct Message: Codable {
                let content: String
            }
        }
    }
    
    enum AnalysisType {
        case personalityAnalysis
        case twinGeneration
        case responseSimulation
    }
    
    func analyzePersonality(responses: [QuestionResponse], questions: [PersonalityQuestion]) async throws -> DetailedPersonalityAnalysis {
        let prompt = buildPersonalityAnalysisPrompt(responses: responses, questions: questions)
        
        let request = ChatGPTRequest(
            model: "gpt-4-turbo-preview",
            messages: [
                ChatGPTRequest.Message(role: "system", content: "You are an expert psycholinguist and personality analyst. Analyze the user's responses to create a detailed personality profile that captures not just what they say, but HOW they would say things. Focus on speech patterns, vocabulary choices, humor style, and conversational quirks."),
                ChatGPTRequest.Message(role: "user", content: prompt)
            ],
            temperature: 0.7,
            max_tokens: 2000,
            response_format: ChatGPTRequest.ResponseFormat(type: "json_object")
        )
        
        let result = try await performRequest(request)
        return try parsePersonalityAnalysis(result)
    }
    
    func generateDigitalTwin(analysis: DetailedPersonalityAnalysis, responses: [QuestionResponse]) async throws -> DigitalTwinModel {
        let prompt = buildTwinGenerationPrompt(analysis: analysis, responses: responses)
        
        let request = ChatGPTRequest(
            model: "gpt-4-turbo-preview",
            messages: [
                ChatGPTRequest.Message(role: "system", content: "You are creating a digital twin that can mimic someone's exact communication style. Based on the personality analysis and actual responses provided, create a comprehensive model that can generate responses exactly as this person would - including their specific phrases, humor, emotional expressions, and quirks."),
                ChatGPTRequest.Message(role: "user", content: prompt)
            ],
            temperature: 0.8,
            max_tokens: 2500,
            response_format: ChatGPTRequest.ResponseFormat(type: "json_object")
        )
        
        let result = try await performRequest(request)
        return try parseTwinModel(result)
    }
    
    func simulateResponse(twin: DigitalTwinModel, scenario: String) async throws -> String {
        let prompt = """
        You are a digital twin with the following personality profile:
        
        Speaking Style: \(twin.speakingStyle)
        Vocabulary Patterns: \(twin.vocabularyPatterns.joined(separator: ", "))
        Emotional Expression: \(twin.emotionalExpression)
        Humor Style: \(twin.humorStyle)
        Common Phrases: \(twin.commonPhrases.joined(separator: ", "))
        Response Patterns: \(twin.responsePatterns.joined(separator: "; "))
        
        Respond to this scenario EXACTLY as this person would, using their speech patterns, vocabulary, and mannerisms:
        
        Scenario: \(scenario)
        """
        
        let request = ChatGPTRequest(
            model: "gpt-4-turbo-preview",
            messages: [
                ChatGPTRequest.Message(role: "system", content: "You must respond EXACTLY as the person described would. Use their specific vocabulary, speech patterns, humor, and emotional expression. Do not break character."),
                ChatGPTRequest.Message(role: "user", content: prompt)
            ],
            temperature: 0.9,
            max_tokens: 500,
            response_format: nil
        )
        
        let result = try await performRequest(request)
        return result
    }
    
    private func buildPersonalityAnalysisPrompt(responses: [QuestionResponse], questions: [PersonalityQuestion]) -> String {
        var prompt = "Analyze these conversation responses to build a detailed personality profile:\n\n"
        
        for (index, response) in responses.enumerated() {
            if index < questions.count {
                prompt += "Q\(index + 1): \(questions[index].prompt)\n"
                prompt += "Response: \(response.response)\n"
                prompt += "Response Time: \(response.responseTime) seconds\n"
                prompt += "Word Count: \(response.wordCount)\n"
                prompt += "Punctuation Style: \(response.punctuationStyle)\n"
                prompt += "Emoji Count: \(response.emojiCount)\n\n"
            }
        }
        
        prompt += """
        Create a detailed JSON analysis with the following structure:
        {
            "speaking_style": {
                "pace": "fast/moderate/slow",
                "formality": 0.0-1.0,
                "verbosity": "concise/balanced/elaborate",
                "sentence_structure": "simple/varied/complex",
                "examples": ["actual example sentences from their responses"]
            },
            "vocabulary_patterns": {
                "complexity_level": "basic/intermediate/advanced",
                "favorite_words": ["words they use frequently"],
                "filler_words": ["um", "like", "you know", etc.],
                "unique_phrases": ["phrases specific to them"],
                "slang_usage": ["any slang or colloquialisms"]
            },
            "emotional_expression": {
                "openness": 0.0-1.0,
                "intensity": "subdued/moderate/intense",
                "primary_emotions": ["emotions they express most"],
                "expression_methods": ["how they show emotions - emojis, words, punctuation"]
            },
            "humor_style": {
                "type": "dry/sarcastic/silly/witty/observational/self-deprecating",
                "frequency": 0.0-1.0,
                "delivery": "subtle/obvious/mixed",
                "examples": ["actual humorous responses"]
            },
            "conversational_patterns": {
                "question_asking": "frequent/occasional/rare",
                "storytelling": "detailed/brief/avoids",
                "topic_transitions": "smooth/abrupt/follows_others",
                "engagement_style": "initiates/responds/balanced"
            },
            "personality_markers": {
                "confidence_level": 0.0-1.0,
                "empathy_expression": 0.0-1.0,
                "analytical_thinking": 0.0-1.0,
                "creativity": 0.0-1.0,
                "authenticity": 0.0-1.0
            },
            "speech_quirks": {
                "repetitions": ["phrases they repeat"],
                "emphasis_patterns": ["how they emphasize - CAPS, repetition, etc."],
                "punctuation_habits": ["...", "!!!", "?!?", etc.],
                "response_starters": ["how they typically start responses"],
                "response_endings": ["how they typically end responses"]
            }
        }
        """
        
        return prompt
    }
    
    private func buildTwinGenerationPrompt(analysis: DetailedPersonalityAnalysis, responses: [QuestionResponse]) -> String {
        return """
        Based on this personality analysis, create a digital twin model that can perfectly mimic this person's communication style.
        
        Analysis: \(analysis.toJSON())
        
        Sample Responses for Reference:
        \(responses.map { "- \($0.response)" }.joined(separator: "\n"))
        
        Generate a comprehensive digital twin model in JSON format:
        {
            "core_personality": {
                "summary": "2-3 sentence description of their personality",
                "key_traits": ["trait1", "trait2", "trait3"]
            },
            "speaking_rules": {
                "sentence_starters": ["typical ways they start sentences"],
                "sentence_endings": ["typical ways they end sentences"],
                "transition_phrases": ["how they connect thoughts"],
                "agreement_phrases": ["how they agree with someone"],
                "disagreement_phrases": ["how they disagree with someone"],
                "uncertainty_phrases": ["how they express uncertainty"]
            },
            "vocabulary_bank": {
                "common_words": ["frequently used words"],
                "avoid_words": ["words they never use"],
                "substitute_patterns": {"formal_word": "their_casual_version"},
                "emoji_usage": ["emojis they use and when"]
            },
            "response_templates": {
                "greeting": "how they greet people",
                "small_talk": "how they do small talk",
                "storytelling": "how they tell stories",
                "opinion_sharing": "how they share opinions",
                "emotional_support": "how they provide support",
                "humor": "how they make jokes"
            },
            "behavioral_rules": {
                "enthusiasm_triggers": ["what makes them excited"],
                "avoidance_topics": ["what they avoid discussing"],
                "elaboration_triggers": ["when they give long responses"],
                "brief_response_triggers": ["when they give short responses"]
            },
            "authenticity_markers": {
                "genuine_reactions": ["their authentic responses"],
                "nervous_tells": ["how they act when uncomfortable"],
                "excitement_tells": ["how they show genuine excitement"],
                "thinking_patterns": ["how they process information"]
            }
        }
        """
    }
    
    private func performRequest(_ request: ChatGPTRequest) async throws -> String {
        var urlRequest = URLRequest(url: URL(string: apiURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, _) = try await session.data(for: urlRequest)
        let response = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
        
        guard let content = response.choices.first?.message.content else {
            throw ChatGPTError.noResponse
        }
        
        return content
    }
    
    private func parsePersonalityAnalysis(_ json: String) throws -> DetailedPersonalityAnalysis {
        guard let data = json.data(using: .utf8) else {
            throw ChatGPTError.invalidJSON
        }
        return try JSONDecoder().decode(DetailedPersonalityAnalysis.self, from: data)
    }
    
    private func parseTwinModel(_ json: String) throws -> DigitalTwinModel {
        guard let data = json.data(using: .utf8) else {
            throw ChatGPTError.invalidJSON
        }
        return try JSONDecoder().decode(DigitalTwinModel.self, from: data)
    }
    
    enum ChatGPTError: Error {
        case noAPIKey
        case noResponse
        case invalidJSON
        case networkError
    }
}

// MARK: - Models

struct DetailedPersonalityAnalysis: Codable {
    let speakingStyle: SpeakingStyle
    let vocabularyPatterns: VocabularyPatterns
    let emotionalExpression: EmotionalExpression
    let humorStyle: HumorAnalysis
    let conversationalPatterns: ConversationalPatterns
    let personalityMarkers: PersonalityMarkers
    let speechQuirks: SpeechQuirks
    
    struct SpeakingStyle: Codable {
        let pace: String
        let formality: Float
        let verbosity: String
        let sentenceStructure: String
        let examples: [String]
    }
    
    struct VocabularyPatterns: Codable {
        let complexityLevel: String
        let favoriteWords: [String]
        let fillerWords: [String]
        let uniquePhrases: [String]
        let slangUsage: [String]
    }
    
    struct EmotionalExpression: Codable {
        let openness: Float
        let intensity: String
        let primaryEmotions: [String]
        let expressionMethods: [String]
    }
    
    struct HumorAnalysis: Codable {
        let type: String
        let frequency: Float
        let delivery: String
        let examples: [String]
    }
    
    struct ConversationalPatterns: Codable {
        let questionAsking: String
        let storytelling: String
        let topicTransitions: String
        let engagementStyle: String
    }
    
    struct PersonalityMarkers: Codable {
        let confidenceLevel: Float
        let empathyExpression: Float
        let analyticalThinking: Float
        let creativity: Float
        let authenticity: Float
    }
    
    struct SpeechQuirks: Codable {
        let repetitions: [String]
        let emphasisPatterns: [String]
        let punctuationHabits: [String]
        let responseStarters: [String]
        let responseEndings: [String]
    }
    
    func toJSON() -> String {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }
}

struct DigitalTwinModel: Codable {
    let corePersonality: CorePersonality
    let speakingRules: SpeakingRules
    let vocabularyBank: VocabularyBank
    let responseTemplates: ResponseTemplates
    let behavioralRules: BehavioralRules
    let authenticityMarkers: AuthenticityMarkers
    
    var speakingStyle: String {
        corePersonality.summary
    }
    
    var vocabularyPatterns: [String] {
        vocabularyBank.commonWords
    }
    
    var emotionalExpression: String {
        authenticityMarkers.genuineReactions.joined(separator: ", ")
    }
    
    var humorStyle: String {
        responseTemplates.humor
    }
    
    var commonPhrases: [String] {
        speakingRules.sentenceStarters + speakingRules.transitionPhrases
    }
    
    var responsePatterns: [String] {
        [responseTemplates.greeting,
         responseTemplates.smallTalk,
         responseTemplates.opinionSharing]
    }
    
    struct CorePersonality: Codable {
        let summary: String
        let keyTraits: [String]
    }
    
    struct SpeakingRules: Codable {
        let sentenceStarters: [String]
        let sentenceEndings: [String]
        let transitionPhrases: [String]
        let agreementPhrases: [String]
        let disagreementPhrases: [String]
        let uncertaintyPhrases: [String]
    }
    
    struct VocabularyBank: Codable {
        let commonWords: [String]
        let avoidWords: [String]
        let substitutePatterns: [String: String]
        let emojiUsage: [String]
    }
    
    struct ResponseTemplates: Codable {
        let greeting: String
        let smallTalk: String
        let storytelling: String
        let opinionSharing: String
        let emotionalSupport: String
        let humor: String
    }
    
    struct BehavioralRules: Codable {
        let enthusiasmTriggers: [String]
        let avoidanceTopics: [String]
        let elaborationTriggers: [String]
        let briefResponseTriggers: [String]
    }
    
    struct AuthenticityMarkers: Codable {
        let genuineReactions: [String]
        let nervousTells: [String]
        let excitementTells: [String]
        let thinkingPatterns: [String]
    }
}