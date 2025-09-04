import SwiftUI

struct TwinProfileView: View {
    let profile: TwinProfile
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Image(systemName: "brain.head.profile.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.linearGradient(
                            colors: [.purple, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    
                    Text("Your Digital Twin")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding(.top)
                
                VStack(alignment: .leading, spacing: 16) {
                    ProfileSection(
                        title: "Communication Style",
                        icon: "text.bubble.fill",
                        content: profile.communicationStyle
                    )
                    
                    ProfileSection(
                        title: "Interests",
                        icon: "star.fill",
                        items: profile.interests
                    )
                    
                    ProfileSection(
                        title: "Personality Traits",
                        icon: "person.fill",
                        items: profile.personalityTraits
                    )
                    
                    ProfileSection(
                        title: "Conversation Patterns",
                        icon: "message.fill",
                        items: profile.conversationPatterns
                    )
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileSection: View {
    let title: String
    let icon: String
    var content: String? = nil
    var items: [String]? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.purple)
                Text(title)
                    .font(.headline)
            }
            
            if let content = content {
                Text(content)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
            }
            
            if let items = items {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(items, id: \.self) { item in
                        HStack {
                            Circle()
                                .fill(Color.purple.opacity(0.5))
                                .frame(width: 6, height: 6)
                            Text(item)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.purple.opacity(0.05))
                .cornerRadius(8)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TwinProfileView(profile: TwinProfile.mock)
    }
}