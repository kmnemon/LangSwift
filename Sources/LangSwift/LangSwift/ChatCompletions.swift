//
//  Qwen.swift
//  LangSwift
//
//  Created by ke Liu on 1/8/26.
//

class ChatCompletions: LLMProtocol {
    private var llm: CompletionModel
    private var mode: String
    
    init(mode: String = .gpt4_o_mini, baseURL: String = "api.chatanywhere.tech") {
        let configuration = CompletionModel.Configuration(token: LLMKey.value(for: LLMKey.openAI), host: baseURL, timeoutInterval: 60.0)
        self.llm = CompletionModel(configuration: configuration)
        self.mode = mode
    }
    
    func invoke(userContent: String) async throws -> String {
        let query = ChatQuery(
            messages: [
                .user(userContent)
            ],
            model: self.mode
        )
        
        let result = try await llm.chats(query: query)
        return result.choices.first?.message.content ?? "no respond"
    }
    
    func invoke(messages: [Message]) async throws -> String {
        let query = ChatQuery(
            messages: messages,
            model: self.mode
        )
        
        let result = try await llm.chats(query: query)
        return result.choices.first?.message.content ?? "no respond"
    }
}
