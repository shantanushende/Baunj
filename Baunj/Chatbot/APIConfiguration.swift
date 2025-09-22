import Foundation
import SwiftUI

struct APIConfiguration {
    static let shared = APIConfiguration()
    
    private let keychainService = "com.baunj.openai"
    private let apiKeyKey = "OpenAIAPIKey"
    
    private init() {}
    
    // MARK: - API Key Management
    
    func getAPIKey() -> String? {
        // First check environment variable (for development)
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        
        // Then check Keychain (for production)
        return getKeyFromKeychain()
    }
    
    func saveAPIKey(_ apiKey: String) -> Bool {
        return saveToKeychain(apiKey)
    }
    
    func hasValidAPIKey() -> Bool {
        guard let key = getAPIKey(), !key.isEmpty else { return false }
        return key.starts(with: "sk-") && key.count > 20
    }
    
    // MARK: - Keychain Operations
    
    private func saveToKeychain(_ apiKey: String) -> Bool {
        let data = apiKey.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: apiKeyKey,
            kSecValueData as String: data
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add the new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private func getKeyFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: apiKeyKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess,
           let data = dataTypeRef as? Data,
           let apiKey = String(data: data, encoding: .utf8) {
            return apiKey
        }
        
        return nil
    }
}

// MARK: - API Key Setup View

struct APIKeySetupView: View {
    @State private var apiKey = ""
    @State private var isKeyValid = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.linearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    
                    Text("OpenAI API Key Required")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("To analyze your responses and create your digital twin, we need access to ChatGPT")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                // Instructions
                VStack(alignment: .leading, spacing: 12) {
                    Label("How to get your API key:", systemImage: "info.circle")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        InstructionRow(number: "1", text: "Go to platform.openai.com")
                        InstructionRow(number: "2", text: "Sign in or create an account")
                        InstructionRow(number: "3", text: "Navigate to API keys section")
                        InstructionRow(number: "4", text: "Create a new secret key")
                        InstructionRow(number: "5", text: "Copy and paste it below")
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(12)
                
                // API Key Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    SecureField("sk-...", text: $apiKey)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: apiKey) { newValue in
                            validateKey(newValue)
                        }
                    
                    if isKeyValid {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Valid API key format")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                // Save Button
                Button(action: saveAPIKey) {
                    Text("Save API Key")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isKeyValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!isKeyValid)
                .padding(.horizontal)
                
                // Privacy Note
                Text("Your API key is stored securely in your device's Keychain and never shared")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        dismiss()
                    }
                }
            }
            .alert("API Key Status", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func validateKey(_ key: String) {
        isKeyValid = key.starts(with: "sk-") && key.count > 20
    }
    
    private func saveAPIKey() {
        if APIConfiguration.shared.saveAPIKey(apiKey) {
            alertMessage = "API key saved successfully!"
            showingAlert = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } else {
            alertMessage = "Failed to save API key. Please try again."
            showingAlert = true
        }
    }
}

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(Color.blue))
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// MARK: - API Key Check Modifier

struct APIKeyCheckModifier: ViewModifier {
    @State private var showingAPIKeySetup = false
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if !APIConfiguration.shared.hasValidAPIKey() {
                    showingAPIKeySetup = true
                }
            }
            .sheet(isPresented: $showingAPIKeySetup) {
                APIKeySetupView()
            }
    }
}

extension View {
    func checkAPIKey() -> some View {
        modifier(APIKeyCheckModifier())
    }
}