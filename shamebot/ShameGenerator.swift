//
//  ShameGenerator.swift
//  shamebot
//
//  Created by Michael Head on 4/1/25.
//

import Foundation
import Combine

class ShameGenerator: ObservableObject {
    @Published var shameMessage: String = "SHAME!"
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private let apiKey: String = "" // You need to set your OpenAI API key here
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    func generateShameMessage() {
        // Use default message if API key is not provided
        guard !apiKey.isEmpty else {
            self.shameMessage = "SHAME! (Add API key for custom messages)"
            return
        }
        
        self.isLoading = true
        self.error = nil
        
        let prompt = """
        Generate a brief, humorous message (max 100 characters) that playfully shames someone for checking Instagram instead of being productive. Keep it light-hearted and motivational rather than harsh. Don't include quotation marks in your response.
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant that generates short, humorous, light-hearted shame messages for people checking social media."],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 60,
            "temperature": 0.7
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            self.isLoading = false
            self.error = "Failed to prepare request"
            return
        }
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.error = "No data received"
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        
                        let trimmedMessage = content.trimmingCharacters(in: .whitespacesAndNewlines)
                        self?.shameMessage = trimmedMessage
                    } else {
                        self?.error = "Failed to parse response"
                    }
                } catch {
                    self?.error = "JSON parsing error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    // Get a local fallback message if API call fails
    func getFallbackMessage() -> String {
        let fallbackMessages = [
            "SHAME! Put down that phone!",
            "Instagram can wait. Your goals can't.",
            "Is scrolling really worth your precious time?",
            "Plot twist: Instagram still exists tomorrow.",
            "Your future self would rather you didn't."
        ]
        
        return fallbackMessages.randomElement() ?? "SHAME!"
    }
}