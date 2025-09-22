import Foundation

struct QuestionBank {
    // Reduced to 3 questions for testing - change back to allQuestions for full 10
    static let questions: [PersonalityQuestion] = Array(allQuestions.prefix(3))
    
    static let allQuestions: [PersonalityQuestion] = [
        
        // Layer 1: Baseline Communication (Icebreakers)
        PersonalityQuestion(
            id: 1,
            category: .icebreaker,
            prompt: "So tell me, what's been making you laugh lately? Could be anything - a show, something that happened, whatever",
            subPrompt: nil,
            followUps: [
                "show": "Oh nice! What kind of humor does it have?",
                "friend": "Your friends sound fun! Are you usually the one making jokes or laughing at them?",
                "work": "Finding humor at work is a skill! Are you the office comedian?",
                "nothing": "One of those weeks huh? What usually cracks you up when nothing else does?"
            ],
            analysisWeights: [
                .humor: 0.8,
                .emotionalExpression: 0.5,
                .openness: 0.6
            ],
            responsePatterns: [
                "haha": PersonalityMarker(dimension: .humor, weight: 0.7, indicator: "expressive_laughter"),
                "lol": PersonalityMarker(dimension: .humor, weight: 0.5, indicator: "casual_laughter"),
                "honestly": PersonalityMarker(dimension: .openness, weight: 0.6, indicator: "authentic_sharing")
            ]
        ),
        
        PersonalityQuestion(
            id: 2,
            category: .icebreaker,
            prompt: "What's been on your mind lately? Like, what keeps popping into your head when you have a quiet moment?",
            subPrompt: nil,
            followUps: [
                "future": "Planning ahead or just daydreaming?",
                "stress": "That sounds heavy. How do you usually deal with stuff like this?",
                "excited": "That's awesome! Are you someone who plans everything out or just wings it?",
                "money": "Ah the universal concern. Are you a saver or more of a 'life is short' type?"
            ],
            analysisWeights: [
                .analyticalThinking: 0.7,
                .optimism: 0.6,
                .openness: 0.5
            ],
            responsePatterns: [
                "worried": PersonalityMarker(dimension: .optimism, weight: -0.5, indicator: "anxiety_expression"),
                "excited": PersonalityMarker(dimension: .optimism, weight: 0.8, indicator: "enthusiasm"),
                "thinking": PersonalityMarker(dimension: .analyticalThinking, weight: 0.7, indicator: "contemplative")
            ]
        ),
        
        // Layer 2: Situational Responses
        PersonalityQuestion(
            id: 3,
            category: .situational,
            prompt: "Okay, scenario time: Your best friend just told you they got their dream job, but it means they're moving across the country. What's the first thing that comes out of your mouth?",
            subPrompt: nil,
            followUps: [
                "happy": "That's sweet! Are you usually the supportive friend even when it's hard?",
                "sad": "Honest reaction! Do you usually wear your heart on your sleeve?",
                "joke": "Humor as a coping mechanism or just your natural response?",
                "practical": "The logical friend! Is that your role in the group?"
            ],
            analysisWeights: [
                .empathy: 0.9,
                .emotionalExpression: 0.7,
                .assertiveness: 0.4
            ],
            responsePatterns: [
                "congrat": PersonalityMarker(dimension: .empathy, weight: 0.8, indicator: "other_focused"),
                "miss": PersonalityMarker(dimension: .emotionalExpression, weight: 0.8, indicator: "vulnerable"),
                "visit": PersonalityMarker(dimension: .optimism, weight: 0.6, indicator: "solution_oriented")
            ]
        ),
        
        PersonalityQuestion(
            id: 4,
            category: .situational,
            prompt: "Someone cuts you off in traffic, then gives you the apologetic wave. Your internal monologue is saying...?",
            subPrompt: nil,
            followUps: [
                "angry": "Fair! Does it take you a while to cool down or are you over it quickly?",
                "fine": "The zen master! Natural temperament or years of practice?",
                "depends": "What makes the difference for you?",
                "wave": "Killing them with kindness! Is that your usual approach?"
            ],
            analysisWeights: [
                .conflictStyle: 0.8,
                .assertiveness: 0.6,
                .emotionalExpression: 0.5
            ],
            responsePatterns: [
                "whatever": PersonalityMarker(dimension: .conflictStyle, weight: 0.3, indicator: "avoidant"),
                "asshole": PersonalityMarker(dimension: .assertiveness, weight: 0.7, indicator: "direct"),
                "happens": PersonalityMarker(dimension: .empathy, weight: 0.7, indicator: "understanding")
            ]
        ),
        
        // Layer 3: Humor & Creativity
        PersonalityQuestion(
            id: 5,
            category: .humor,
            prompt: "Complete this: The most ridiculous thing about modern life is...",
            subPrompt: nil,
            followUps: [
                "phone": "The classic! Are you good at unplugging or totally addicted?",
                "social": "The social media paradox! Are you a poster or a lurker?",
                "work": "The grind culture got you? What's your ideal work-life balance?",
                "dating": "The apps are wild! Got any horror stories or success stories?"
            ],
            analysisWeights: [
                .humor: 0.7,
                .analyticalThinking: 0.6,
                .openness: 0.5
            ],
            responsePatterns: [
                "literally": PersonalityMarker(dimension: .humor, weight: 0.4, indicator: "emphatic"),
                "stupid": PersonalityMarker(dimension: .assertiveness, weight: 0.6, indicator: "blunt"),
                "funny": PersonalityMarker(dimension: .humor, weight: 0.7, indicator: "observational")
            ]
        ),
        
        PersonalityQuestion(
            id: 6,
            category: .humor,
            prompt: "Would you rather fight 100 duck-sized horses or 1 horse-sized duck? And please, I need your battle strategy here",
            subPrompt: nil,
            followUps: [
                "duck": "Bold choice! Are you usually a 'go big or go home' person?",
                "horses": "Playing the odds! Are you typically the strategic planner?",
                "neither": "The pacifist! But seriously, if you HAD to choose?",
                "weapon": "Already thinking tactics! Do you approach most problems this analytically?"
            ],
            analysisWeights: [
                .humor: 0.8,
                .spontaneity: 0.6,
                .analyticalThinking: 0.5
            ],
            responsePatterns: [
                "obviously": PersonalityMarker(dimension: .assertiveness, weight: 0.6, indicator: "confident"),
                "terrifying": PersonalityMarker(dimension: .humor, weight: 0.6, indicator: "dramatic"),
                "strategy": PersonalityMarker(dimension: .analyticalThinking, weight: 0.8, indicator: "methodical")
            ]
        ),
        
        // Layer 4: Values & Philosophy
        PersonalityQuestion(
            id: 7,
            category: .philosophical,
            prompt: "If you could change one unwritten social rule that everyone just accepts, what would it be?",
            subPrompt: nil,
            followUps: [
                "small talk": "The introvert's dream! What would you replace it with?",
                "emotion": "Breaking down walls! Are you pretty open with your feelings?",
                "success": "Redefining the game! What does success mean to you?",
                "polite": "Keeping it real! Are you usually the most honest person in the room?"
            ],
            analysisWeights: [
                .openness: 0.8,
                .analyticalThinking: 0.7,
                .assertiveness: 0.5
            ],
            responsePatterns: [
                "should": PersonalityMarker(dimension: .assertiveness, weight: 0.7, indicator: "prescriptive"),
                "weird": PersonalityMarker(dimension: .openness, weight: 0.6, indicator: "questioning_norms"),
                "society": PersonalityMarker(dimension: .analyticalThinking, weight: 0.7, indicator: "systemic_thinking")
            ]
        ),
        
        PersonalityQuestion(
            id: 8,
            category: .philosophical,
            prompt: "What's something you believe that most people would disagree with? Don't worry, this is a judgment-free zone",
            subPrompt: nil,
            followUps: [
                "actually": "Interesting perspective! How did you come to that conclusion?",
                "unpopular": "Brave of you to say! Do you usually go against the grain?",
                "think": "I can see that! Are you often the devil's advocate in discussions?",
                "probably": "Playing it safe or genuinely moderate views?"
            ],
            analysisWeights: [
                .openness: 0.9,
                .assertiveness: 0.7,
                .analyticalThinking: 0.6
            ],
            responsePatterns: [
                "everyone": PersonalityMarker(dimension: .assertiveness, weight: 0.5, indicator: "generalizing"),
                "personally": PersonalityMarker(dimension: .openness, weight: 0.7, indicator: "personal_stance"),
                "evidence": PersonalityMarker(dimension: .analyticalThinking, weight: 0.8, indicator: "fact_based")
            ]
        ),
        
        // Layer 5: Small Talk & Daily Life
        PersonalityQuestion(
            id: 9,
            category: .smallTalk,
            prompt: "Someone asks 'How was your weekend?' but they actually want to know. What's your real answer?",
            subPrompt: nil,
            followUps: [
                "nothing": "The art of doing nothing! Is that rare for you?",
                "busy": "The hustler! Do you ever actually relax?",
                "friends": "Social butterfly! Are you the planner or do you just show up?",
                "netflix": "The homebody! What's your latest obsession?"
            ],
            analysisWeights: [
                .socialEnergy: 0.8,
                .spontaneity: 0.5,
                .openness: 0.6
            ],
            responsePatterns: [
                "honestly": PersonalityMarker(dimension: .openness, weight: 0.8, indicator: "authentic"),
                "actually": PersonalityMarker(dimension: .assertiveness, weight: 0.5, indicator: "elaborating"),
                "just": PersonalityMarker(dimension: .detailOrientation, weight: -0.5, indicator: "minimizing")
            ]
        ),
        
        // Layer 6: Emotional Intelligence
        PersonalityQuestion(
            id: 10,
            category: .emotional,
            prompt: "Your friend is venting about the same problem for the 10th time. What's going through your head vs what you actually say?",
            subPrompt: nil,
            followUps: [
                "listen": "The patient saint! Does this come naturally or is it effort?",
                "advice": "The fixer! Do people come to you for solutions often?",
                "frustrated": "The honest reaction! How do you handle repetitive situations?",
                "relate": "The empathizer! Are you usually the one people confide in?"
            ],
            analysisWeights: [
                .empathy: 0.9,
                .emotionalExpression: 0.6,
                .assertiveness: 0.5
            ],
            responsePatterns: [
                "again": PersonalityMarker(dimension: .empathy, weight: -0.3, indicator: "frustrated"),
                "understand": PersonalityMarker(dimension: .empathy, weight: 0.8, indicator: "supportive"),
                "but": PersonalityMarker(dimension: .assertiveness, weight: 0.6, indicator: "redirecting")
            ]
        )
    ]
    
    static func getQuestion(by id: Int) -> PersonalityQuestion? {
        return questions.first { $0.id == id }
    }
    
    static func getQuestionsByCategory(_ category: QuestionCategory) -> [PersonalityQuestion] {
        return questions.filter { $0.category == category }
    }
    
    static func getFollowUpQuestion(for response: String, from question: PersonalityQuestion) -> String? {
        let lowercasedResponse = response.lowercased()
        
        for (keyword, followUp) in question.followUps {
            if lowercasedResponse.contains(keyword) {
                return followUp
            }
        }
        
        return nil
    }
}