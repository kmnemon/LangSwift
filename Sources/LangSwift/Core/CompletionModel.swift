//
//  LLM.swift
//  LangSwift
//
//  Created by ke Liu on 1/3/26.
//

import Foundation

struct ChatQuery: Encodable {
    let messages: [Message]
    let model: Model
    let temperature: Double?
    let maxTokens: Int?

    init(
        messages: [Message],
        model: Model,
        temperature: Double? = nil,
        maxTokens: Int? = nil
    ) {
        self.messages = messages
        self.model = model
        self.temperature = temperature
        self.maxTokens = maxTokens
    }

    private enum CodingKeys: String, CodingKey {
        case messages
        case model
        case temperature
        case maxTokens = "max_tokens"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messages.map(ChatRequestMessage.init(message:)), forKey: .messages)
        try container.encode(model, forKey: .model)
        try container.encodeIfPresent(temperature, forKey: .temperature)
        try container.encodeIfPresent(maxTokens, forKey: .maxTokens)
    }
}

private struct ChatRequestMessage: Encodable {
    let role: Role
    let content: String

    init(message: Message) {
        self.role = message.role
        self.content = message.content
    }
}

struct ChatCompletionResponse: Decodable {
    let choices: [ChatChoice]
}

struct ChatChoice: Decodable {
    let message: ChatResponseMessage
}

struct ChatResponseMessage: Decodable {
    let role: Role?
    let content: String?
}

final class CompletionModel: BaseModel {
    func chats(query: ChatQuery) async throws -> ChatCompletionResponse {
        let request = try makeRequest(path: "/v1/chat/completions", body: query)
        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data)
        return try jsonDecoder.decode(ChatCompletionResponse.self, from: data)
    }
}
