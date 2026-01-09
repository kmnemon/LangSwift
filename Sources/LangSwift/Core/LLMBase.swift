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
    
    static func value(for key: LLMKey) -> String {
        ProcessInfo.processInfo.environment[key.rawValue]!
    }
}

