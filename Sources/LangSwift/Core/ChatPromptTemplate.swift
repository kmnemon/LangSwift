//
//  ChatPromptTemplate.swift
//  LangSwift
//
//  Created by ke Liu on 4/27/26.
//

import Foundation

public struct ChatPromptTemplate: Runnable {
    public let messages: [Message]

    public init(messages: [Message]) {
        self.messages = messages
    }

    public static func fromTemplate(_ template: String) -> ChatPromptTemplate {
        ChatPromptTemplate(messages: [.user(template)])
    }

    public static func fromMessages(_ messages: [Message]) -> ChatPromptTemplate {
        ChatPromptTemplate(messages: messages)
    }

    public static func fromMessages(_ messages: [(Role, String)]) -> ChatPromptTemplate {
        ChatPromptTemplate(messages: messages.map { role, content in
            Message(role: role, content: content)
        })
    }

    public var inputVariables: [String] {
        Array(Set(messages.flatMap { $0.content.promptVariables })).sorted()
    }

    public func format(_ values: [String: String]) throws -> String {
        try formatMessages(values).map(\.content).joined(separator: "\n")
    }

    public func formatMessages(_ values: [String: String]) throws -> [Message] {
        try messages.map { message in
            Message(
                role: message.role,
                content: try message.content.formatPrompt(with: values)
            )
        }
    }

    public func invoke(_ values: [String: String]) async throws -> [Message] {
        try formatMessages(values)
    }
}

public enum ChatPromptTemplateError: Error, LocalizedError, Equatable {
    case missingValue(String)
    case emptyVariableName
    case unclosedVariable(String)

    public var errorDescription: String? {
        switch self {
        case .missingValue(let name):
            return "Missing value for prompt variable '\(name)'."
        case .emptyVariableName:
            return "Prompt variable names cannot be empty."
        case .unclosedVariable(let name):
            return "Prompt variable '\(name)' is missing a closing brace."
        }
    }
}

private extension Message {
    init(role: Role, content: String) {
        switch role {
        case .system:
            self = .system(content)
        case .user:
            self = .user(content)
        case .assistant:
            self = .assistant(content)
        case .tool:
            self = .tool(content)
        }
    }
}

public extension String {
    var promptVariables: [String] {
        var variables: [String] = []
        var searchIndex = startIndex

        while let openBrace = self[searchIndex...].firstIndex(of: "{") {
            guard let closeBrace = self[index(after: openBrace)...].firstIndex(of: "}") else {
                break
            }

            let name = self[index(after: openBrace)..<closeBrace]
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if name.isEmpty == false {
                variables.append(name)
            }

            searchIndex = index(after: closeBrace)
        }

        return variables
    }

    func formatPrompt(with values: [String: String]) throws -> String {
        var result = ""
        var searchIndex = startIndex

        while let openBrace = self[searchIndex...].firstIndex(of: "{") {
            result += self[searchIndex..<openBrace]

            let variableStart = index(after: openBrace)
            guard let closeBrace = self[variableStart...].firstIndex(of: "}") else {
                let variableName = String(self[variableStart...])
                throw ChatPromptTemplateError.unclosedVariable(variableName)
            }

            let variableName = self[variableStart..<closeBrace]
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard variableName.isEmpty == false else {
                throw ChatPromptTemplateError.emptyVariableName
            }

            guard let value = values[variableName] else {
                throw ChatPromptTemplateError.missingValue(variableName)
            }

            result += value
            searchIndex = index(after: closeBrace)
        }

        result += self[searchIndex...]
        return result
    }
}
