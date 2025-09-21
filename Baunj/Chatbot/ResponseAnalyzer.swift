import Foundation
import NaturalLanguage

class ResponseAnalyzer {
    
    static func analyzeResponse(_ response: String, for question: PersonalityQuestion) -> QuestionResponse {
        let startTime = Date()
        
        let wordCount = response.split(separator: " ").count
        let sentiment = analyzeSentiment(response)
        let emojiCount = countEmojis(in: response)
        let punctuation = analyzePunctuation(response)
        
        return QuestionResponse(
            questionId: question.id,
            response: response,
            responseTime: 0,
            wordCount: wordCount,
            sentimentScore: sentiment,
            emojiCount: emojiCount,
            punctuationStyle: punctuation,
            timestamp: startTime
        )
    }
    
    static func analyzeSentiment(_ text: String) -> Float {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        
        var totalScore: Float = 0
        var count = 0
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .paragraph, scheme: .sentimentScore) { tag, range in
            if let tag = tag,
               let score = Float(tag.rawValue) {
                totalScore += score
                count += 1
            }
            return true
        }
        
        return count > 0 ? totalScore / Float(count) : 0
    }
    
    static func countEmojis(in text: String) -> Int {
        var emojiCount = 0
        text.unicodeScalars.forEach { scalar in
            if scalar.properties.isEmoji && scalar.properties.isEmojiPresentation {
                emojiCount += 1
            }
        }
        return emojiCount
    }
    
    static func analyzePunctuation(_ text: String) -> PunctuationStyle {
        let exclamationCount = text.filter { $0 == "!" }.count
        let questionCount = text.filter { $0 == "?" }.count
        let ellipsisCount = text.components(separatedBy: "...").count - 1
        let periodCount = text.filter { $0 == "." }.count
        
        if exclamationCount > 2 || ellipsisCount > 1 {
            return .expressive
        } else if periodCount > 0 && exclamationCount == 0 && ellipsisCount == 0 {
            return .formal
        } else if exclamationCount == 0 && periodCount == 0 {
            return .minimal
        } else {
            return .casual
        }
    }
    
    static func detectPatterns(from responses: [QuestionResponse]) -> [CommunicationPattern] {
        var patterns: [CommunicationPattern] = []
        
        let avgWordCount = responses.reduce(0) { $0 + $1.wordCount } / max(responses.count, 1)
        if avgWordCount > 50 {
            patterns.append(CommunicationPattern(
                patternType: .storyteller,
                frequency: avgWordCount,
                examples: responses.prefix(2).map { $0.response }
            ))
        } else if avgWordCount < 20 {
            patterns.append(CommunicationPattern(
                patternType: .factual,
                frequency: avgWordCount,
                examples: responses.prefix(2).map { $0.response }
            ))
        }
        
        let emotionalResponses = responses.filter { abs($0.sentimentScore) > 0.5 }
        if emotionalResponses.count > responses.count / 2 {
            patterns.append(CommunicationPattern(
                patternType: .emotional,
                frequency: emotionalResponses.count,
                examples: emotionalResponses.prefix(2).map { $0.response }
            ))
        }
        
        let questioningResponses = responses.filter { $0.response.contains("?") }
        if questioningResponses.count > responses.count / 3 {
            patterns.append(CommunicationPattern(
                patternType: .questioning,
                frequency: questioningResponses.count,
                examples: questioningResponses.prefix(2).map { $0.response }
            ))
        }
        
        let selfReferences = responses.filter { 
            let lower = $0.response.lowercased()
            return lower.contains(" i ") || lower.contains("i'm") || lower.contains("i've") || lower.contains("my ")
        }
        if selfReferences.count > responses.count * 2 / 3 {
            patterns.append(CommunicationPattern(
                patternType: .confident,
                frequency: selfReferences.count,
                examples: selfReferences.prefix(2).map { $0.response }
            ))
        }
        
        return patterns
    }
    
    static func extractLinguisticMarkers(_ text: String) -> [String: Any] {
        var markers: [String: Any] = [:]
        
        let hedgeWords = ["maybe", "perhaps", "might", "could", "possibly", "probably", "sort of", "kind of"]
        let assertiveWords = ["definitely", "absolutely", "certainly", "obviously", "clearly", "must", "always", "never"]
        let fillerWords = ["um", "uh", "like", "you know", "basically", "literally", "actually"]
        
        let lowercased = text.lowercased()
        
        markers["hedgeCount"] = hedgeWords.filter { lowercased.contains($0) }.count
        markers["assertiveCount"] = assertiveWords.filter { lowercased.contains($0) }.count
        markers["fillerCount"] = fillerWords.filter { lowercased.contains($0) }.count
        
        markers["capitalizedWords"] = text.split(separator: " ").filter { 
            $0.first?.isUppercase == true && $0.count > 1 
        }.count
        
        markers["laughterIndicators"] = ["haha", "lol", "lmao", "hehe"].filter { 
            lowercased.contains($0) 
        }
        
        return markers
    }
    
    static func detectEmotionalTone(from responses: [QuestionResponse]) -> EmotionalTone {
        let avgSentiment = responses.reduce(0) { $0 + $1.sentimentScore } / Float(max(responses.count, 1))
        let avgEmojis = responses.reduce(0) { $0 + $1.emojiCount } / max(responses.count, 1)
        let expressivePunctuation = responses.filter { $0.punctuationStyle == .expressive }.count
        
        if avgSentiment > 0.3 && avgEmojis > 0 {
            return .enthusiastic
        } else if expressivePunctuation > responses.count / 2 {
            return .humorous
        } else if avgSentiment < -0.2 {
            return .anxious
        } else if avgSentiment < 0.1 && avgSentiment > -0.1 {
            let longResponses = responses.filter { $0.wordCount > 40 }.count
            if longResponses > responses.count / 2 {
                return .contemplative
            }
        }
        
        return .neutral
    }
    
    static func identifyConversationStyle(from responses: [QuestionResponse]) -> [String] {
        var styles: [String] = []
        
        let firstPersonCount = responses.filter { response in
            let lower = response.response.lowercased()
            return lower.contains(" i ") || lower.hasPrefix("i ")
        }.count
        
        let secondPersonCount = responses.filter { response in
            let lower = response.response.lowercased()
            return lower.contains(" you ") || lower.contains("your ")
        }.count
        
        if firstPersonCount > responses.count * 2/3 {
            styles.append("Personal storyteller")
        }
        
        if secondPersonCount > responses.count / 3 {
            styles.append("Engaging conversationalist")
        }
        
        let exampleCount = responses.filter { $0.response.lowercased().contains("for example") || $0.response.lowercased().contains("like when") }.count
        if exampleCount > 0 {
            styles.append("Uses concrete examples")
        }
        
        let metaphorWords = ["like", "as if", "similar to", "kind of like"]
        let metaphorCount = responses.filter { response in
            metaphorWords.contains { response.response.lowercased().contains($0) }
        }.count
        if metaphorCount > 1 {
            styles.append("Uses analogies and metaphors")
        }
        
        return styles
    }
}