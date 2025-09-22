import Foundation

class PersonalitySynthesizer {
    
    func synthesize(from context: ConversationContext) -> PersonalityProfile {
        let dimensions = calculateDimensions(from: context.responses)
        let communicationStyle = analyzeCommunicationStyle(from: context.responses)
        let humorStyle = analyzeHumorStyle(from: context.responses)
        let socialStyle = analyzeSocialStyle(from: context.responses)
        let thinkingStyle = analyzeThinkingStyle(from: context.responses)
        let emotionalStyle = analyzeEmotionalStyle(from: context.responses)
        let typicalResponses = generateTypicalResponses(from: context.responses)
        let starters = generateConversationStarters(from: context)
        let signature = extractPersonalitySignature(from: context.responses)
        
        return PersonalityProfile(
            dimensions: dimensions,
            communicationStyle: communicationStyle,
            humorStyle: humorStyle,
            socialStyle: socialStyle,
            thinkingStyle: thinkingStyle,
            emotionalStyle: emotionalStyle,
            typicalResponses: typicalResponses,
            conversationStarters: starters,
            comfortTopics: identifyComfortTopics(from: context.responses),
            avoidanceTopics: identifyAvoidanceTopics(from: context.responses),
            stressIndicators: identifyStressIndicators(from: context.responses),
            signature: signature
        )
    }
    
    private func calculateDimensions(from responses: [QuestionResponse]) -> [PersonalityDimension: Float] {
        var dimensions: [PersonalityDimension: Float] = [:]
        
        guard !responses.isEmpty else {
            // Return default values if no responses
            return [
                .formality: 0.5,
                .emotionalExpression: 0.5,
                .humor: 0.5,
                .analyticalThinking: 0.5,
                .empathy: 0.5,
                .assertiveness: 0.5,
                .openness: 0.5,
                .optimism: 0.5,
                .detailOrientation: 0.5,
                .spontaneity: 0.5,
                .conflictStyle: 0.5,
                .socialEnergy: 0.5
            ]
        }
        
        let avgWordCount = Float(responses.reduce(0) { $0 + $1.wordCount }) / Float(max(responses.count, 1))
        dimensions[.detailOrientation] = min(max(0, avgWordCount / 50), 1.0)
        
        let avgSentiment = responses.reduce(0) { $0 + $1.sentimentScore } / Float(max(responses.count, 1))
        dimensions[.optimism] = max(0, min(1, (avgSentiment + 1) / 2))
        
        let emojiTotal = responses.reduce(0) { $0 + $1.emojiCount }
        dimensions[.emotionalExpression] = min(max(0, Float(emojiTotal) / Float(max(responses.count * 2, 1))), 1.0)
        
        let formalCount = responses.filter { $0.punctuationStyle == .formal }.count
        dimensions[.formality] = max(0, min(1, Float(formalCount) / Float(max(responses.count, 1))))
        
        let questionCount = responses.filter { $0.response.contains("?") }.count
        dimensions[.openness] = max(0, min(1, Float(questionCount) / Float(max(responses.count, 1))))
        
        dimensions[.analyticalThinking] = calculateAnalyticalScore(from: responses)
        dimensions[.empathy] = calculateEmpathyScore(from: responses)
        dimensions[.assertiveness] = calculateAssertivenessScore(from: responses)
        dimensions[.spontaneity] = calculateSpontaneityScore(from: responses)
        dimensions[.humor] = calculateHumorScore(from: responses)
        
        return dimensions
    }
    
    private func calculateAnalyticalScore(from responses: [QuestionResponse]) -> Float {
        let analyticalWords = ["because", "therefore", "analyze", "consider", "think", "reason", "logic", "evidence"]
        var score: Float = 0
        
        for response in responses {
            let lower = response.response.lowercased()
            let matches = analyticalWords.filter { lower.contains($0) }.count
            score += Float(matches) / Float(analyticalWords.count)
        }
        
        return responses.isEmpty ? 0.5 : min(max(0, score / Float(responses.count)), 1.0)
    }
    
    private func calculateEmpathyScore(from responses: [QuestionResponse]) -> Float {
        let empathyWords = ["understand", "feel", "sorry", "happy for", "support", "care", "relate", "imagine"]
        var score: Float = 0
        
        for response in responses {
            let lower = response.response.lowercased()
            let matches = empathyWords.filter { lower.contains($0) }.count
            score += Float(matches) / Float(empathyWords.count)
        }
        
        return responses.isEmpty ? 0.5 : min(max(0, score / Float(responses.count)), 1.0)
    }
    
    private func calculateAssertivenessScore(from responses: [QuestionResponse]) -> Float {
        let assertiveWords = ["definitely", "absolutely", "must", "should", "need", "will", "won't", "never", "always"]
        var score: Float = 0
        
        for response in responses {
            let lower = response.response.lowercased()
            let matches = assertiveWords.filter { lower.contains($0) }.count
            score += Float(matches) / Float(assertiveWords.count)
        }
        
        return responses.isEmpty ? 0.5 : min(max(0, score / Float(responses.count)), 1.0)
    }
    
    private func calculateSpontaneityScore(from responses: [QuestionResponse]) -> Float {
        var score: Float = 0
        
        for response in responses {
            if response.responseTime < 5 { score += 0.2 }
            if response.punctuationStyle == .expressive { score += 0.1 }
            if response.emojiCount > 0 { score += 0.1 }
        }
        
        return responses.isEmpty ? 0.5 : min(max(0, score / Float(responses.count)), 1.0)
    }
    
    private func calculateHumorScore(from responses: [QuestionResponse]) -> Float {
        let humorIndicators = ["haha", "lol", "lmao", "funny", "hilarious", "joke", "laugh", "😂", "😆", "🤣"]
        var score: Float = 0
        
        for response in responses {
            let lower = response.response.lowercased()
            let matches = humorIndicators.filter { lower.contains($0) }.count
            score += Float(min(matches, 3)) / 3.0
        }
        
        return responses.isEmpty ? 0.5 : min(max(0, score / Float(responses.count)), 1.0)
    }
    
    private func analyzeCommunicationStyle(from responses: [QuestionResponse]) -> CommunicationStyle {
        let avgWords = Float(responses.reduce(0) { $0 + $1.wordCount }) / Float(max(responses.count, 1))
        let pace = avgWords < 20 ? "Quick and concise" : avgWords > 50 ? "Detailed and thorough" : "Balanced"
        
        let formalCount = responses.filter { $0.punctuationStyle == .formal }.count
        let formality = Float(formalCount) / Float(max(responses.count, 1))
        
        let emojiCount = responses.reduce(0) { $0 + $1.emojiCount }
        let expressiveness = min(Float(emojiCount) / Float(responses.count), 1.0)
        
        let directWords = ["honestly", "actually", "literally", "basically", "simply"]
        var directness: Float = 0
        for response in responses {
            let matches = directWords.filter { response.response.lowercased().contains($0) }.count
            directness += Float(matches) > 0 ? 0.1 : 0
        }
        directness = min(directness, 1.0)
        
        let warmthIndicators = ["thanks", "please", "appreciate", "love", "great", "awesome", "nice"]
        var warmth: Float = 0
        for response in responses {
            let matches = warmthIndicators.filter { response.response.lowercased().contains($0) }.count
            warmth += Float(matches) > 0 ? 0.15 : 0
        }
        warmth = min(warmth, 1.0)
        
        let detail = avgWords > 40 ? "Provides context and examples" : "Gets to the point"
        
        let examples = responses.prefix(2).map { 
            String($0.response.prefix(100)) + ($0.response.count > 100 ? "..." : "")
        }
        
        return CommunicationStyle(
            pace: pace,
            formality: formality,
            expressiveness: expressiveness,
            directness: directness,
            warmth: warmth,
            detail: detail,
            examples: examples
        )
    }
    
    private func analyzeHumorStyle(from responses: [QuestionResponse]) -> HumorStyle {
        var humorCounts: [HumorStyle.HumorType: Int] = [:]
        var examples: [String] = []
        
        for response in responses {
            let lower = response.response.lowercased()
            
            if lower.contains("sarcas") || lower.contains("obviously") || lower.contains("clearly") {
                humorCounts[.sarcastic, default: 0] += 1
            }
            if lower.contains("haha") || lower.contains("lol") || response.emojiCount > 1 {
                humorCounts[.silly, default: 0] += 1
                if lower.contains("haha") || lower.contains("lol") {
                    examples.append(String(response.response.prefix(50)))
                }
            }
            if lower.contains("myself") && (lower.contains("stupid") || lower.contains("dumb") || lower.contains("idiot")) {
                humorCounts[.selfdeprecating, default: 0] += 1
            }
            if lower.contains("witty") || lower.contains("clever") {
                humorCounts[.witty, default: 0] += 1
            }
        }
        
        let primaryType = humorCounts.max(by: { $0.value < $1.value })?.key ?? .observational
        let frequency = Float(humorCounts.values.reduce(0, +)) / Float(responses.count)
        
        let triggers = frequency > 0.5 ? ["Casual conversation", "Awkward moments"] : ["Comfortable settings"]
        
        return HumorStyle(
            primaryType: primaryType,
            frequency: frequency,
            triggers: triggers,
            examples: examples
        )
    }
    
    private func analyzeSocialStyle(from responses: [QuestionResponse]) -> SocialStyle {
        let avgWords = responses.reduce(0) { $0 + $1.wordCount } / max(responses.count, 1)
        let energy = avgWords > 30 ? "Extroverted - enjoys sharing" : "Introverted - selective sharing"
        
        let groupWords = ["everyone", "people", "friends", "group", "team", "together"]
        let soloWords = ["alone", "myself", "solitary", "quiet", "personal"]
        
        var groupScore = 0
        var soloScore = 0
        for response in responses {
            let lower = response.response.lowercased()
            groupScore += groupWords.filter { lower.contains($0) }.count
            soloScore += soloWords.filter { lower.contains($0) }.count
        }
        
        let groupPreference = groupScore > soloScore ? "Group activities" : "One-on-one or solo"
        let initiationStyle = responses.filter { $0.response.contains("?") }.count > 2 ? "Asks questions" : "Shares experiences"
        let boundaryStyle = "Balanced - shares gradually"
        let conflictApproach = "Diplomatic"
        
        return SocialStyle(
            energy: energy,
            groupPreference: groupPreference,
            initiationStyle: initiationStyle,
            boundaryStyle: boundaryStyle,
            conflictApproach: conflictApproach
        )
    }
    
    private func analyzeThinkingStyle(from responses: [QuestionResponse]) -> ThinkingStyle {
        let analyticalWords = ["analyze", "think", "consider", "because", "reason"]
        let intuitiveWords = ["feel", "sense", "gut", "seems", "probably"]
        
        var analyticalScore = 0
        var intuitiveScore = 0
        
        for response in responses {
            let lower = response.response.lowercased()
            analyticalScore += analyticalWords.filter { lower.contains($0) }.count
            intuitiveScore += intuitiveWords.filter { lower.contains($0) }.count
        }
        
        let approach = analyticalScore > intuitiveScore ? "Analytical" : "Intuitive"
        let processing = responses.first?.responseTime ?? 0 > 10 ? "Deliberate" : "Quick"
        let focus = "Balanced between big picture and details"
        
        let examples = ["Considers multiple perspectives", "Uses personal experience as reference"]
        
        return ThinkingStyle(
            approach: approach,
            processing: processing,
            focus: focus,
            examples: examples
        )
    }
    
    private func analyzeEmotionalStyle(from responses: [QuestionResponse]) -> EmotionalStyle {
        let emotionalWords = ["feel", "felt", "happy", "sad", "angry", "excited", "worried", "love", "hate"]
        var emotionalCount = 0
        
        for response in responses {
            let lower = response.response.lowercased()
            emotionalCount += emotionalWords.filter { lower.contains($0) }.count
        }
        
        let expression = emotionalCount > responses.count * 2 ? "Open and expressive" : "Reserved"
        let regulation = "Balanced emotional regulation"
        let empathy = Float(emotionalCount) / Float(max(responses.count * 3, 1))
        let vulnerability = empathy * 0.7
        
        return EmotionalStyle(
            expression: expression,
            regulation: regulation,
            empathyLevel: min(empathy, 1.0),
            vulnerabilityComfort: vulnerability
        )
    }
    
    private func generateTypicalResponses(from responses: [QuestionResponse]) -> [String: String] {
        var typical: [String: String] = [:]
        
        let greetingStyle = responses.first?.response.lowercased().contains("hey") ?? false ? "Hey!" : "Hi there!"
        typical["greeting"] = greetingStyle
        
        typical["agreement"] = responses.contains { $0.response.lowercased().contains("totally") } ? "Totally!" : "I agree"
        typical["disagreement"] = "I see what you mean, but..."
        typical["excitement"] = responses.reduce(0) { $0 + $1.emojiCount } > 3 ? "That's amazing!! 🎉" : "That's great!"
        typical["sympathy"] = "I'm sorry to hear that"
        typical["confusion"] = "Hmm, I'm not sure I follow..."
        
        return typical
    }
    
    private func generateConversationStarters(from context: ConversationContext) -> [String] {
        var starters: [String] = []
        
        if context.responses.contains(where: { $0.response.lowercased().contains("show") || $0.response.lowercased().contains("movie") }) {
            starters.append("Have you seen anything good lately?")
        }
        
        if context.responses.contains(where: { $0.response.lowercased().contains("work") }) {
            starters.append("How's work been treating you?")
        }
        
        starters.append("So what's new with you?")
        starters.append("Got any fun plans coming up?")
        
        if context.mood == .humorous {
            starters.append("Okay, I need your take on something ridiculous...")
        }
        
        return starters
    }
    
    private func identifyComfortTopics(from responses: [QuestionResponse]) -> [String] {
        var topics: [String] = []
        
        for response in responses {
            let lower = response.response.lowercased()
            if lower.contains("work") || lower.contains("job") { topics.append("Career") }
            if lower.contains("friend") { topics.append("Friendships") }
            if lower.contains("family") { topics.append("Family") }
            if lower.contains("movie") || lower.contains("show") || lower.contains("music") { topics.append("Entertainment") }
            if lower.contains("travel") { topics.append("Travel") }
        }
        
        return Array(Set(topics))
    }
    
    private func identifyAvoidanceTopics(from responses: [QuestionResponse]) -> [String] {
        var avoided: [String] = []
        
        let shortResponses = responses.filter { $0.wordCount < 10 }
        for response in shortResponses {
            let lower = response.response.lowercased()
            if lower.contains("politic") { avoided.append("Politics") }
            if lower.contains("personal") { avoided.append("Very personal topics") }
        }
        
        return avoided
    }
    
    private func identifyStressIndicators(from responses: [QuestionResponse]) -> [String] {
        return [
            "Shorter responses than usual",
            "Less emoji usage",
            "More formal language",
            "Delayed response times"
        ]
    }
    
    private func extractPersonalitySignature(from responses: [QuestionResponse]) -> PersonalitySignature {
        var phrases: Set<String> = []
        var fillers: Set<String> = []
        var laughs: Set<String> = []
        
        for response in responses {
            let lower = response.response.lowercased()
            
            if lower.contains("honestly") { phrases.insert("honestly") }
            if lower.contains("literally") { phrases.insert("literally") }
            if lower.contains("basically") { fillers.insert("basically") }
            if lower.contains("like") && !lower.contains("i like") { fillers.insert("like") }
            
            if lower.contains("haha") { laughs.insert("haha") }
            if lower.contains("lol") { laughs.insert("lol") }
            if lower.contains("😂") { laughs.insert("😂") }
        }
        
        let greeting = responses.first?.response.lowercased().contains("hey") ?? false ? "Hey!" : "Hi!"
        let signoff = "Talk soon!"
        
        let agreement = phrases.contains("totally") ? ["Totally!", "Exactly!"] : ["I agree", "That makes sense"]
        let disagreement = ["I see what you mean, but...", "Hmm, I'm not so sure..."]
        
        return PersonalitySignature(
            uniquePhrases: Array(phrases),
            filler: Array(fillers),
            greetingStyle: greeting,
            signoffStyle: signoff,
            laughStyle: Array(laughs),
            agreementStyle: agreement,
            disagreementStyle: disagreement
        )
    }
}