//
//  RunnableTests.swift
//  LangSwift
//
//  Created by Codex on 4/27/26.
//

import Testing
@testable import LangSwift

struct RunnableTests {
    @Test func promptLLMStringParserChainReturnsModelText() async throws {
        let prompt = ChatPromptTemplate.fromTemplate(
            "Extract the technical specifications from the following text:\n\n{text_input}"
        )
        let llm = StubLLM { messages in
            let input = messages.map(\.content).joined(separator: "\n")
            return "Extracted: \(input)"
        }

        let chain = prompt | llm | StrOutputParser()
        let result = try await chain.invoke([
            "text_input": "The laptop has an M4 CPU, 24GB memory, and 1TB storage."
        ])

        #expect(result.contains("Extracted:"), "The parser should return the LLM string output.")
        #expect(result.contains("M4 CPU"))
        #expect(result.contains("24GB memory"))
        #expect(result.contains("1TB storage"))
    }

    @Test func promptChainCanBeInvokedWithCallSyntax() async throws {
        let prompt = ChatPromptTemplate.fromTemplate("Summarize {topic}")
        let llm = EchoLLM()
        let chain = prompt | llm | StrOutputParser()

        let result = try await chain(["topic": "Swift concurrency"])

        #expect(result == "Summarize Swift concurrency")
    }

    @Test func chainCanFeedOnePromptResultIntoAnotherPrompt() async throws {
        let promptExtract = ChatPromptTemplate.fromTemplate(
            "Extract specs:\n\n{text_input}"
        )
        let promptTransform = ChatPromptTemplate.fromTemplate(
            "Transform the following specifications into JSON:\n\n{specifications}"
        )
        let llm = EchoLLM()

        let chain = promptExtract
            | llm
            | StrOutputParser()
            | AssignInput("specifications")
            | promptTransform
            | llm
            | StrOutputParser()

        let result = try await chain.invoke([
            "text_input": "CPU: M4. Memory: 24GB. Storage: 1TB."
        ])

        #expect(result == """
        Transform the following specifications into JSON:

        Extract specs:

        CPU: M4. Memory: 24GB. Storage: 1TB.
        """)
    }

    @Test func assignInputWrapsStringOutputForNextPromptVariable() async throws {
        let assign = AssignInput("specifications")
        let result = try await assign.invoke("CPU: M4")

        #expect(result == ["specifications": "CPU: M4"])
    }

    @Test func missingPromptVariableStopsChainBeforeCallingLLM() async {
        let prompt = ChatPromptTemplate.fromTemplate("Extract {text_input}")
        let llm = FailingIfCalledLLM()
        let chain = prompt | llm | StrOutputParser()

        do {
            _ = try await chain.invoke([:])
            Issue.record("Expected missingValue error.")
        } catch let error as ChatPromptTemplateError {
            #expect(error == .missingValue("text_input"))
        } catch {
            Issue.record("Wrong error thrown: \(error)")
        }
    }

    @Test func llmErrorPropagatesThroughChain() async {
        let prompt = ChatPromptTemplate.fromTemplate("Extract {text_input}")
        let llm = ThrowingLLM(error: ChainTestError.llmFailed)
        let chain = prompt | llm | StrOutputParser()

        do {
            _ = try await chain.invoke(["text_input": "CPU: M4"])
            Issue.record("Expected LLM error.")
        } catch let error as ChainTestError {
            #expect(error == .llmFailed)
        } catch {
            Issue.record("Wrong error thrown: \(error)")
        }
    }
}

private struct EchoLLM: LLMProtocol {
    func invoke(userContent: String) async throws -> String {
        userContent
    }

    func invoke(messages: [Message]) async throws -> String {
        messages.map(\.content).joined(separator: "\n")
    }
}

private struct StubLLM: LLMProtocol {
    let response: ([Message]) throws -> String

    func invoke(userContent: String) async throws -> String {
        try response([.user(userContent)])
    }

    func invoke(messages: [Message]) async throws -> String {
        try response(messages)
    }
}

private struct FailingIfCalledLLM: LLMProtocol {
    func invoke(userContent: String) async throws -> String {
        Issue.record("LLM should not be called when prompt formatting fails.")
        return ""
    }

    func invoke(messages: [Message]) async throws -> String {
        Issue.record("LLM should not be called when prompt formatting fails.")
        return ""
    }
}

private struct ThrowingLLM: LLMProtocol {
    let error: Error

    func invoke(userContent: String) async throws -> String {
        throw error
    }

    func invoke(messages: [Message]) async throws -> String {
        throw error
    }
}

private enum ChainTestError: Error, Equatable {
    case llmFailed
}
