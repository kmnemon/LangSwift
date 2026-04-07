//
//  OpenAI.swift
//  LangSwift
//
//  Created by ke Liu on 1/3/26.
//
import OpenAI

enum OpenAIModel: String {
    case gpt_4o = "gpt-4o"
    case gpt_4o_mini = "gpt-4o-mini"
}

class OpenAI_LLM: LLMProtocol {
    private var openAI: OpenAI
    private var mode: OpenAIModel
    
    init(mode: OpenAIModel = .gpt_4o_mini, baseURL: String = "api.chatanywhere.tech") {
        let configuration = OpenAI.Configuration(token: LLMKey.value(for: LLMKey.openAI), host: baseURL, timeoutInterval: 60.0)
        self.openAI = OpenAI(configuration: configuration)
        self.mode = mode
    }
    
    func invoke(userContent: String) async throws -> String {
        let query = ChatQuery(
            messages: [
                .user(.init(content: .string(userContent)))
            ],
            model: self.mode.rawValue
        )

        do {
            let result = try await openAI.chats(query: query)
            return result.choices.first?.message.content ?? "no respond"
        } catch {
            throw error
        }
    }
    
    func invoke(messages: [Message]) async -> String {
        return ""
    }
}
    
