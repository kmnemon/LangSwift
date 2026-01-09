//
//  DeepSeek.swift
//  LangSwift
//
//  Created by ke Liu on 1/3/26.
//

import Foundation

enum DeepSeekModel: String {
    case deepSeekChat = "deepseek-chat"
}

struct ChatMessage<T: BaseMessage> : Codable {
    var model: String
    var messages: [T]
    var stream: Bool
}

class DeepSeek: LLMProtocol {
    private let baseURLStr = "https://api.deepseek.com"
    private var mode: DeepSeekModel = .deepSeekChat
    
    init() {}
    init(mode: DeepSeekModel) {
        self.mode = mode
    }
    
    func invoke(userContent: String) async -> String {
        var request = chatRequest()
        var messages: [Message] = makeMessage(userContent: userContent)
        return await sendMessageAndGetRespond(request: request, messages: messages)
    }
    
    func invoke(messages: [Message]) async -> String {
        var request = chatRequest()
        return await sendMessageAndGetRespond(request: request, messages: messages)
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
    
    private func makeMessage(userContent: String) -> [Message] {
        return [
            Message(role: Role.system, content: "You are a helpful assistant."),
            Message(role: Role.user, content: userContent)
        ]
    }
    
    private func sendMessageAndGetRespond(request: URLRequest, messages: [Message]) async -> String {
        var chatMsg = makeChatMessage(messages: messages)
        
        guard let chatMsgJson = try? JSONEncoder().encode(chatMsg) else {
            return "Failed to encode user content"
        }
        
        do {
            let(data, _) = try await URLSession.shared.upload(for: request, from: chatMsgJson)
            
            //TODO: receive data
            return ""
            
        } catch {
            return "some error happened, please try again"
        }
    }
    
    private func makeChatMessage(messages: [Message]) -> ChatMessage<Message> {
        return ChatMessage(
            model: mode.rawValue,
            messages: messages,
            stream: false
        )
    }
}
