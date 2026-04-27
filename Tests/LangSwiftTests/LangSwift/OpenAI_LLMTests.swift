//
//  OpenAI_LLMTests.swift
//  LangSwift
//
//  Created by ke Liu on 4/7/26.
//
import Testing
@testable import LangSwift

@Test func testOpenAISendMessage() async throws {
    InitKey.initKeys()
    
    let openai = ChatCompletions()
    let resp = try! await openai.invoke(userContent: "give me some icecream")
    
    print(resp)
    #expect(resp != "")
}

@Test func testOpenAISendMessageWithTemplate() async throws {
    InitKey.initKeys()
    
    let openai = ChatCompletions()
    let template = ChatPromptTemplate.fromTemplate("I need some {item}")
    let templateMessage = try template.format(["item" : "books"])
    
    let resp = try! await openai.invoke(userContent: templateMessage)
    
    print(resp)
    #expect(resp != "")
}

