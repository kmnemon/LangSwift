//
//  DeepSeek.swift
//  LangSwift
//
//  Created by ke Liu on 1/3/26.
//

import Foundation

enum DeepSeekModel: String {
    case deepSeekChat = "deepseek-chat"
    case deepSeekReasoner = "deepseek-reasoner"
}

struct ChatMessageBody<T: BaseMessage> : Codable {
    var model: String
    var messages: [T]
    var stream: Bool
}

struct Thinking: Codable {
    var type: String
}

class DeepSeek: LLMProtocol {
    private let baseURLStr = "https://api.deepseek.com"
    private var mode: DeepSeekModel = .deepSeekChat
    private var key: String
    private var thinking: Thinking?
    private var frequencyPenalty: Double?
    
    init() throws {
        guard let key = LLMKey.value(for: .deepSeek) else { throw LLMError.missingAPIKey }
        self.key = key
    }
    
    init(mode: DeepSeekModel) throws {
        self.mode = mode
        
        guard let key = LLMKey.value(for: .deepSeek) else { throw LLMError.missingAPIKey }
        self.key = key
    }
    
    func invoke(userContent: String) async -> String {
        let request = chatRequest()
        let messages: [Message] = makeMessage(userContent: userContent)
        return await sendMessageAndGetRespond(request: request, messages: messages)
    }
    
    func invoke(messages: [Message]) async -> String {
        let request = chatRequest()
        return await sendMessageAndGetRespond(request: request, messages: messages)
    }
    
    private func chatURL() -> URL {
        return URL(string: baseURLStr + "/chat/completions")!
    }
    
    private func chatRequest() -> URLRequest {
        var request = URLRequest(url: chatURL())
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func makeMessage(userContent: String) -> [Message] {
        return [
            Message(role: Role.system, content: "You are a helpful assistant."),
            Message(role: Role.user, content: userContent)
        ]
    }
    
    // MARK: - DeepSeek API Response Models
    private struct DeepSeekChatResponse: Codable {
        struct Choice: Codable {
            let index: Int?
            let message: DeepSeekChoiceMessage
            let finish_reason: String?
        }
        let id: String?
        let object: String?
        let created: Int?
        let model: String?
        let choices: [Choice]
    }
    
    private struct DeepSeekChoiceMessage: Codable {
        let role: String
        let content: String
    }
    
    private func sendMessageAndGetRespond(request: URLRequest, messages: [Message]) async -> String {
        let chatMsgBody = makeChatMessageBody(messages: messages)
        
        guard let chatMsgBodyJson = try? JSONEncoder().encode(chatMsgBody) else {
            return "Failed to encode user content"
        }
        
        do {
            let (data, response) = try await URLSession.shared.upload(for: request, from: chatMsgBodyJson)
            
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                let body = String(data: data, encoding: .utf8) ?? "<non-utf8 body>"
                return "HTTP \(http.statusCode): \(body)"
            }
            
            // Try to decode DeepSeek chat completion response
            if let chat = try? JSONDecoder().decode(DeepSeekChatResponse.self, from: data) {
                if let first = chat.choices.first {
                    return first.message.content
                } else {
                    return "No choices returned from API."
                }
            }
            
            // Fallback: return raw string if JSON shape differs
            if let text = String(data: data, encoding: .utf8) {
                return text
            }
            return "Received non-textual response."
        } catch {
            return "some error happened, please try again"
        }
    }
    
    private func makeChatMessageBody(messages: [Message]) -> ChatMessageBody<Message> {
        return ChatMessageBody(
            model: mode.rawValue,
            messages: messages,
            stream: false
        )
    }
}

