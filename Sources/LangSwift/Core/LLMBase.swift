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

enum Role: String, Codable {
    case system = "system"
    case user = "user"
    case assistant = "assistant"
    case tool = "tool"
}


enum LLMError: Error, LocalizedError {
    case missingAPIKey

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "LLM API key is missing."
        }
    }
}
