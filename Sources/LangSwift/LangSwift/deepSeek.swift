//
//  DeepSeek.swift
//  LangSwift
//
//  Created by ke Liu on 1/3/26.
//

import Foundation

enum DeepSeekModelType: String {
    case deepSeekChat = "deepseek-chat"
}

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
    
    
    func invoke(message: String) async -> String {
        var request = chatRequest()
        return await sendMessageAndGetRespond(request: request, message: message)
    }
    
    private func chatURL() -> URL {
        return URL(string: baseURLStr + "/chat/completions")!
    }
    
    private func chatRequest() -> URLRequest {
        var request = URLRequest(url: chatURL())
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(LLMKey.value(for: .deepSeek))", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func makeMessageBody(userContent: String) -> MessageBody {
        MessageBody(
            model: DeepSeekModelType.deepSeekChat.rawValue,
            messages: [
                Message(role: "system", content: "You are a helpful assistant."),
                Message(role: "user", content: userContent)
            ],
            stream: false
        )
    }
    
    private func sendMessageAndGetRespond(request: URLRequest, message: String) async -> String {
        var msgBody = makeMessageBody(userContent: message)
        
        guard let msgBodyJson = try? JSONEncoder().encode(msgBody) else {
            return "Failed to encode user content"
        }
        
        do {
            let(data, _) = try await URLSession.shared.upload(for: request, from: msgBodyJson)
            
            //TODO: receive data
            return ""
            
            
        } catch {
            return "some error happened, please try again"
        }
    }
}


