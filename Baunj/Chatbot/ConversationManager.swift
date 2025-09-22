import Foundation
import Combine

class ConversationManager: ObservableObject {
    @Published var currentQuestion: PersonalityQuestion?
    @Published var currentPrompt: String = ""
    @Published var isTyping: Bool = false
    @Published var conversationHistory: [ChatMessage] = []
    @Published var progress: Double = 0.0
    @Published var isComplete: Bool = false
    
    private var context = ConversationContext()
    private let questions = QuestionBank.questions
    private var responseStartTime: Date?
    private var followUpTimer: Timer?
    
    init() {
        startConversation()
    }
    
    func startConversation() {
        conversationHistory.append(ChatMessage(
            content: "Hey! I'm going to ask you some questions to understand your personality and communication style. Just be yourself - there are no right or wrong answers. Ready?",
            isBot: true,
            timestamp: Date()
        ))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.askNextQuestion()
        }
    }
    
    func askNextQuestion() {
        guard context.currentQuestionIndex < questions.count else {
            completeConversation()
            return
        }
        
        if let followUp = context.followUpQueue.first {
            context.followUpQueue.removeFirst()
            sendBotMessage(followUp)
            return
        }
        
        let question = questions[context.currentQuestionIndex]
        currentQuestion = question
        context.currentQuestionIndex += 1
        
        updateProgress()
        
        sendBotMessage(question.prompt)
        
        if let subPrompt = question.subPrompt {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.sendBotMessage(subPrompt, isSubPrompt: true)
            }
        }
        
        responseStartTime = Date()
    }
    
    func sendUserResponse(_ response: String) {
        guard !response.isEmpty, let currentQuestion = currentQuestion else { return }
        
        let responseTime = responseStartTime.map { Date().timeIntervalSince($0) } ?? 0
        
        conversationHistory.append(ChatMessage(
            content: response,
            isBot: false,
            timestamp: Date()
        ))
        
        let analyzed = ResponseAnalyzer.analyzeResponse(response, for: currentQuestion)
        context.responses.append(analyzed)
        
        simulateThinking()
        
        if let followUp = QuestionBank.getFollowUpQuestion(for: response, from: currentQuestion) {
            context.followUpQueue.append(followUp)
        }
        
        let patterns = ResponseAnalyzer.detectPatterns(from: context.responses)
        context.detectedPatterns = patterns
        
        let tone = ResponseAnalyzer.detectEmotionalTone(from: context.responses)
        context.mood = tone
        
        if shouldAdjustTone(basedOn: tone) {
            adjustConversationTone()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.askNextQuestion()
        }
    }
    
    private func sendBotMessage(_ message: String, isSubPrompt: Bool = false) {
        isTyping = true
        
        let typingDuration = Double(message.count) * 0.02 + 0.5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + typingDuration) {
            self.conversationHistory.append(ChatMessage(
                content: message,
                isBot: true,
                timestamp: Date(),
                isSubPrompt: isSubPrompt
            ))
            self.isTyping = false
            self.currentPrompt = message
        }
    }
    
    private func simulateThinking() {
        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.isTyping = false
        }
    }
    
    private func shouldAdjustTone(basedOn tone: EmotionalTone) -> Bool {
        return tone == .anxious || tone == .contemplative
    }
    
    private func adjustConversationTone() {
        let comfortingMessages = [
            "No pressure at all! Take your time...",
            "You're doing great, by the way!",
            "These are thought-provoking, I know. No rush!"
        ]
        
        if Int.random(in: 0...2) == 0 {
            let message = comfortingMessages.randomElement() ?? ""
            sendBotMessage(message, isSubPrompt: true)
        }
    }
    
    private func updateProgress() {
        progress = Double(context.currentQuestionIndex) / Double(questions.count)
    }
    
    private func completeConversation() {
        isComplete = true
        
        sendBotMessage("That's it! Thanks for sharing - I've got a really good sense of your personality now. Let me process everything...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.generatePersonalityProfile()
        }
    }
    
    private func generatePersonalityProfile() {
        // First generate basic profile
        let synthesizer = PersonalitySynthesizer()
        let basicProfile = synthesizer.synthesize(from: context)
        
        // Then enhance with ChatGPT if API key is available
        if APIConfiguration.shared.hasValidAPIKey() {
            Task {
                let generator = DigitalTwinGenerator()
                await generator.generateTwin(from: context)
                
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: Notification.Name("DigitalTwinGenerated"),
                        object: nil,
                        userInfo: ["context": context, "basicProfile": basicProfile]
                    )
                }
            }
        } else {
            // Just use basic profile if no API key
            NotificationCenter.default.post(
                name: Notification.Name("PersonalityProfileGenerated"),
                object: nil,
                userInfo: ["profile": basicProfile]
            )
        }
    }
    
    func skipToNext() {
        askNextQuestion()
    }
    
    func getResponseSuggestions() -> [String] {
        guard let question = currentQuestion else { return [] }
        
        switch question.category {
        case .icebreaker:
            return ["Not much lately", "Actually, something funny happened...", "Let me think..."]
        case .situational:
            return ["I'd probably...", "Honestly, I'd...", "Depends on..."]
        case .humor:
            return ["Obviously the duck", "100 horses for sure", "Is running away an option?"]
        case .philosophical:
            return ["I've always thought...", "This might be controversial but...", "I believe..."]
        default:
            return []
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isBot: Bool
    let timestamp: Date
    var isSubPrompt: Bool = false
}