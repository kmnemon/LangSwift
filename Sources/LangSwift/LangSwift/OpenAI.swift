//
//  OpenAI.swift
//  LangSwift
//
//  Created by ke on 5/9/26.
//

public final class OpenAI: Runnable {
    private let chatCompletions: ChatCompletions
    
    public init(
        mode: String = .gpt4_o_mini,
        baseURL: String = "api.chatanywhere.tech",
        temperature: Double? = nil
    ) {
        self.chatCompletions = ChatCompletions(mode: mode, baseURL: baseURL, temperature: temperature)
    }

    public func invoke(userContent: String) async throws -> String {
        try await chatCompletions.invoke(userContent: userContent)
    }

    public func invoke(messages: [Message]) async throws -> String {
        try await chatCompletions.invoke(messages: messages)
    }

    public func invoke(_ input: [Message]) async throws -> String {
        try await invoke(messages: input)
    }
}
