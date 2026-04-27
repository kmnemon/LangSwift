//
//  Runnable.swift
//  LangSwift
//
//  Created by Codex on 4/27/26.
//

public protocol Runnable {
    associatedtype Input
    associatedtype Output

    func invoke(_ input: Input) async throws -> Output
}

public extension Runnable {
    func callAsFunction(_ input: Input) async throws -> Output {
        try await invoke(input)
    }
}

public struct RunnableSequence<First: Runnable, Second: Runnable>: Runnable where First.Output == Second.Input {
    public let first: First
    public let second: Second

    public init(first: First, second: Second) {
        self.first = first
        self.second = second
    }

    public func invoke(_ input: First.Input) async throws -> Second.Output {
        let intermediate = try await first.invoke(input)
        return try await second.invoke(intermediate)
    }
}

public func | <First: Runnable, Second: Runnable>(
    first: First,
    second: Second
) -> RunnableSequence<First, Second> where First.Output == Second.Input {
    RunnableSequence(first: first, second: second)
}
