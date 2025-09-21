import SwiftUI
import UniformTypeIdentifiers

struct TwinCreationView: View {
    @State private var uploadedFiles: [URL] = []
    @State private var isImporting = false
    @State private var analysisProgress: Double = 0
    @State private var twinProfile: TwinProfile?
    @State private var showingAnalysis = false
    @State private var showingChatbot = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                VStack(spacing: 12) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.linearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    
                    Text("Create Your Digital Twin")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Choose how to build your AI persona")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                VStack(spacing: 16) {
                    Button(action: { showingChatbot = true }) {
                        Label("Chat with AI Assistant", systemImage: "message.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Text("or")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    
                    Button(action: { isImporting = true }) {
                        Label("Upload ChatGPT Conversations", systemImage: "doc.badge.plus")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    // TEST MODE - Remove this in production
                    Button(action: { 
                        // Add fake test files
                        uploadedFiles = [
                            URL(string: "file:///test/conversation1.html")!,
                            URL(string: "file:///test/conversation2.html")!,
                            URL(string: "file:///test/conversation3.html")!
                        ]
                    }) {
                        Label("Add Test Files (Dev Mode)", systemImage: "hammer.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    if !uploadedFiles.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Uploaded Files (\(uploadedFiles.count))")
                                .font(.headline)
                            
                            ForEach(uploadedFiles, id: \.self) { file in
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                        .foregroundColor(.blue)
                                    Text(file.lastPathComponent)
                                        .font(.caption)
                                    Spacer()
                                    Button(action: {
                                        uploadedFiles.removeAll { $0 == file }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    if showingAnalysis {
                        VStack {
                            ProgressView(value: analysisProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                            Text("Analyzing your conversation patterns...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                    
                    if !uploadedFiles.isEmpty && !showingAnalysis {
                        Button(action: analyzeTwin) {
                            Label("Generate Twin", systemImage: "sparkles")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                if let twin = twinProfile {
                    NavigationLink(destination: TwinProfileView(profile: twin)) {
                        HStack {
                            Text("View Your Digital Twin")
                            Image(systemName: "arrow.right")
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.html],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let files):
                    uploadedFiles.append(contentsOf: files)
                case .failure(let error):
                    print("Error selecting files: \(error)")
                }
            }
            .fullScreenCover(isPresented: $showingChatbot) {
                ChatbotView()
            }
        }
    }
    
    func analyzeTwin() {
        showingAnalysis = true
        analysisProgress = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            analysisProgress += 0.05
            if analysisProgress >= 1.0 {
                timer.invalidate()
                showingAnalysis = false
                twinProfile = TwinProfile.mock
            }
        }
    }
}

struct TwinProfile {
    let id: UUID
    let communicationStyle: String
    let interests: [String]
    let personalityTraits: [String]
    let conversationPatterns: [String]
    let createdAt: Date
    
    static let mock = TwinProfile(
        id: UUID(),
        communicationStyle: "Analytical & Curious",
        interests: ["Technology", "Philosophy", "Startups", "AI"],
        personalityTraits: ["Innovative", "Direct", "Thoughtful"],
        conversationPatterns: ["Asks clarifying questions", "Uses analogies", "Solution-oriented"],
        createdAt: Date()
    )
}

#Preview {
    TwinCreationView()
}