import Foundation

class TwinStorage {
    static let shared = TwinStorage()
    private let userDefaults = UserDefaults.standard
    private let twinKey = "userDigitalTwin"
    
    private init() {}
    
    struct StoredTwin: Codable {
        let id: UUID
        let communicationStyle: String
        let interests: [String]
        let personalityTraits: [String]
        let conversationPatterns: [String]
        let createdAt: Date
        let lastUpdated: Date
        
        // Personality scores for matching algorithm
        let formalityScore: Float
        let analyticalScore: Float
        let verbosityScore: Float
        let questionFrequency: Float
    }
    
    func saveTwin(_ twin: StoredTwin) {
        if let encoded = try? JSONEncoder().encode(twin) {
            userDefaults.set(encoded, forKey: twinKey)
        }
    }
    
    func loadTwin() -> StoredTwin? {
        guard let data = userDefaults.data(forKey: twinKey),
              let twin = try? JSONDecoder().decode(StoredTwin.self, from: data) else {
            return nil
        }
        return twin
    }
    
    func deleteTwin() {
        userDefaults.removeObject(forKey: twinKey)
    }
    
    func hasExistingTwin() -> Bool {
        return loadTwin() != nil
    }
    
    // Convert parser output to stored format
    static func createStoredTwin(from traits: ChatGPTParser.PersonaTraits) -> StoredTwin {
        return StoredTwin(
            id: UUID(),
            communicationStyle: traits.communicationStyle.description,
            interests: traits.interests,
            personalityTraits: traits.personalityTraits,
            conversationPatterns: traits.conversationPatterns,
            createdAt: Date(),
            lastUpdated: Date(),
            formalityScore: traits.communicationStyle.formality,
            analyticalScore: traits.communicationStyle.analyticalScore,
            verbosityScore: traits.communicationStyle.verbosity,
            questionFrequency: traits.communicationStyle.questionFrequency
        )
    }
}

// MARK: - Twin Matching Algorithm
extension TwinStorage {
    
    struct CompatibilityScore {
        let score: Float // 0-100
        let strengths: [String]
        let complementaryTraits: [String]
    }
    
    static func calculateCompatibility(twin1: StoredTwin, twin2: StoredTwin) -> CompatibilityScore {
        // Complementary matching: opposites in some areas, similar in others
        
        // Similar interests boost score
        let sharedInterests = Set(twin1.interests).intersection(Set(twin2.interests))
        let interestScore = Float(sharedInterests.count) / Float(max(twin1.interests.count, 1)) * 30
        
        // Complementary communication styles can work well
        let formalityDiff = abs(twin1.formalityScore - twin2.formalityScore)
        let formalityScore = (formalityDiff > 0.3 && formalityDiff < 0.7) ? 20 : 10
        
        // Similar analytical levels help understanding
        let analyticalDiff = abs(twin1.analyticalScore - twin2.analyticalScore)
        let analyticalScore = analyticalDiff < 0.3 ? 20 : 10
        
        // Question frequency balance (one asks, one answers)
        let questionBalance = abs(twin1.questionFrequency - twin2.questionFrequency)
        let questionScore = (questionBalance > 0.3 && questionBalance < 0.7) ? 20 : 10
        
        // Complementary verbosity (one concise, one detailed)
        let verbosityDiff = abs(twin1.verbosityScore - twin2.verbosityScore)
        let verbosityScore = (verbosityDiff > 0.3) ? 10 : 5
        
        let totalScore = interestScore + Float(formalityScore + analyticalScore + questionScore + verbosityScore)
        
        var strengths: [String] = []
        if sharedInterests.count > 0 {
            strengths.append("Shared interests: \(sharedInterests.joined(separator: ", "))")
        }
        if formalityDiff > 0.3 {
            strengths.append("Balanced communication styles")
        }
        
        var complementary: [String] = []
        if questionBalance > 0.3 {
            complementary.append("Natural conversation flow")
        }
        if verbosityDiff > 0.3 {
            complementary.append("Complementary detail levels")
        }
        
        return CompatibilityScore(
            score: min(totalScore, 100),
            strengths: strengths,
            complementaryTraits: complementary
        )
    }
}