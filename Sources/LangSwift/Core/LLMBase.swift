//
//  LLM.swift
//  LangSwift
//
//  Created by ke Liu on 1/3/26.
//

import Foundation

enum LLMKey: String {
    case openAI = "OPENAI_API_KEY"
    case deepSeek = "DEEPSEEK_API_KEY"
    case qwen = "QWEN_API_KEY"
    
    static func value(for key: LLMKey) -> String? {
        ProcessInfo.processInfo.environment[key.rawValue]
    }
    
    @discardableResult
    static func setValue(_ value: String, for key: LLMKey, overwrite: Bool = true) -> Bool {
        // setenv returns 0 on success, -1 on failure
        let result = setenv(key.rawValue, value, overwrite ? 1 : 0)
        return result == 0
    }
    
    @discardableResult
    static func clearValue(for key: LLMKey) -> Bool {
        // unsetenv returns 0 on success, -1 on failure
        let result = unsetenv(key.rawValue)
        return result == 0
    }
}




enum LLMError: Error, LocalizedError {
    case missingAPIKey
    case invalidBaseURL(String)
    case invalidResponse
    case requestFailed(statusCode: Int, body: String)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "LLM API key is missing."
        case .invalidBaseURL(let baseURL):
            return "Invalid LLM base URL: \(baseURL)"
        case .invalidResponse:
            return "LLM returned an invalid response."
        case .requestFailed(let statusCode, let body):
            return "LLM request failed with status code \(statusCode): \(body)"
        case .emptyResponse:
            return "LLM returned an empty response."
        }
    }
}

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

final class LLM {
    struct Configuration {
        let token: String?
        let host: String
        let timeoutInterval: TimeInterval

        init(token: String?, host: String = "api.openai.com", timeoutInterval: TimeInterval = 60.0) {
            self.token = token
            self.host = host
            self.timeoutInterval = timeoutInterval
        }
    }

    private let configuration: Configuration
    private let session: URLSession
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    init(configuration: Configuration, session: URLSession = .shared) {
        self.configuration = configuration
        self.session = session
        self.jsonEncoder = JSONEncoder()
        self.jsonDecoder = JSONDecoder()
    }

    func chats(query: ChatQuery) async throws -> ChatCompletionResponse {
        let request = try makeRequest(path: "/v1/chat/completions", body: query)
        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data)
        return try jsonDecoder.decode(ChatCompletionResponse.self, from: data)
    }

    func makeRequest<Body: Encodable>(path: String, body: Body) throws -> URLRequest {
        guard let token = configuration.token, token.isEmpty == false else {
            throw LLMError.missingAPIKey
        }

        guard let url = makeURL(path: path) else {
            throw LLMError.invalidBaseURL(configuration.host)
        }

        var request = URLRequest(url: url, timeoutInterval: configuration.timeoutInterval)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try jsonEncoder.encode(body)
        return request
    }

    func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LLMError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw LLMError.requestFailed(statusCode: httpResponse.statusCode, body: body)
        }
    }

    func decode<Response: Decodable>(_ type: Response.Type, from data: Data) throws -> Response {
        try jsonDecoder.decode(type, from: data)
    }

    private func makeURL(path: String) -> URL? {
        let host = configuration.host.trimmingCharacters(in: .whitespacesAndNewlines)
        let baseURLString = host.contains("://") ? host : "https://\(host)"

        guard let baseURL = URL(string: baseURLString) else {
            return nil
        }

        return baseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
    }
}
