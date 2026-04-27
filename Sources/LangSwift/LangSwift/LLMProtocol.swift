//
//  LLMProtocol.swift
//  LangSwift
//
//  Created by ke Liu on 1/8/26.
//
import Foundation

public protocol LLMProtocol: Runnable where Input == [Message], Output == String {
    func invoke(userContent: String) async throws -> String
    func invoke(messages: [Message]) async throws -> String
}

public extension LLMProtocol {
    func invoke(_ input: [Message]) async throws -> String {
        try await invoke(messages: input)
    }
}
