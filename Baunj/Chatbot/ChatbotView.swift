import SwiftUI
import Combine

struct ChatbotView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var conversationManager = ConversationManager()
    @State private var userInput = ""
    @State private var showingProfile = false
    @State private var generatedProfile: PersonalityProfile?
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Bar
                if !conversationManager.isComplete {
                    ProgressView(value: conversationManager.progress)
                        .tint(.purple)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    Text("\(Int(conversationManager.progress * 100))% Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                }
                
                // Chat Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(conversationManager.conversationHistory) { message in
                                ChatBubbleView(message: message)
                                    .id(message.id)
                            }
                            
                            if conversationManager.isTyping {
                                TypingIndicatorView()
                                    .id("typing")
                            }
                        }
                        .padding()
                    }
                    .onChange(of: conversationManager.conversationHistory.count) { _ in
                        withAnimation {
                            proxy.scrollTo(conversationManager.conversationHistory.last?.id, anchor: .bottom)
                        }
                    }
                    .onChange(of: conversationManager.isTyping) { typing in
                        if typing {
                            withAnimation {
                                proxy.scrollTo("typing", anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Suggestion Chips
                if !conversationManager.getResponseSuggestions().isEmpty && !conversationManager.isComplete {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(conversationManager.getResponseSuggestions(), id: \.self) { suggestion in
                                Button(action: {
                                    userInput = suggestion
                                    sendMessage()
                                }) {
                                    Text(suggestion)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.purple.opacity(0.1))
                                        .foregroundColor(.purple)
                                        .cornerRadius(15)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
                
                // Input Field
                if !conversationManager.isComplete {
                    HStack(spacing: 12) {
                        TextField("Type your response...", text: $userInput, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .focused($isInputFocused)
                            .onSubmit {
                                sendMessage()
                            }
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(userInput.isEmpty ? .gray : .purple)
                        }
                        .disabled(userInput.isEmpty)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .shadow(radius: 1)
                } else {
                    // Completion View
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        
                        Text("Profile Complete!")
                            .font(.headline)
                        
                        Button("View Your Digital Twin") {
                            if let profile = generatedProfile {
                                // Navigate to profile view
                                showingProfile = true
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Personality Chat")
                        .font(.headline)
                }
            }
            .onAppear {
                isInputFocused = false
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("PersonalityProfileGenerated"))) { notification in
                if let profile = notification.userInfo?["profile"] as? PersonalityProfile {
                    generatedProfile = profile
                }
            }
            .sheet(isPresented: $showingProfile) {
                if let profile = generatedProfile {
                    PersonalityProfileView(profile: profile)
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        conversationManager.sendUserResponse(userInput)
        userInput = ""
        isInputFocused = false
    }
}

struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if !message.isBot { Spacer(minLength: 60) }
            
            VStack(alignment: message.isBot ? .leading : .trailing, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(message.isBot ? Color.gray.opacity(0.2) : Color.purple.opacity(0.8))
                    .foregroundColor(message.isBot ? .primary : .white)
                    .cornerRadius(16)
                    .font(message.isSubPrompt ? .caption : .body)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if message.isBot { Spacer(minLength: 60) }
        }
    }
}

struct TypingIndicatorView: View {
    @State private var animationAmount = 0.0
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationAmount == Double(index) ? 1.3 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animationAmount
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(16)
            
            Spacer(minLength: 60)
        }
        .onAppear {
            animationAmount = 2.0
        }
    }
}

#Preview {
    ChatbotView()
}