//
//  ChatPromptTemplateTests.swift
//  LangSwift
//
//  Created by ke Liu on 4/27/26.
//

import Testing
@testable import LangSwift

@Test func testFormatPromptReplacesSingleVariable() throws {
    let result = try "Tell me about {topic}".formatPrompt(with: [
        "topic": "Swift"
    ])
    
    #expect(result == "Tell me about Swift")
}

@Test func testFormatPromptReplacesMultipleVariables() throws {
    let result = try "{name} is learning {language}.".formatPrompt(with: [
        "name": "Ke",
        "language": "Swift"
    ])
    
    #expect(result == "Ke is learning Swift.")
}

@Test func testFormatPromptReplacesRepeatedVariables() throws {
    let result = try "{word}, {word}!".formatPrompt(with: [
        "word": "hello"
    ])
    
    #expect(result == "hello, hello!")
}

@Test func testFormatPromptTrimsVariableWhitespace() throws {
    let result = try "Use { topic } today.".formatPrompt(with: [
        "topic": "SwiftUI"
    ])
    
    #expect(result == "Use SwiftUI today.")
}

@Test func testFormatPromptThrowsForMissingValue() throws {
    do {
        _ = try "Tell me about {topic}".formatPrompt(with: [:])
        Issue.record("Expected missingValue error.")
    } catch let error as ChatPromptTemplateError {
        #expect(error == .missingValue("topic"))
    }
}

@Test func testFormatPromptThrowsForEmptyVariableName() throws {
    do {
        _ = try "Tell me about {}".formatPrompt(with: [:])
        Issue.record("Expected emptyVariableName error.")
    } catch let error as ChatPromptTemplateError {
        #expect(error == .emptyVariableName)
    }
}

@Test func testFormatPromptThrowsForUnclosedVariable() throws {
    do {
        _ = try "Tell me about {topic".formatPrompt(with: [
            "topic": "Swift"
        ])
        Issue.record("Expected unclosedVariable error.")
    } catch let error as ChatPromptTemplateError {
        #expect(error == .unclosedVariable("topic"))
    }
}

@Test func testFormatValues() throws {
    let template = ChatPromptTemplate.fromTemplate("I need some {item}")
    let templateMessage = try template.format(["item" : "books"])
    
    #expect(templateMessage == "I need some books")
}
