//
//  Message.swift
//  LangSwift
//
//  Created by ke on 1/9/26.
//

enum Role: String, Codable {
    case system
    case user
    case assistant
    case tool
}

enum Message: Codable {
    case system(String)
    case user(String)
    case assistant(String)
    case tool(String)
}

extension Message {
    var role: Role {
        switch self {
        case .system: return .system
        case .user: return .user
        case .assistant: return .assistant
        case .tool: return .tool
        }
    }
    
    var content: String {
        switch self {
        case .system(let content),
                .user(let content),
                .assistant(let content),
                .tool(let content):
            return content
        }
    }
}

