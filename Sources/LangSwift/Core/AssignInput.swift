//
//  AssignInput.swift
//  LangSwift
//
//  Created by Codex on 4/27/26.
//

public struct AssignInput: Runnable {
    public let key: String

    public init(_ key: String) {
        self.key = key
    }

    public func invoke(_ input: String) async throws -> [String: String] {
        [key: input]
    }
}
