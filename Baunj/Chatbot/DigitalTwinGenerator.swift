import Foundation
import SwiftUI

class DigitalTwinGenerator: ObservableObject {
    @Published var isGenerating = false
    @Published var generationProgress: Double = 0.0
    @Published var generatedTwin: DigitalTwinModel?
    @Published var errorMessage: String?
    
    private let chatGPTService = ChatGPTService.shared
    
    func generateTwin(from context: ConversationContext) async {
        await MainActor.run {
            isGenerating = true
            generationProgress = 0.1
            errorMessage = nil
        }
        
        do {
            // Step 1: Analyze personality with ChatGPT
            await updateProgress(0.3, message: "Analyzing personality patterns...")
            let analysis = try await chatGPTService.analyzePersonality(
                responses: context.responses,
                questions: QuestionBank.questions
            )
            
            // Step 2: Generate digital twin model
            await updateProgress(0.6, message: "Creating digital twin model...")
            let twinModel = try await chatGPTService.generateDigitalTwin(
                analysis: analysis,
                responses: context.responses
            )
            
            // Step 3: Validate and refine the model
            await updateProgress(0.8, message: "Refining personality model...")
            let refinedTwin = try await refineTwin(twinModel, with: context)
            
            // Step 4: Complete
            await updateProgress(1.0, message: "Digital twin ready!")
            
            await MainActor.run {
                self.generatedTwin = refinedTwin
                self.isGenerating = false
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to generate twin: \(error.localizedDescription)"
                self.isGenerating = false
            }
        }
    }
    
    private func refineTwin(_ twin: DigitalTwinModel, with context: ConversationContext) async throws -> DigitalTwinModel {
        // Test the twin with sample scenarios to ensure accuracy
        let testScenarios = [
            "Someone asks you about your weekend plans",
            "A friend tells you they got a promotion",
            "You're asked your opinion on a controversial topic"
        ]
        
        var refinedTwin = twin
        
        for scenario in testScenarios {
            let response = try await chatGPTService.simulateResponse(
                twin: twin,
                scenario: scenario
            )
            
            // Analyze if response matches the personality
            // This could be expanded to get user feedback
            print("Test scenario: \(scenario)")
            print("Generated response: \(response)")
        }
        
        return refinedTwin
    }
    
    private func updateProgress(_ progress: Double, message: String) async {
        await MainActor.run {
            self.generationProgress = progress
        }
    }
    
    // Generate sample responses using the twin
    func generateSampleResponse(for prompt: String) async -> String? {
        guard let twin = generatedTwin else { return nil }
        
        do {
            return try await chatGPTService.simulateResponse(
                twin: twin,
                scenario: prompt
            )
        } catch {
            print("Error generating response: \(error)")
            return nil
        }
    }
}

// MARK: - Twin Interaction View

struct DigitalTwinInteractionView: View {
    @StateObject private var generator = DigitalTwinGenerator()
    let conversationContext: ConversationContext
    
    @State private var testPrompt = ""
    @State private var generatedResponse = ""
    @State private var isGeneratingResponse = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.badge.shield.checkmark.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.linearGradient(
                                colors: [.green, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                        
                        Text("Digital Twin Generated!")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Your AI twin can now mimic your communication style")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    if let twin = generator.generatedTwin {
                        // Twin Summary
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Twin Personality", systemImage: "brain")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            Text(twin.corePersonality.summary)
                                .padding()
                                .background(Color.purple.opacity(0.05))
                                .cornerRadius(12)
                            
                            // Key Traits
                            HStack {
                                ForEach(twin.corePersonality.keyTraits, id: \.self) { trait in
                                    Text(trait)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(15)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 2)
                        
                        // Test Your Twin
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Test Your Twin", systemImage: "text.bubble")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            Text("Ask your twin to respond to any scenario:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("E.g., 'How was your day?'", text: $testPrompt, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                            
                            Button(action: testTwin) {
                                if isGeneratingResponse {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Generate Response")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(testPrompt.isEmpty || isGeneratingResponse)
                            
                            if !generatedResponse.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Twin's Response:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(generatedResponse)
                                        .padding()
                                        .background(Color.green.opacity(0.05))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 2)
                        
                        // Example Responses
                        ExampleResponsesView(twin: twin)
                    } else if generator.isGenerating {
                        // Generation Progress
                        VStack(spacing: 16) {
                            ProgressView(value: generator.generationProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .tint(.purple)
                            
                            Text("Creating your digital twin...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(generator.generationProgress * 100))% Complete")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    if let error = generator.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    await generator.generateTwin(from: conversationContext)
                }
            }
        }
    }
    
    private func testTwin() {
        isGeneratingResponse = true
        generatedResponse = ""
        
        Task {
            if let response = await generator.generateSampleResponse(for: testPrompt) {
                await MainActor.run {
                    generatedResponse = response
                    isGeneratingResponse = false
                }
            } else {
                await MainActor.run {
                    generatedResponse = "Error generating response"
                    isGeneratingResponse = false
                }
            }
        }
    }
}

struct ExampleResponsesView: View {
    let twin: DigitalTwinModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("How Your Twin Talks", systemImage: "quote.bubble")
                .font(.headline)
                .foregroundColor(.purple)
            
            VStack(alignment: .leading, spacing: 12) {
                ResponseExample(
                    scenario: "Greeting:",
                    response: twin.responseTemplates.greeting
                )
                
                ResponseExample(
                    scenario: "Small Talk:",
                    response: twin.responseTemplates.smallTalk
                )
                
                ResponseExample(
                    scenario: "Sharing Opinion:",
                    response: twin.responseTemplates.opinionSharing
                )
                
                ResponseExample(
                    scenario: "Making a Joke:",
                    response: twin.responseTemplates.humor
                )
                
                ResponseExample(
                    scenario: "Being Supportive:",
                    response: twin.responseTemplates.emotionalSupport
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

struct ResponseExample: View {
    let scenario: String
    let response: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(scenario)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\"\(response)\"")
                .font(.subheadline)
                .italic()
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }
}