//
//  DeepSeek.swift
//  LangSwift
//
//  Created by ke Liu on 1/3/26.
//

import Foundation

struct MessageBody: Codable {
    var model: String
    var messages: [Message]
    var stream: Bool
}

struct Message: Codable {
    var role: String
    var content: String
}

class DeepSeek: LLMProtocol {
    private let baseURLStr = "https://api.deepseek.com"
    
    
    func invoke(msg: String) -> String {
        var request = chatRequest()
        var msgBody = makeMessageBody(userContent: msg)
        
        guard let jsonData = try? JSONEncoder().encode(msgBody) else {
            return "Failed to encode user content"
        }
        
        Task {
            do {
                //send data
                let(data, _) = try await URLSession.shared.upload(for: request, from: jsonData)
                
                //receive reponse data
            } catch {
                print("Check out failed: \(error.localizedDescription)")
            }
        }
        
        return ""
    }
    
    private func chatURL() -> URL {
        return URL(string: baseURLStr + "/chat/completions")!
    }
    
    private func chatRequest() -> URLRequest {
        var request = URLRequest(url: chatURL())
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(LLMKey.value(for: .DeepSeek))", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func makeMessageBody(userContent: String) -> MessageBody {
        MessageBody(
            model: "deepseek-chat",
            messages: [
                Message(role: "system", content: "You are a helpful assistant."),
                Message(role: "user", content: userContent)
            ],
            stream: false
        )
    }
}


