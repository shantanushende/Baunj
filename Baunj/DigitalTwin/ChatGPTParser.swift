import Foundation
import SwiftSoup

struct ChatGPTParser {
    
    struct ConversationData {
        let userMessages: [String]
        let assistantMessages: [String]
        let topics: Set<String>
        let messageCount: Int
        let averageMessageLength: Int
    }
    
    struct PersonaTraits {
        let communicationStyle: CommunicationStyle
        let interests: [String]
        let personalityTraits: [String]
        let conversationPatterns: [String]
        let vocabulary: VocabularyProfile
    }
    
    struct CommunicationStyle {
        let formality: Float // 0 = casual, 1 = formal
        let analyticalScore: Float // 0 = emotional, 1 = analytical
        let verbosity: Float // 0 = concise, 1 = verbose
        let questionFrequency: Float // How often they ask questions
        
        var description: String {
            let formalityStr = formality > 0.6 ? "Formal" : formality > 0.3 ? "Balanced" : "Casual"
            let analyticalStr = analyticalScore > 0.6 ? "Analytical" : analyticalScore > 0.3 ? "Balanced" : "Intuitive"
            return "\(formalityStr) & \(analyticalStr)"
        }
    }
    
    struct VocabularyProfile {
        let commonPhrases: [String]
        let techTermsUsed: Bool
        let emojiUsage: Bool
        let averageWordComplexity: Float
    }
    
    static func parseHTMLFile(at url: URL) -> ConversationData? {
        guard let htmlContent = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }
        
        do {
            let doc = try SwiftSoup.parse(htmlContent)
            
            var userMessages: [String] = []
            var assistantMessages: [String] = []
            
            // ChatGPT export structure typically has message divs
            let messages = try doc.select("div[data-message-author-role]")
            
            for message in messages {
                let role = try message.attr("data-message-author-role")
                let text = try message.text()
                
                if role == "user" {
                    userMessages.append(text)
                } else if role == "assistant" {
                    assistantMessages.append(text)
                }
            }
            
            // If the above doesn't work, try alternative parsing
            if userMessages.isEmpty {
                // Try alternative selectors for different export formats
                let allText = try doc.text()
                let lines = allText.components(separatedBy: .newlines)
                
                var isUserMessage = false
                for line in lines {
                    if line.contains("You:") || line.contains("User:") {
                        isUserMessage = true
                        userMessages.append(line)
                    } else if line.contains("ChatGPT:") || line.contains("Assistant:") {
                        isUserMessage = false
                        assistantMessages.append(line)
                    } else if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                        if isUserMessage {
                            userMessages.append(line)
                        }
                    }
                }
            }
            
            let topics = extractTopics(from: userMessages)
            let avgLength = userMessages.reduce(0) { $0 + $1.count } / max(userMessages.count, 1)
            
            return ConversationData(
                userMessages: userMessages,
                assistantMessages: assistantMessages,
                topics: topics,
                messageCount: userMessages.count,
                averageMessageLength: avgLength
            )
        } catch {
            print("Error parsing HTML: \(error)")
            return nil
        }
    }
    
    static func generatePersona(from conversations: [ConversationData]) -> PersonaTraits {
        let allMessages = conversations.flatMap { $0.userMessages }
        
        let style = analyzeCommunicationStyle(messages: allMessages)
        let interests = extractInterests(from: conversations)
        let traits = derivePersonalityTraits(from: allMessages, style: style)
        let patterns = identifyConversationPatterns(from: allMessages)
        let vocabulary = analyzeVocabulary(from: allMessages)
        
        return PersonaTraits(
            communicationStyle: style,
            interests: interests,
            personalityTraits: traits,
            conversationPatterns: patterns,
            vocabulary: vocabulary
        )
    }
    
    private static func analyzeCommunicationStyle(messages: [String]) -> CommunicationStyle {
        let formalWords = ["therefore", "however", "furthermore", "regarding", "pursuant"]
        let casualWords = ["yeah", "cool", "awesome", "lol", "btw", "gonna"]
        let questionWords = ["what", "how", "why", "when", "where", "could", "would", "can"]
        
        var formalCount = 0
        var casualCount = 0
        var questionCount = 0
        var totalWords = 0
        var totalLength = 0
        
        for message in messages {
            let words = message.lowercased().components(separatedBy: .whitespaces)
            totalWords += words.count
            totalLength += message.count
            
            for word in words {
                if formalWords.contains(where: { word.contains($0) }) {
                    formalCount += 1
                }
                if casualWords.contains(where: { word.contains($0) }) {
                    casualCount += 1
                }
                if questionWords.contains(where: { word.contains($0) }) {
                    questionCount += 1
                }
            }
            
            if message.contains("?") {
                questionCount += 2
            }
        }
        
        let formality = Float(formalCount) / Float(max(formalCount + casualCount, 1))
        let analytical = Float(totalLength) / Float(max(messages.count * 100, 1))
        let verbosity = Float(totalWords) / Float(max(messages.count * 20, 1))
        let questions = Float(questionCount) / Float(max(messages.count, 1))
        
        return CommunicationStyle(
            formality: min(max(formality, 0), 1),
            analyticalScore: min(max(analytical, 0), 1),
            verbosity: min(max(verbosity, 0), 1),
            questionFrequency: min(max(questions / 3, 0), 1)
        )
    }
    
    private static func extractTopics(from messages: [String]) -> Set<String> {
        let techKeywords = ["code", "programming", "software", "app", "AI", "data", "algorithm", "design", "build", "develop"]
        let businessKeywords = ["startup", "business", "market", "customer", "product", "growth", "revenue"]
        let creativeKeywords = ["art", "music", "creative", "design", "story", "write"]
        
        var topics = Set<String>()
        let allText = messages.joined(separator: " ").lowercased()
        
        if techKeywords.contains(where: { allText.contains($0) }) {
            topics.insert("Technology")
        }
        if businessKeywords.contains(where: { allText.contains($0) }) {
            topics.insert("Business & Startups")
        }
        if creativeKeywords.contains(where: { allText.contains($0) }) {
            topics.insert("Creative Arts")
        }
        
        return topics
    }
    
    private static func extractInterests(from conversations: [ConversationData]) -> [String] {
        var allTopics = Set<String>()
        for conv in conversations {
            allTopics.formUnion(conv.topics)
        }
        return Array(allTopics).sorted()
    }
    
    private static func derivePersonalityTraits(from messages: [String], style: CommunicationStyle) -> [String] {
        var traits: [String] = []
        
        if style.analyticalScore > 0.6 {
            traits.append("Analytical")
        }
        if style.questionFrequency > 0.5 {
            traits.append("Curious")
        }
        if style.formality < 0.3 {
            traits.append("Casual & Approachable")
        }
        if style.verbosity > 0.6 {
            traits.append("Detailed-Oriented")
        } else if style.verbosity < 0.4 {
            traits.append("Concise")
        }
        
        return traits
    }
    
    private static func identifyConversationPatterns(from messages: [String]) -> [String] {
        var patterns: [String] = []
        
        let questionCount = messages.filter { $0.contains("?") }.count
        if Float(questionCount) / Float(max(messages.count, 1)) > 0.3 {
            patterns.append("Asks clarifying questions")
        }
        
        let exampleCount = messages.filter { $0.lowercased().contains("for example") || $0.lowercased().contains("like") }.count
        if exampleCount > messages.count / 10 {
            patterns.append("Uses examples to explain")
        }
        
        return patterns
    }
    
    private static func analyzeVocabulary(from messages: [String]) -> VocabularyProfile {
        let allText = messages.joined(separator: " ")
        let hasEmoji = allText.contains(where: { $0.unicodeScalars.contains { $0.properties.isEmoji } })
        let hasTech = ["API", "UI", "UX", "ML", "AI"].contains { allText.contains($0) }
        
        return VocabularyProfile(
            commonPhrases: [],
            techTermsUsed: hasTech,
            emojiUsage: hasEmoji,
            averageWordComplexity: 0.5
        )
    }
}