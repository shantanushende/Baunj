import SwiftUI

struct PersonalityProfileView: View {
    let profile: PersonalityProfile
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "brain.head.profile.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.linearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                        
                        Text("Your Digital Twin Profile")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(profile.communicationStyle.description)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Tab Selector
                    Picker("Profile Section", selection: $selectedTab) {
                        Text("Overview").tag(0)
                        Text("Communication").tag(1)
                        Text("Personality").tag(2)
                        Text("Signature").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Content based on selected tab
                    Group {
                        switch selectedTab {
                        case 0:
                            OverviewSection(profile: profile)
                        case 1:
                            CommunicationSection(profile: profile)
                        case 2:
                            PersonalitySection(profile: profile)
                        case 3:
                            SignatureSection(profile: profile)
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveProfile) {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
            }
        }
    }
    
    private func saveProfile() {
        // Convert PersonalityProfile to TwinStorage format and save
        let storedTwin = TwinStorage.StoredTwin(
            id: UUID(),
            communicationStyle: profile.communicationStyle.description,
            interests: profile.comfortTopics,
            personalityTraits: getPersonalityTraits(),
            conversationPatterns: profile.conversationStarters,
            createdAt: Date(),
            lastUpdated: Date(),
            formalityScore: profile.communicationStyle.formality,
            analyticalScore: profile.dimensions[.analyticalThinking] ?? 0.5,
            verbosityScore: profile.dimensions[.detailOrientation] ?? 0.5,
            questionFrequency: profile.dimensions[.openness] ?? 0.5
        )
        
        TwinStorage.shared.saveTwin(storedTwin)
        dismiss()
    }
    
    private func getPersonalityTraits() -> [String] {
        var traits: [String] = []
        
        if let empathy = profile.dimensions[.empathy], empathy > 0.6 {
            traits.append("Empathetic")
        }
        if let humor = profile.dimensions[.humor], humor > 0.6 {
            traits.append("Humorous")
        }
        if let analytical = profile.dimensions[.analyticalThinking], analytical > 0.6 {
            traits.append("Analytical")
        }
        if let assertive = profile.dimensions[.assertiveness], assertive > 0.6 {
            traits.append("Assertive")
        }
        if let spontaneous = profile.dimensions[.spontaneity], spontaneous > 0.6 {
            traits.append("Spontaneous")
        }
        
        return traits
    }
}

struct OverviewSection: View {
    let profile: PersonalityProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Key Dimensions
            VStack(alignment: .leading, spacing: 12) {
                Label("Key Traits", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                ForEach(Array(profile.dimensions.sorted(by: { $0.value > $1.value }).prefix(5)), id: \.key) { dimension, value in
                    HStack {
                        Text(dimensionName(dimension))
                            .font(.subheadline)
                        Spacer()
                        ProgressView(value: Double(value))
                            .frame(width: 100)
                            .tint(colorForValue(value))
                        Text("\(Int(value * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.purple.opacity(0.05))
            .cornerRadius(12)
            
            // Social Style
            VStack(alignment: .leading, spacing: 8) {
                Label("Social Style", systemImage: "person.2.fill")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                Text(profile.socialStyle.energy)
                    .padding(.vertical, 4)
                Text("Prefers: \(profile.socialStyle.groupPreference)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Conversation: \(profile.socialStyle.initiationStyle)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    private func dimensionName(_ dimension: PersonalityDimension) -> String {
        switch dimension {
        case .formality: return "Formality"
        case .emotionalExpression: return "Emotional Expression"
        case .humor: return "Humor"
        case .analyticalThinking: return "Analytical Thinking"
        case .empathy: return "Empathy"
        case .assertiveness: return "Assertiveness"
        case .openness: return "Openness"
        case .optimism: return "Optimism"
        case .detailOrientation: return "Detail Oriented"
        case .spontaneity: return "Spontaneity"
        case .conflictStyle: return "Conflict Management"
        case .socialEnergy: return "Social Energy"
        }
    }
    
    private func colorForValue(_ value: Float) -> Color {
        if value > 0.7 { return .green }
        if value > 0.4 { return .blue }
        return .orange
    }
}

struct CommunicationSection: View {
    let profile: PersonalityProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Communication Style
            VStack(alignment: .leading, spacing: 12) {
                Label("Communication Style", systemImage: "bubble.left.and.bubble.right.fill")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                DetailRow(label: "Pace", value: profile.communicationStyle.pace)
                DetailRow(label: "Detail Level", value: profile.communicationStyle.detail)
                DetailRow(label: "Warmth", value: "\(Int(profile.communicationStyle.warmth * 100))%")
                DetailRow(label: "Directness", value: "\(Int(profile.communicationStyle.directness * 100))%")
            }
            .padding()
            .background(Color.purple.opacity(0.05))
            .cornerRadius(12)
            
            // Humor Style
            VStack(alignment: .leading, spacing: 12) {
                Label("Humor Style", systemImage: "face.smiling")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                Text(humorTypeName(profile.humorStyle.primaryType))
                    .font(.subheadline)
                
                if !profile.humorStyle.examples.isEmpty {
                    Text("Examples:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ForEach(profile.humorStyle.examples, id: \.self) { example in
                        Text("• \(example)")
                            .font(.caption)
                            .padding(.leading)
                    }
                }
            }
            .padding()
            .background(Color.orange.opacity(0.05))
            .cornerRadius(12)
            
            // Typical Responses
            VStack(alignment: .leading, spacing: 12) {
                Label("Typical Responses", systemImage: "text.bubble")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                ForEach(Array(profile.typicalResponses), id: \.key) { scenario, response in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(scenario.capitalized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\"\(response)\"")
                            .font(.subheadline)
                            .italic()
                    }
                }
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    private func humorTypeName(_ type: HumorStyle.HumorType) -> String {
        switch type {
        case .dry: return "Dry Humor"
        case .silly: return "Silly & Playful"
        case .sarcastic: return "Sarcastic"
        case .witty: return "Witty & Clever"
        case .observational: return "Observational"
        case .selfdeprecating: return "Self-Deprecating"
        case .none: return "Minimal Humor"
        }
    }
}

struct PersonalitySection: View {
    let profile: PersonalityProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Thinking Style
            VStack(alignment: .leading, spacing: 12) {
                Label("Thinking Style", systemImage: "brain")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                DetailRow(label: "Approach", value: profile.thinkingStyle.approach)
                DetailRow(label: "Processing", value: profile.thinkingStyle.processing)
                DetailRow(label: "Focus", value: profile.thinkingStyle.focus)
            }
            .padding()
            .background(Color.purple.opacity(0.05))
            .cornerRadius(12)
            
            // Emotional Style
            VStack(alignment: .leading, spacing: 12) {
                Label("Emotional Style", systemImage: "heart.fill")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                DetailRow(label: "Expression", value: profile.emotionalStyle.expression)
                DetailRow(label: "Regulation", value: profile.emotionalStyle.regulation)
                DetailRow(label: "Empathy Level", value: "\(Int(profile.emotionalStyle.empathyLevel * 100))%")
            }
            .padding()
            .background(Color.pink.opacity(0.05))
            .cornerRadius(12)
            
            // Comfort & Avoidance
            VStack(alignment: .leading, spacing: 12) {
                Label("Topics", systemImage: "list.bullet")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                if !profile.comfortTopics.isEmpty {
                    Text("Comfortable discussing:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ForEach(profile.comfortTopics, id: \.self) { topic in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text(topic)
                                .font(.subheadline)
                        }
                    }
                }
                
                if !profile.avoidanceTopics.isEmpty {
                    Text("Tends to avoid:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    ForEach(profile.avoidanceTopics, id: \.self) { topic in
                        HStack {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text(topic)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .padding()
            .background(Color.green.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

struct SignatureSection: View {
    let profile: PersonalityProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Unique Phrases
            if !profile.signature.uniquePhrases.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Signature Phrases", systemImage: "quote.bubble")
                        .font(.headline)
                        .foregroundColor(.purple)
                    
                    ForEach(profile.signature.uniquePhrases, id: \.self) { phrase in
                        Text("\"\(phrase)\"")
                            .font(.subheadline)
                            .italic()
                            .padding(.vertical, 2)
                    }
                }
                .padding()
                .background(Color.purple.opacity(0.05))
                .cornerRadius(12)
            }
            
            // Conversation Starters
            VStack(alignment: .leading, spacing: 12) {
                Label("Conversation Starters", systemImage: "message")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                ForEach(profile.conversationStarters, id: \.self) { starter in
                    Text("• \(starter)")
                        .font(.subheadline)
                        .padding(.vertical, 2)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(12)
            
            // Communication Patterns
            VStack(alignment: .leading, spacing: 12) {
                Label("Communication Patterns", systemImage: "arrow.left.arrow.right")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                DetailRow(label: "Greeting", value: profile.signature.greetingStyle)
                DetailRow(label: "Sign-off", value: profile.signature.signoffStyle)
                
                if !profile.signature.laughStyle.isEmpty {
                    DetailRow(label: "Laughter", value: profile.signature.laughStyle.joined(separator: ", "))
                }
                
                if !profile.signature.filler.isEmpty {
                    DetailRow(label: "Filler words", value: profile.signature.filler.joined(separator: ", "))
                }
            }
            .padding()
            .background(Color.green.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    PersonalityProfileView(profile: PersonalityProfile(
        dimensions: [
            .humor: 0.8,
            .empathy: 0.7,
            .analyticalThinking: 0.6
        ],
        communicationStyle: CommunicationStyle(
            pace: "Quick and concise",
            formality: 0.3,
            expressiveness: 0.7,
            directness: 0.8,
            warmth: 0.6,
            detail: "Gets to the point",
            examples: ["Example response"]
        ),
        humorStyle: HumorStyle(
            primaryType: .witty,
            frequency: 0.6,
            triggers: ["Casual conversation"],
            examples: ["haha that's funny"]
        ),
        socialStyle: SocialStyle(
            energy: "Extroverted",
            groupPreference: "Small groups",
            initiationStyle: "Asks questions",
            boundaryStyle: "Open",
            conflictApproach: "Direct"
        ),
        thinkingStyle: ThinkingStyle(
            approach: "Analytical",
            processing: "Quick",
            focus: "Big picture",
            examples: ["Uses logic"]
        ),
        emotionalStyle: EmotionalStyle(
            expression: "Open",
            regulation: "Balanced",
            empathyLevel: 0.7,
            vulnerabilityComfort: 0.5
        ),
        typicalResponses: [
            "greeting": "Hey!",
            "agreement": "Totally!"
        ],
        conversationStarters: ["What's new?"],
        comfortTopics: ["Technology", "Travel"],
        avoidanceTopics: ["Politics"],
        stressIndicators: ["Short responses"],
        signature: PersonalitySignature(
            uniquePhrases: ["honestly", "literally"],
            filler: ["like", "basically"],
            greetingStyle: "Hey!",
            signoffStyle: "Later!",
            laughStyle: ["haha", "lol"],
            agreementStyle: ["Totally!"],
            disagreementStyle: ["Not sure about that..."]
        )
    ))
}